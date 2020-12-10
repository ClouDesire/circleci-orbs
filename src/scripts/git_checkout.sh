#!/bin/bash

CheckoutRepo() {
 
  
  if [ -z $REPO_BRANCH ]; then
    if git ls-remote -h $REPO_URL | grep -q "${CIRCLE_BRANCH}"; then
      REPO_BRANCH="${CIRCLE_BRANCH}"
    elif git ls-remote -h $REPO_URL | grep -q "refs/heads/master"; then
        REPO_BRANCH="master"
        MERGE_MASTER=0
    elif git ls-remote -h $REPO_URL | grep -q "refs/heads/main"; then
          REPO_BRANCH="main"
          MERGE_MASTER=0
    else
      echo "ERROR: impossible to find a remote branch that it is either CIRCLE_BRANCH, master or main"
      return 1
    fi
  fi

  echo "Cloning repo $REPO_URL on branch $REPO_BRANCH"
  git clone $REPO_URL --branch $REPO_BRANCH --single-branch "${REPO_DIR}/${REPO_NAME}"


  if [ $MERGE_MASTER -eq 1 ] || [ ! -z $MERGE_MASTER ]; then
    if [ -z $GIT_EMAIL ] || [ -z $GIT_USERNAME ]; then
      echo "ERROR: GIT_EMAIL and GIT_USERNAME environment variables are not set in the context and they are required when merge master is enabled"
      return 1
    fi

    cd "${REPO_DIR}/${REPO_NAME}"
    git config user.email "${GIT_EMAIL}"
    git config user.name "${GIT_USERNAME}"
    
    GIT_DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
    set +e
    git checkout "$REPO_BRANCH" && git merge origin/$GIT_DEFAULT_BRANCH
    set -e
  fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    CheckoutRepo
fi
