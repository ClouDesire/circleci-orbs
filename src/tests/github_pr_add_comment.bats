#!/usr/bin/env bats
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

@test 'AddPRComment exit on branch master' {
  export CIRCLE_TAG="0.1.0"
  
  run AddPRComment
  [ "$status" -eq 0 ]
  [ "$output" = "Not in a PR branch. Exiting..." ]
}


@test 'AddPRComment exit on branch main' {
  export CIRCLE_BRANCH="main"
  
  run AddPRComment
  [ "$status" -eq 0 ]
  [ "$output" = "Not in a PR branch. Exiting..." ]
}

