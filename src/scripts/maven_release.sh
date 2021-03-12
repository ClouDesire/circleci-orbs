#!/bin/bash

MavenRelease() {
  
  git config --global user.email "${GIT_EMAIL}"
  git config --global user.name "${GIT_USERNAME}"

  
  #RELEASE_VERSION="${CIRCLE_BRANCH//release-}"
  RELEASE_VERSION=$(${MVN_PATH} help:evaluate -Dexpression=project.version -q -DforceStdout)
  echo "export MAVEN_RELEASE_VERSION=${RELEASE_VERSION}" >> "${BASH_ENV}"
  cd "$PROJECT_DIR"

  echo "Releasing $RELEASE_VERSION"
  ${MVN_PATH} versions:set -DnewVersion="${RELEASE_VERSION}" -DgenerateBackupPoms=false
  ${MVN_PATH} deploy -Dmaven.test.skip=true
  
  IFS='.' read -a semver <<< "$RELEASE_VERSION"
  NEW_VERSION="${semver[0]}.${semver[1]}.$((${semver[2]} + 1))"
  echo "Updating pom.xml version to $NEW_VERSION"
  ${MVN_PATH} versions:set -DnewVersion="${NEW_VERSION}-SNAPSHOT" scm:checkin -Dmessage="[skip ci] Preparing for next iteration - version set to ${NEW_VERSION}-SNAPSHOT" -DgenerateBackupPoms=false

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  MavenRelease
fi
