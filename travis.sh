#!/bin/bash

set -euo pipefail

#deploy pull request artifacts to repox to start QA
export DEPLOY_PULL_REQUEST=true

function installTravisTools {
  mkdir -p ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/v36 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}
installTravisTools

if [ -z "$USE_GRADLE" ]; then

  regular_mvn_build_deploy_analyze
  
else

  # Enable the release process of the project (through Artifactory BuildInfo)
  # * Download artifacts from BURGR
  # * Publication to Bintray
  export ARTIFACT_TO_PUBLISH="org.sonarsource.dummy:sonar-dummy-oss-plugin:jar"
  
  # This function is needed to deploy fixed version on Artifactory (Snapshots are not allowed)
  # It also export the variable PROJECT_VERSION which is used by QA builds (through Artifactory BuildInfo) to get the version of the project to use on QA
  function prepareBuildVersion {
    CURRENT_VERSION=`cat gradle.properties | grep version | awk -F= '{print $2}'`
    RELEASE_VERSION=`echo $CURRENT_VERSION | sed "s/-.*//g"`
    # In case of 2 digits, we need to add the 3rd digit (0 obviously)
    # Mandatory in order to compare versions (patch VS non patch)
    IFS=$'.'
    DIGIT_COUNT=`echo $RELEASE_VERSION | wc -w`
    unset IFS
    if [ $DIGIT_COUNT -lt 3 ]; then
      RELEASE_VERSION="$RELEASE_VERSION.0"
    fi
    NEW_VERSION="$RELEASE_VERSION.$TRAVIS_BUILD_NUMBER"
    export PROJECT_VERSION=$NEW_VERSION
    # Deploy the release version related to this build instead of snapshot
    sed -i.bak "s/$CURRENT_VERSION/$NEW_VERSION/g" gradle.properties
  }
  
  function strongEcho {
    echo ""
    echo "================ $1 ================="
  }
  
  # On Travis container based infrastructure, the JVM can see 64GiB of memory (memory available for the machine running the containers)!
  # Let's reduce it!!
  export GRADLE_OPTS="-Xmx512m"
  
  if [ "$TRAVIS_BRANCH" == "master" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    strongEcho 'Build and analyze commit in master and publish in artifactory'
    # this commit is master must be built and analyzed (with upload of report)
  
    prepareBuildVersion
    ./gradlew build check sonarqube artifactory \
        -Dsonar.projectVersion=$CURRENT_VERSION \
        -Dsonar.host.url=$SONAR_HOST_URL \
        -Dsonar.login=$SONAR_TOKEN
  
  elif [[ "${TRAVIS_BRANCH}" == "branch-"* ]] && [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    strongEcho 'Build and publish in artifactory'
    prepareBuildVersion
  
    #build and deploy - no dory analysis on release branch
    ./gradlew build check artifactory 
  
  elif [ "$TRAVIS_PULL_REQUEST" != "false" ] && [ "$TRAVIS_SECURE_ENV_VARS" == "true" ]; then
    strongEcho 'Build and analyze pull request'  
  
    if [ "${DEPLOY_PULL_REQUEST:-}" == "true" ]; then
      echo '======= with deploy'
  
      prepareBuildVersion
      ./gradlew build check sonarqube artifactory \
        -Dsonar.analysis.mode=issues \
        -Dsonar.github.pullRequest=$TRAVIS_PULL_REQUEST \
        -Dsonar.github.repository=$TRAVIS_REPO_SLUG \
        -Dsonar.github.oauth=$GITHUB_TOKEN \
        -Dsonar.host.url=$SONAR_HOST_URL \
        -Dsonar.login=$SONAR_TOKEN
  
    else
      echo '======= no deploy'
  
      ./gradlew build check sonarqube \
        -Dsonar.analysis.mode=issues \
        -Dsonar.github.pullRequest=$TRAVIS_PULL_REQUEST \
        -Dsonar.github.repository=$TRAVIS_REPO_SLUG \
        -Dsonar.github.oauth=$GITHUB_TOKEN \
        -Dsonar.host.url=$SONAR_HOST_URL \
        -Dsonar.login=$SONAR_TOKEN
    fi
  else
    strongEcho 'Build, no analysis'
    # Build branch, without any analysis
  
    ./gradlew build check
  fi

fi

