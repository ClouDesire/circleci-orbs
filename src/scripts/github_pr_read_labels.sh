#!/bin/bash
ReadPRLabels() {

  if [ "${CIRCLE_BRANCH}" == "master" ] || [ "${CIRCLE_BRANCH}" == "main" ]; then
    echo "Not in a PR branch. Exiting..."
    exit 0
  fi

  echo ">> Org: ${CIRCLE_PROJECT_USERNAME}"
  echo ">> Repo: ${CIRCLE_PROJECT_REPONAME}"
  echo ">> PR Link: ${CIRCLE_PULL_REQUEST}"
  echo ">> PR #: ${CIRCLE_PULL_REQUEST##*/}"
  echo "\n"
  labels=$(curl -s --location --request GET "https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/pulls/${CIRCLE_PULL_REQUEST##*/}" --header "Authorization: token ${GITHUB_TOKEN}" | jq -r 'select(.labels != null) | .labels | map(.name) | join(",")')

  if [ "${labels}" == "" ]; then
    echo "PR ${CIRCLE_PULL_REQUEST} does not have labels."
    exit 0
  else
    echo ">> Labels: ${labels}"
    IFS=',' read -a labels_array <<< "$labels"
    for label in "${labels_array[@]}"; do
      label=${label//-/_}
      label=$(echo ${label} | tr '[:lower:]' '[:upper:]')
      echo "  >> Adding GH_PR_LABEL_${label} to BASH_ENV"
      echo "export GH_PR_LABEL_${label}=true" >> "${BASH_ENV}"
    done
    source "${BASH_ENV}"
  fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    ReadPRLabels
fi

