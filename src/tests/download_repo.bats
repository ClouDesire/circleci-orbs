# Runs prior to every test
setup() {
  # Load our script file.
  source ./src/scripts/download_repo.sh
}

function teardown() {
  rm -rf ${REPO_DIR}/${REPO_NAME}
}


@test '1: Download Repo' {
    export REPO_URL="git@github.com:ClouDesire/ci-conf.git"
    export REPO_BRANCH="master"
    export REPO_DIR="/tmp"

    DownloadRepo
    [ $(cd "${REPO_DIR}/${REPO_NAME}" && git branch --show-current) == "${REPO_BRANCH}" ]
}