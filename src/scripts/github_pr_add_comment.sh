#!/bin/bash

pr_comment_url=$(curl -s --location --request GET "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/${CIRCLE_PULL_REQUEST##*/}" --header "Authorization: token ${GITHUB_TOKEN}" | jq -r "._links.comments.href")

echo ">> PR url: ${pr_comment_url}"

curl --location --request POST "$pr_comment_url" \
--header 'Authorization: token ${GITHUB_TOKEN}' \
--data-raw "{\"body\": \"$(eval echo ${PR_COMMENT})\"}"
