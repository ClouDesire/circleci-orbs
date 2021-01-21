#!/bin/bash
ReadPRLabels() {

  echo ">> Org: ${CIRCLE_PROJECT_USERNAME}"
  echo ">> Repo: ${CIRCLE_PROJECT_REPONAME}"
  echo ">> PR: ${CIRCLE_PULL_REQUEST##*/}"
  labels=$(curl -s --location --request GET "https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/issues/${CIRCLE_PULL_REQUEST##*/}" --header "Authorization: token ${GITHUB_TOKEN}" | jq -r 'select(.labels != null) | .labels | map(.name) | join(",")')

  echo ">> Labels: ${labels}"
  echo "export GITHUB_PR_LABELS='${labels}'" >> "$BASH_ENV"
  source "${BASH_ENV}"
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    ReadPRLabels
fi