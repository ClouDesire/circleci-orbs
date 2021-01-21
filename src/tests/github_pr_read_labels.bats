#!/usr/bin/env bats
# Runs prior to every test
setup() {
  # Load our script file.
  source ./src/scripts/github_pr_read_labels.sh
}


@test 'ReadPRLabels exports labels correctly' {
  export CIRCLE_PROJECT_USERNAME="ClouDesire"
  export CIRCLE_PROJECT_REPONAME="circleci-orbs"
  export CIRCLE_PULL_REQUEST="https://github.com/ClouDesire/circleci-orbs/pull/55"
  export BASH_ENV="/tmp/bash_env.sh"
  ReadPRLabels
  [[ "${GITHUB_PR_LABELS}" == *"test-label"* ]]
}

