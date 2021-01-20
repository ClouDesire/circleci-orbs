#!/bin/bash

labels=$(curl -s --location --request GET 'https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${$CIRCLE_PROJECT_REPONAME}/pulls/${PR_NUMBER}' --header 'Authorization: Bearer ${GITHUB_TOKEN}' | jq -r '.labels | map(.name) | join(",")')
echo 'export GITHUB_PR_LABELS=${labels}' >> $BASH_ENV
source $BASH_ENV
