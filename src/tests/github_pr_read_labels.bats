#!/usr/bin/env bats
# Runs prior to every test
setup() {
  # Load our script file.
  source ./src/scripts/github_pr_read_labels.sh
}

function teardown() {
  if [ -f "${BASH_ENV}" ]; then
    rm -f "${BASH_ENV}"
  fi
}


@test 'ReadPRLabels exports labels correctly' {
  export CIRCLE_PROJECT_USERNAME="ClouDesire"
  export CIRCLE_PROJECT_REPONAME="circleci-orbs"
  export CIRCLE_PULL_REQUEST="https://github.com/ClouDesire/circleci-orbs/pull/55"
  export BASH_ENV="/tmp/.pipeline_env"
  run ReadPRLabels
  source "${BASH_ENV}"
  [[ $GH_PR_LABEL_TEST_LABEL ]]
}

@test 'ReadPRLabels exit when PR does not have labels' {
  export CIRCLE_PROJECT_USERNAME="ClouDesire"
  export CIRCLE_PROJECT_REPONAME="circleci-orbs"
  export CIRCLE_PULL_REQUEST="https://github.com/ClouDesire/circleci-orbs/pull/56"
  export BASH_ENV="/tmp/.pipeline_env"
  
  run ReadPRLabels
  [ "$status" -eq 0 ]
}



@test 'ReadPRLabels exit on branch master' {
  export CIRCLE_BRANCH="master"
  
  run ReadPRLabels
  [ "$status" -eq 0 ]
  [ "$output" = "Not in a PR branch. Exiting..." ]
}

@test 'ReadPRLabels exit on branch main' {
  export CIRCLE_BRANCH="main"
  
  run ReadPRLabels
  [ "$status" -eq 0 ]
  [ "$output" = "Not in a PR branch. Exiting..." ]
}

