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

# allow deployment of PR artifacts to repox with
export DEPLOY_PULL_REQUEST=true

regular_mvn_build_deploy_analyze
