#!/bin/bash

AddPRComment() {
  if [ "${CIRCLE_BRANCH}" == "master" ] || [ "${CIRCLE_BRANCH}" == "main" ]; then
    echo "Not in a PR branch. Exiting..."
    exit 0
  fi

  pr_comment_url=$(curl -s --location --request GET "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/${CIRCLE_PULL_REQUEST##*/}" --header "Authorization: token ${GITHUB_TOKEN}" | jq -r "._links.comments.href")

  echo ">> PR url: ${pr_comment_url}"
  
  PR_COMMENT=$(eval echo "${PR_COMMENT}")

  if [ -n "$PR_COMMENT_FILE_PATH" ]; then
    file=$(eval echo $PR_COMMENT_FILE_PATH)
    
    sed -i '$! s/$/\\n/' "${file}"
    tr -d '\n' < "${file}" > tmpfile
    
    mv -f tmpfile "${file}"
    
    sed -i 's/\"/\\\"/g' "${file}"
    
    PR_COMMENT="${PR_COMMENT}\n$(cat ${file})"
    echo -e ">> Comment: \n ${PR_COMMENT}"
  fi

  
  echo -nE "{\"body\":\"${PR_COMMENT}\"}" > request_body.json
  
  curl --location --request POST "$pr_comment_url" \
  --header "Authorization: token ${GITHUB_TOKEN}" \
  --header 'Content-Type: text/json' \
  -d @request_body.json
}


# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  AddPRComment
fi
