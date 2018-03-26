#!/bin/bash

set -euo pipefail

function installTravisTools {
  mkdir -p ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/81e8f14c0ee4b93c2e70383e660493d8146263be | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}
installTravisTools

. ~/.local/bin/installJDK8

# When a pull request is open on the branch, then the job related
# to the branch does not need to be executed and should be canceled.
# It does not book slaves for nothing.
# @TravisCI please provide the feature natively, like at AppVeyor or CircleCI ;-)
cancel_branch_build_with_pr || if [[ $? -eq 1 ]]; then exit 0; fi

regular_gradle_build_deploy_analyze