#!/bin/bash

CheckoutRepo() {

  GITHUB_HEADER="Accept: application/vnd.github.v3+json"

  GITHUB_ORG=$(echo $REPO_URL | awk -F : '{print $2}' | awk -F / '{print $1}')
  REPO_NAME=$(echo $REPO_URL | awk -F : '{print $2}' | awk -F / '{print $2}' | awk -F . '{print $1}')
  
  GITHUB_API_URL="https://api.github.com/repos/${GITHUB_ORG}/${REPO_NAME}"

  if [ -z $REPO_BRANCH ]; then
    echo "Checking branch on GitHub"
    REPO_BRANCH=$(curl -sH $GITHUB_HEADER -u "${GITHUB_TOKEN}:x-oauth-basic" "${GITHUB_API_URL}/branches/${CIRCLE_BRANCH}" | jq -r '. | map(select(.name? == "${CIRCLE_BRANCH}"))[0] | .name')
    if [ "${REPO_BRANCH}" == "null" ] || [ -z $REPO_BRANCH ]; then
      echo "Using default branch"
      REPO_BRANCH=$(curl -sH $GITHUB_HEADER -u "${GITHUB_TOKEN}:x-oauth-basic" "${GITHUB_API_URL}" | jq -r ".default_branch")
      echo "DEFAULT_BRANCH = ${REPO_BRANCH}"
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
    
    GIT_DEFAULT_BRANCH=$(curl -sH $GITHUB_HEADER -u "${GITHUB_TOKEN}:x-oauth-basic" "${GITHUB_API_URL}" | jq -r ".default_branch")
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
