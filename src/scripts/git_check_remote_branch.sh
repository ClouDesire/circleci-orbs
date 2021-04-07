#!/bin/bash

if [[ "$REPO_URL" == git@github.com* ]]; then
  REPO_URL=${REPO_URL#"git@github.com:"}
  REPO_URL="https://$GITHUB_TOKEN:x-oauth-basic@github.com/${REPO_URL}"
fi


if git ls-remote -h $REPO_URL | grep -q "refs/heads/${CIRCLE_BRANCH}"; then
  REMOTE_BRANCH_EXISTS="true"
else
  REMOTE_BRANCH_EXISTS="false"  
fi

echo "export REMOTE_BRANCH_EXISTS=${REMOTE_BRANCH_EXISTS}" >> "${BASH_ENV}"
echo "export REMOTE_BRANCH_EXISTS=${REMOTE_BRANCH_EXISTS}" >> "${HOME}/globals.sh"
