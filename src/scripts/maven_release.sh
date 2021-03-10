#!/bin/bash

MavenRelease() {
  VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
  NEW_VERSION=$(echo ${CIRCLE_BRANCH//release-})

  cd $PROJECT_DIR

  echo "Releasing $VERSION" 
  #./mvnw deploy -Dmaven.test.skip=true


  IFS='.' read -a semver <<< "$NEW_VERSION"
  NEW_VERSION="${semver[0]}.${semver[1]}.$((${semver[2]} + 1))"
  echo "Updating pom.xml version to $NEW_VERSION"
  ./mvnw versions:set -DnewVersion=${NEW_VERSION}-SNAPSHOT -DgenerateBackupPoms=false

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  MavenRelease
fi
