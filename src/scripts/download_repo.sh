#!/usr/bin/env bash

DownloadRepo() {
  echo "Cloning branch $REPO_BRANCH"
  git clone -b $REPO_BRANCH git@github.com:${REPO_ORG}/${REPO_NAME}.git ${REPO_DIR}/${REPO_NAME}
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    DownloadRepo
fi
