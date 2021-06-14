#!/bin/bash

CheckoutRepo() {


  REPO_PATH=""
  if [[ "$REPO_URL" == git@github.com* ]]; then
    REPO_PATH=${REPO_URL#"git@github.com:"} # org/repo_name
  fi

  if [[ "$REPO_URL" == https://github.com* ]]; then
    REPO_PATH=${REPO_URL#"https://github.com/"} # org/repo_name
  fi

  REPO_URL="https://$GITHUB_TOKEN:x-oauth-basic@github.com/${REPO_PATH}"

  basename=$(basename $REPO_URL)
  REPO_NAME=${basename%.*}
  
  TMP_REPO_NAME="${REPO_NAME//-/_}"
  TMP_REPO_NAME=$(echo ${TMP_REPO_NAME} | tr '[:lower:]' '[:upper:]')

  STOP_COMMAND="${TMP_REPO_NAME}_STOP_COMMAND"
  STOP_COMMAND_REASON="${TMP_REPO_NAME}_STOP_COMMAND_REASON"
  if [ "${!STOP_COMMAND}" == "true" ]; then
    echo "${!STOP_COMMAND_REASON}"
    exit 0
  fi
  
  REPO_DEFAULT_BRANCH=$(curl -s -u $GITHUB_TOKEN:x-oauth-basic -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${REPO_PATH%".git"} | jq --raw-output '.default_branch' | tr -d '\n')

  if [ -z "$REPO_BRANCH" ]; then
    if git ls-remote -h "$REPO_URL" | grep -q "refs/heads/${CIRCLE_BRANCH}"; then
      REPO_BRANCH="${CIRCLE_BRANCH}"
    else
      REPO_BRANCH=$REPO_DEFAULT_BRANCH
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
  git clone "$REPO_URL" --branch "$REPO_BRANCH" "${REPO_NAME}"

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
    set +e
    git fetch origin "${DEFAULT_BRANCH}" 
    git merge --no-edit "origin/${DEFAULT_BRANCH}";
    set -e
  fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  CheckoutRepo
fi
