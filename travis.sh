#!/bin/bash

set -euo pipefail

#deploy pull request artifacts to repox to start QA
export DEPLOY_PULL_REQUEST=true

function installTravisTools {
  mkdir -p ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/v42 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}
installTravisTools
. ~/.local/bin/installJDK8
. ~/.local/bin/installMaven35

# When a pull request is open on the branch, then the job related
# to the branch does not need to be executed and should be canceled.
# It does not book slaves for nothing.
# @TravisCI please provide the feature natively, like at AppVeyor or CircleCI ;-)
cancel_branch_build_with_pr || if [[ $? -eq 1 ]]; then exit 0; fi

# allow deployment of PR artifacts to repox with
export DEPLOY_PULL_REQUEST=true

regular_mvn_build_deploy_analyze
