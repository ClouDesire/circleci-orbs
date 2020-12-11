#!/bin/bash -e
# PROJECT_NAME must be set
# BRANCH can be set to build a specific branch
# PARAMETERS: list of key-value pairs to pass as parameters
if [ -z "${PROJECT_NAME}" ]; then
  echo "ERROR: PROJECT_NAME must be set"
  exit 1
fi

if [ -z "${ORG}" ];
  echo "ERROR: ORG must be set"
  exit 1
fi

if [ -z $BRANCH ] || [ "${BRANCH}" == "" ]; then
  REPO_URL="git@github.com:${ORG}/${PROJECT_NAME}.git"
  if git ls-remote -h $REPO_URL | grep -q "${CIRCLE_BRANCH}"; then
    BRANCH="${CIRCLE_BRANCH}"
  elif git ls-remote -h $REPO_URL | grep -q "refs/heads/main"; then
    BRANCH="main"
  else
    BRANCH="master"
  fi
fi

if [ -z "${PARAMETERS}" ] || [ "${PARAMETERS}" == "" ]; then
  json_data='{ "branch": "'${BRANCH}'" }'
else
  json_data='{ "parameters": '${PARAMETERS}', "branch": "'${BRANCH}'"}'
fi


curl \
  --header "Content-Type: application/json" \
  --data "${json_data}" \
  --request POST \
  https://circleci.com/api/v2/project/gh/${ORG}/${PROJECT_NAME}/pipeline?circle-token="${CIRCLECI_TOKEN}"