#!/bin/bash

set -euo pipefail

function installTravisTools {
  mkdir ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/14dd372c1f4ae04dce0890919c20007d670b1a4c | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}

installTravisTools

case "$TEST" in

ci)
  #deploy pull request artifacts to repox to start QA
  export DEPLOY_PULL_REQUEST=true
  regular_mvn_build_deploy_analyze  
  ;;

*)
  echo "Unexpected TEST mode: $TEST"
  exit 1
  ;;

esac
