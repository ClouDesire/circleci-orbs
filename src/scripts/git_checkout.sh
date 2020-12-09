#!/usr/bin/env bash

CheckoutRepo() {

  if [ -z $GIT_EMAIL ] || [ -z $GIT_USERNAME ]; then
    echo "ERROR: GIT_EMAIL and GIT_USERNAME environment variable are not set in the context"
    return 1
  fi

  git config --global user.email "${GIT_EMAIL}"
  git config --global user.name "${GIT_USERNAME}"

  basename=$(basename $REPO_URL)
  REPO_NAME=${basename%.*}
  
  echo "Cloning repo $REPO_URL on branch $REPO_BRANCH"
  git clone $REPO_URL --branch $REPO_BRANCH --single-branch "${REPO_DIR}/${REPO_NAME}"

  if [ $MERGE_MASTER -eq 1 ]; then
    set +e
    git checkout "$CIRCLE_BRANCH" && git merge origin/master
    set -e
  fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    CheckoutRepo
fi
