#!/bin/bash

set -euo pipefail

function installTravisTools {
  mkdir ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/947456dcf0f29ef05b14226b2c09e8c709ea975b | tar zx --strip-components 1 -C ~/.local
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
