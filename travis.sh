#!/bin/bash

set -euo pipefail

function installTravisTools {
  mkdir ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/fb9805abb6e894d9cc230849d89a5aebfb97e593 | tar zx --strip-components 1 -C ~/.local
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
