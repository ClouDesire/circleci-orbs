#!/bin/bash
# Runs prior to every test
setup() {
  # Load our script file.
  source ./src/scripts/github_pr_add_comment.sh
}

function teardown() {
  if [ -f "${BASH_ENV}" ]; then
    rm -f "${BASH_ENV}"
  fi
}

@test 'ReadPRLabels exit on branch master' {
  export CIRCLE_BRANCH="master"
  
  run AddPRComment
  [ "$status" -eq 0 ]
  [ "$output" = "Not in a PR branch. Exiting..." ]
}


@test 'ReadPRLabels exit on branch main' {
  export CIRCLE_BRANCH="main"
  
  run AddPRComment
  [ "$status" -eq 0 ]
  [ "$output" = "Not in a PR branch. Exiting..." ]
}

