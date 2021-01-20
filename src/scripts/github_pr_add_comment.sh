#!/bin/bash

pr_comment_url=$(curl -s --location --request GET "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/${CIRCLE_PULL_REQUEST##*/}" \
--header 'Authorization: Bearer ${GITHUB_TOKEN}')

echo ">> PR Link: ${pr_comment_url}"

curl --location --request POST "$pr_comment_url" \
--header 'Authorization: Bearer ${GITHUB_TOKEN}' \
--data-raw "{\"body\": \"$(eval echo ${PR_COMMENT})\"}"
