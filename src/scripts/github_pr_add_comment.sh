#!/bin/bash

AddPRComment() {
  if [ "${CIRCLE_BRANCH}" == "master" ] || [ "${CIRCLE_BRANCH}" == "main" ]; then
    echo "Not in a PR branch. Exiting..."
    exit 0
  fi

  pr_comment_url=$(curl -s --location --request GET "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/${CIRCLE_PULL_REQUEST##*/}" --header "Authorization: token ${GITHUB_TOKEN}" | jq -r "._links.comments.href")

  echo ">> PR url: ${pr_comment_url}"

  if [ -n "$PR_COMMENT_FILE_PATH" ]; then
    PR_COMMENT=$(eval cat "${PR_COMMENT_FILE_PATH}")
    echo -e ">> Comment: \n ${PR_COMMENT}"
  else 
    PR_COMMENT=$(eval echo "${PR_COMMENT}")
    echo ">> Comment: $PR_COMMENT"
  fi

  
  curl --location --request POST "$pr_comment_url" \
  --header "Authorization: token ${GITHUB_TOKEN}" \
  --data-raw "{\"body\": '$PR_COMMENT'}"
}


# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  AddPRComment
fi
