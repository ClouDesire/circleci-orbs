#!/usr/bin/env bats
# Runs prior to every test
setup() {
  # Load our script file.
  source ./src/scripts/git_checkout.sh
}

function teardown() {
  if [ -d "${REPO_DIR}" ]; then
    rm -rf "${REPO_DIR}/${REPO_NAME}"
  fi
}


@test 'CheckoutRepo fails without GIT_USERNAME and GIT_EMAIL set' {
  export REPO_URL="git@github.com:ClouDesire/ci-conf.git"
  export REPO_BRANCH="master"
  export REPO_DIR="/tmp/bats_tests"
  export BASH_ENV="/tmp/.pipeline_env"
  export MERGE_MASTER=1
  unset GIT_USERNAME
  unset GIT_EMAIL
  run CheckoutRepo
  [ "$status" -eq 1 ]
}

@test 'Download repo' {
  export REPO_URL="git@github.com:ClouDesire/ci-conf.git"
  export REPO_DIR="/tmp/bats_tests"
  export GIT_EMAIL="circleci@cloudesire.com"
  export GIT_USERNAME="circleci"
  export BASH_ENV="/tmp/.pipeline_env"
  if [ -z "${CIRCLE_BRANCH}" ]; then 
    export CIRCLE_BRANCH="master"
  fi

  CheckoutRepo
  [ $(cd "${REPO_DIR}/${REPO_NAME}" && git branch --show-current) == "${REPO_BRANCH}" ]
}

@test 'Download repo with custom branch' {
  export REPO_URL="git@github.com:ClouDesire/ci-conf.git"
  export REPO_BRANCH="master"
  export REPO_DIR="/tmp/bats_tests"
  export GIT_EMAIL="circleci@cloudesire.com"
  export GIT_USERNAME="circleci"
  export BASH_ENV="/tmp/.pipeline_env"

  CheckoutRepo
  [ $(cd "${REPO_DIR}/${REPO_NAME}" && git branch --show-current) == "${REPO_BRANCH}" ]
}
