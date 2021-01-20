#!/bin/bash

pr_response=$(curl --location --request GET "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/${CIRCLE_PULL_REQUEST##*/}" \
--header 'Authorization: Bearer ${GITHUB_TOKEN}')

if [ $(echo $pr_response | jq length) -eq 0 ]; then
  echo "No PR found to update"
else
  pr_comment_url=$(echo $pr_response | jq -r "._links.comments.href")
fi

curl --location --request POST "$pr_comment_url" \
--header 'Authorization: Bearer ${GITHUB_TOKEN}' \
--data-raw "{\"body\": \"$(eval echo ${PR_COMMENT})\"}"
