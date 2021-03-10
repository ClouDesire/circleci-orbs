#!/bin/bash

MavenRelease() {
  RELEASE_VERSION="${CIRCLE_BRANCH//release-}"
  echo "export MAVEN_RELEASE_VERSION=${RELEASE_VERSION}" >> "${BASH_ENV}"
  cd "$PROJECT_DIR"

  echo "Releasing $RELEASE_VERSION"
  ./mvnw versions:set -DnewVersion="${RELEASE_VERSION}" -DgenerateBackupPoms=false
  ./mvnw deploy -Dmaven.test.skip=true

  #./mvnw scm:tag -Dtag=v${VERSION}
  
  echo "${GIT_EMAIL}"
  echo "${GIT_USERNAME}"
  git config --global user.email "${GIT_EMAIL}"
  git config --global user.name "${GIT_USERNAME}"


  IFS='.' read -a semver <<< "$RELEASE_VERSION"
  NEW_VERSION="${semver[0]}.${semver[1]}.$((${semver[2]} + 1))"
  echo "Updating pom.xml version to $NEW_VERSION"
  ./mvnw versions:set -DnewVersion="${NEW_VERSION}-SNAPSHOT" scm:checkin -Dmessage="[skip ci] Preparing for next iteration - version set to ${NEW_VERSION}-SNAPSHOT" -DgenerateBackupPoms=false

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  MavenRelease
fi
