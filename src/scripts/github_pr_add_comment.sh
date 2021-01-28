#!/bin/bash

if [[ "${CIRCLE_BRANCH}" == "master" ]] || [[ "${CIRCLE_BRANCH}" == "main" ]]; then
  echo "Not in a PR branch. Exiting..."
  exit 0
fi

pr_comment_url=$(curl -s --location --request GET "https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/${CIRCLE_PULL_REQUEST##*/}" --header "Authorization: token ${GITHUB_TOKEN}" | jq -r "._links.comments.href")

echo ">> PR url: ${pr_comment_url}"
echo ">> Comment: $(eval echo ${PR_COMMENT})"
curl --location --request POST "$pr_comment_url" \
--header "Authorization: token ${GITHUB_TOKEN}" \
--data-raw "{\"body\": \"$(eval echo ${PR_COMMENT})\"}"
