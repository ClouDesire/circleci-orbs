#!/usr/bin/env bash

DownloadRepo() {
  echo "Cloning repo $REPO_URL on branch $REPO_BRANCH"
  basename=$(basename $REPO_URL)
  REPO_NAME=${basename%.*}
  git clone $REPO_URL --branch $REPO_BRANCH --single-branch "${REPO_DIR}/${REPO_NAME}"
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    DownloadRepo
fi
