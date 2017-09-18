#!/bin/bash

set -euo pipefail

#deploy pull request artifacts to repox to start QA
export DEPLOY_PULL_REQUEST=true

function installTravisTools {
  mkdir -p ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/f0cf0bc49738a07c20029f405ce2059c1ff3d7a7 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}
installTravisTools

regular_mvn_build_deploy_analyze
