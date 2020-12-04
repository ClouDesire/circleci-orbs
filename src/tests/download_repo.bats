# Runs prior to every test
setup() {
  # Load our script file.
  source ./src/scripts/download_repo.sh
}

function teardown() {
  rm -rf ${REPO_DIR}/${REPO_NAME}
}


@test '1: Download Repo' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    export REPO_NAME="circleci-orbs"
    export REPO_BRANCH="master"
    export REPO_DIR="/tmp"
    # Capture the output of our "Greet" function
    DownloadRepo
    [ $(cd "${REPO_DIR}/${REPO_NAME}" && git branch --show-current) == "${REPO_BRANCH}" ]
}