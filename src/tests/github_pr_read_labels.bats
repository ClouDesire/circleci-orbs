#!/usr/bin/env bats
# Runs prior to every test
setup() {
  # Load our script file.
  source ./src/scripts/github_pr_read_labels.sh
}


@test '1: ReadPRLabels exports labels correctly' {
  export CIRCLE_PROJECT_USERNAME="ClouDesire"
  export CIRCLE_PROJECT_REPONAME="support"
  export PR_NUMBER="4589"
  export BASH_ENV="/tmp/bash_env.sh"
  ReadPRLabels
  [[ "${GITHUB_PR_LABELS}" == *"type/devops"* ]]
}

