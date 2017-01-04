#!/bin/bash

#download SQ
cd sonarqube
wget -c https://repox.sonarsource.com/sonarsource-qa/org/sonarsource/sonarqube/sonar-application/6.3-build16399/sonar-application-6.3-build16399.zip --user=$ARTIFACTORY_QA_READER_USERNAME --password=$ARTIFACTORY_QA_READER_PASSWORD --auth-no-challenge
cd ..
# set project version
export PROJECT_VERSION=1.$TRAVIS_BUILD_ID-$HOSTNAME
mvn versions:set -DgenerateBackupPoms=false -DnewVersion=$PROJECT_VERSION

#upload SQ
mvn deploy -Pdeploy-sonarsource -B -e -V