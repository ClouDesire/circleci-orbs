#!/bin/bash -e
# Make sure that current branch is aligned to master
GitMergeMaster() {
  
  REPO_URL="${CIRCLE_REPOSITORY_URL}"
  DEFAULT_BRANCH=""

  git config user.email "${GIT_EMAIL}"
  git config user.name "${GIT_USERNAME}"

  if [[ "$REPO_URL" == git@github.com* ]]; then
    REPO_URL=${REPO_URL#"git@github.com:"}
    REPO_URL="https://$GITHUB_TOKEN:x-oauth-basic@github.com/${REPO_URL}"
  fi

  if git ls-remote -h $REPO_URL | grep -q "refs/heads/master"; then
    DEFAULT_BRANCH="master"
  elif git ls-remote -h $REPO_URL | grep -q "refs/heads/main"; then
    DEFAULT_BRANCH="main"
  else
    echo "ERROR: impossible to find a remote branch that it is either master or main"
    return 1
  fi

  if [ "${DEFAULT_BRANCH}" != "${CIRCLE_BRANCH}" ]; then
    git clean -dxf
    git fetch origin "${DEFAULT_BRANCH}" 
    git merge --no-edit origin/"${DEFAULT_BRANCH}"; 
  fi
}


# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  GitMergeMaster
fi
