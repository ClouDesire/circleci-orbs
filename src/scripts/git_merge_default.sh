#!/bin/bash -e
# Make sure that current branch is aligned to master
GitMergeDefault() {
  
  DEFAULT_BRANCH=$(curl -s -u $GITHUB_TOKEN:x-oauth-basic -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${REPO_PATH%".git"} | jq --raw-output '.default_branch' | tr -d '\n')


  if [ "${CIRCLE_BRANCH}" == "${DEFAULT_BRANCH}" ]; then
    echo "Already on ${CIRCLE_BRANCH}. Merge with default branch (${DEFAULT_BRANCH}) not required. Skipping."
    exit 0
  fi

  REPO_PATH=""
  if [[ "$REPO_URL" == git@github.com* ]]; then
    REPO_PATH=${REPO_URL#"git@github.com:"} # org/repo_name
  fi

  if [[ "$REPO_URL" == https://github.com* ]]; then
    REPO_PATH=${REPO_URL#"https://github.com/"} # org/repo_name
  fi


  

  git clean -dxf
  git fetch origin "${DEFAULT_BRANCH}" 
  git merge --no-edit "origin/${DEFAULT_BRANCH}"; 
  
}


# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  GitMergeDefault
fi
