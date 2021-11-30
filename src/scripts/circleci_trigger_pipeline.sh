#!/bin/bash -e
# PROJECT_NAME must be set
# BRANCH can be set to build a specific branch
# PARAMETERS: list of key-value pairs to pass as parameters
if [ -z "${PROJECT_NAME}" ]; then
  echo "ERROR: PROJECT_NAME must be set"
  exit 1
fi

if [ -z "${ORG}" ]; then
  echo "ERROR: ORG must be set"
  exit 1
fi

if [ -z "$BRANCH" ] || [ "${BRANCH}" == "" ]; then
  REPO_URL="git@github.com:${ORG}/${PROJECT_NAME}.git"
  if git ls-remote -h "$REPO_URL" | grep -q "${CIRCLE_BRANCH}"; then
    BRANCH="${CIRCLE_BRANCH}"
  elif git ls-remote -h "$REPO_URL" | grep -q "refs/heads/main"; then
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

PIPELINE_API_URL="https://circleci.com/api/v2/project/gh/${ORG}/${PROJECT_NAME}/pipeline"
CIRCLE_RESPONSE_OUTPUT_PATH="circleci_trigger_response_${PROJECT_NAME}.json"

echo "Trigger info: "
echo ">> Org: ${ORG}"
echo ">> Project: ${PROJECT_NAME}"
echo ">> Branch: ${BRANCH}"
echo ">> Parameters: ${PARAMETERS}"
echo ">> Url: ${PIPELINE_API_URL}"
echo -e "\n"

curl \
  --header "Content-Type: application/json" \
  --header "Circle-Token: ${CIRCLECI_TOKEN}" \
  --data "${json_data}" \
  --request POST \
  "${PIPELINE_API_URL}" -o "${CIRCLE_RESPONSE_OUTPUT_PATH}"

cat "${CIRCLE_RESPONSE_OUTPUT_PATH}"
PIPELINE_NUMBER=$(jq --raw-output '.number // empty' "${CIRCLE_RESPONSE_OUTPUT_PATH}")

if [ -z "${PIPELINE_NUMBER}" ]; then
  echo -e "\nSomething went wrong triggering ${PROJECT_NAME} pipeline"
  exit 1
else
  echo -e "\nTriggered ${PROJECT_NAME} pipeline ${PIPELINE_NUMBER}"
fi
