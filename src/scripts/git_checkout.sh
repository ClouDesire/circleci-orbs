#!/usr/bin/env bash

CheckoutRepo() {

  basename=$(basename $REPO_URL)
  REPO_NAME=${basename%.*}
  
  echo "Cloning repo $REPO_URL on branch $REPO_BRANCH"
  git clone $REPO_URL --branch $REPO_BRANCH --single-branch "${REPO_DIR}/${REPO_NAME}"

  if [ $MERGE_MASTER -eq 1 ]; then
    if [ -z $GIT_EMAIL ] || [ -z $GIT_USERNAME ]; then
      echo "ERROR: GIT_EMAIL and GIT_USERNAME environment variable are not set in the context"
      return 1
    fi

    cd "${REPO_DIR}/${REPO_NAME}"
    git config user.email "${GIT_EMAIL}"
    git config user.name "${GIT_USERNAME}"
    
    GIT_BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    set +e
    git checkout "$CIRCLE_BRANCH" && git merge origin/$GIT_BASE_BRANCH
    set -e
    
  fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    CheckoutRepo
fi
