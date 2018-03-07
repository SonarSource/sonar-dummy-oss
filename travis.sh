#!/bin/bash

set -euo pipefail

#deploy pull request artifacts to repox to start QA
export DEPLOY_PULL_REQUEST=true

function installTravisTools {
  mkdir -p ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/v44 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}
installTravisTools

. ~/.local/bin/installJDK8

# When a pull request is open on the branch, then the job related
# to the branch does not need to be executed and should be canceled.
# It does not book slaves for nothing.
# @TravisCI please provide the feature natively, like at AppVeyor or CircleCI ;-)
cancel_branch_build_with_pr || if [[ $? -eq 1 ]]; then exit 0; fi

# allow deployment of PR artifacts to repox with
export DEPLOY_PULL_REQUEST=true

# Used by Next
export INITIAL_VERSION=$(cat gradle.properties | grep version | awk -F= '{print $2}')

#
# use generic environments to remove coupling with (and fix) Travis
#
export GIT_COMMIT=$TRAVIS_COMMIT
export BUILD_NUMBER=$TRAVIS_BUILD_NUMBER
if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  export GIT_BRANCH=$TRAVIS_BRANCH
  unset PULL_REQUEST_BRANCH_TARGET
  unset PULL_REQUEST_NUMBER
else
  export GIT_BRANCH=$TRAVIS_PULL_REQUEST_BRANCH
  export PULL_REQUEST_BRANCH_TARGET=$TRAVIS_BRANCH
  export PULL_REQUEST_NUMBER=$TRAVIS_PULL_REQUEST
fi

if [ "$TRAVIS_BRANCH" == "master" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  echo 'Build and analyze master'
  ./gradlew --no-daemon --console plain \
      -DbuildNumber=$BUILD_NUMBER \
      build sonarqube artifactoryPublish \
      -Dsonar.host.url=$SONAR_HOST_URL \
      -Dsonar.login=$SONAR_TOKEN \
      -Dsonar.projectVersion=$INITIAL_VERSION \
      -Dsonar.analysis.buildNumber=$BUILD_NUMBER \
      -Dsonar.analysis.pipeline=$BUILD_NUMBER \
      -Dsonar.analysis.sha1=$GIT_COMMIT \
      -Dsonar.analysis.repository=$TRAVIS_REPO_SLUG

elif [[ "$TRAVIS_BRANCH" == "branch-"* ]] && [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  echo 'Build release branch'
  ./gradlew --no-daemon --console plain \
      -DbuildNumber=$BUILD_NUMBER \
      build sonarqube artifactoryPublish \
      -Dsonar.host.url=$SONAR_HOST_URL \
      -Dsonar.login=$SONAR_TOKEN \
      -Dsonar.branch.name=$TRAVIS_BRANCH \
      -Dsonar.projectVersion=$INITIAL_VERSION \
      -Dsonar.analysis.buildNumber=$BUILD_NUMBER \
      -Dsonar.analysis.pipeline=$BUILD_NUMBER \
      -Dsonar.analysis.sha1=$GIT_COMMIT \
      -Dsonar.analysis.repository=$TRAVIS_REPO_SLUG

elif [ "$TRAVIS_PULL_REQUEST" != "false" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
  echo 'Build and analyze internal pull request'
  ./gradlew --no-daemon --console plain \
      -DbuildNumber=$BUILD_NUMBER \
      build sonarqube artifactoryPublish \
      -Dsonar.host.url=$SONAR_HOST_URL \
      -Dsonar.login=$SONAR_TOKEN \
      -Dsonar.branch.name=$TRAVIS_PULL_REQUEST_BRANCH \
      -Dsonar.branch.target=$TRAVIS_BRANCH \
      -Dsonar.analysis.buildNumber=$BUILD_NUMBER \
      -Dsonar.analysis.pipeline=$BUILD_NUMBER \
      -Dsonar.analysis.sha1=$TRAVIS_PULL_REQUEST_SHA \
      -Dsonar.analysis.prNumber=$TRAVIS_PULL_REQUEST \
      -Dsonar.analysis.repository=$TRAVIS_REPO_SLUG \
      -Dsonar.pullrequest.id=$TRAVIS_PULL_REQUEST \
      -Dsonar.pullrequest.github.id=$TRAVIS_PULL_REQUEST \
      -Dsonar.pullrequest.github.repository=$TRAVIS_REPO_SLUG

else
  echo 'Build feature branch or external pull request'
  ./gradlew --no-daemon --console plain build artifactoryPublish -DbuildNumber=$BUILD_NUMBER
fi
