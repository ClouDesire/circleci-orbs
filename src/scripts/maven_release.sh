#!/bin/bash

MavenRelease() {
  VERSION=$(echo ${CIRCLE_BRANCH//release-})

  cd $PROJECT_DIR

  echo "Releasing $VERSION" 
  #./mvnw deploy -Dmaven.test.skip=true
  #./mvnw scm:tag -Dtag=v${VERSION}

  git config user.email "${GIT_EMAIL}"
  git config user.name "${GIT_USERNAME}"


  IFS='.' read -a semver <<< "$VERSION"
  NEW_VERSION="${semver[0]}.${semver[1]}.$((${semver[2]} + 1))"
  echo "Updating pom.xml version to $NEW_VERSION"
  ./mvnw versions:set -DnewVersion=${NEXT_VERSION}-SNAPSHOT scm:checkin -Dmessage="[skip ci] Preparing for next iteration - version set to ${NEW_VERSION}-SNAPSHOT" -DgenerateBackupPoms=false

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  MavenRelease
fi