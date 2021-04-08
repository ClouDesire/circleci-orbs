#!/bin/bash

CheckoutRepo() {

  if [[ "$REPO_URL" == git@github.com* ]]; then
    REPO_URL=${REPO_URL#"git@github.com:"}
    REPO_URL="https://$GITHUB_TOKEN:x-oauth-basic@github.com/${REPO_URL}"
  fi
  
  basename=$(basename $REPO_URL)
  REPO_NAME=${basename%.*}

  
  if [ -z $REPO_BRANCH ]; then
    if git ls-remote -h $REPO_URL | grep -q "refs/heads/${CIRCLE_BRANCH}"; then
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

  if [ -z $REPO_DIR ]; then
    REPO_DIR="${HOME}"
  else
    mkdir -p "${REPO_DIR}"
  fi


  echo ">> Cloning repo: "
  echo "  >> Name: ${REPO_NAME}"
  echo "  >> Url: ${REPO_URL}"
  echo "  >> Branch: ${REPO_BRANCH}"
  echo "  >> Base dir: ${REPO_DIR}"

  cd "${REPO_DIR}"
  git clone $REPO_URL --branch $REPO_BRANCH "${REPO_NAME}"

  TMP_REPO_NAME="${REPO_NAME//-/_}"
  TMP_REPO_NAME=$(echo ${TMP_REPO_NAME} | tr '[:lower:]' '[:upper:]')
  echo "Adding GIT_${TMP_REPO_NAME}_DIR='${REPO_DIR}/${REPO_NAME}' to bash env"
  
  echo "echo IMPORTANT: usage of this file is deprecated. Please use globals.sh instead!" >> "${HOME}/cloudesire.env"
  echo "export GIT_${TMP_REPO_NAME}_DIR='${REPO_DIR}/${REPO_NAME}'" >> "${HOME}/cloudesire.env"
  
  echo "export GIT_${TMP_REPO_NAME}_DIR='${REPO_DIR}/${REPO_NAME}'" >> "${HOME}/globals.sh"
  echo "export GIT_${TMP_REPO_NAME}_DIR='${REPO_DIR}/${REPO_NAME}'" >> "${BASH_ENV}"
  source "${BASH_ENV}"


  if [ $MERGE_MASTER -eq 1 ] || [ ! -z $MERGE_MASTER ]; then
    if [ -z $GIT_EMAIL ] || [ -z $GIT_USERNAME ]; then
      echo "ERROR: GIT_EMAIL and GIT_USERNAME environment variables are not set in the context and they are required when merge master is enabled"
      return 1
    fi

    cd "${REPO_DIR}/${REPO_NAME}"
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
