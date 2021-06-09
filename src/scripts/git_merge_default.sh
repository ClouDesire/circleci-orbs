#!/bin/bash -e
# Make sure that current branch is aligned to master
GitMergeMaster() {
  
  if [ "${CIRCLE_BRANCH}" == "master" ] || [ "${CIRCLE_BRANCH}" == "main" ]; then
    echo "Already on ${CIRCLE_BRANCH}. Merge with default branch not required. Skipping."
    exit 0
  fi


  REPO_URL="${CIRCLE_REPOSITORY_URL}"
  DEFAULT_BRANCH=""
  basename=$(basename $REPO_URL)
  REPO_NAME=${basename%.*}
 

  DEFAULT_BRANCH=$(curl -u $GITHUB_TOKEN:x-oauth-basic -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ClouDesire/${REPO_NAME} | jq --raw-output '.default_branch')

  git clean -dxf
  git fetch origin "${DEFAULT_BRANCH}" 
  git merge --no-edit "origin/${DEFAULT_BRANCH}"; 
  
}


# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  GitMergeMaster
fi
