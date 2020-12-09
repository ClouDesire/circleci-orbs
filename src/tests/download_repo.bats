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


@test '1: CheckoutRepo fails without GIT_USERNAME and GIT_EMAIL set' {
  export REPO_URL="git@github.com:ClouDesire/ci-conf.git"
  export REPO_BRANCH="master"
  export REPO_DIR="/tmp/bats_tests/"
  export MERGE_MASTER=1
  run CheckoutRepo
  [ "$status" -eq 1 ]
}

@test '2: Download Repo' {
    export REPO_URL="git@github.com:ClouDesire/ci-conf.git"
    export REPO_BRANCH="master"
    export REPO_DIR="/tmp/bats_tests/"
    export GIT_EMAIL="circleci@cloudesire.com"
    export GIT_USERNAME="circleci"

    CheckoutRepo
    [ $(cd "${REPO_DIR}/${REPO_NAME}" && git branch --show-current) == "${REPO_BRANCH}" ]
}