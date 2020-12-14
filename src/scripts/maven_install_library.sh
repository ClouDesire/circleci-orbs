#!/bin/bash -ex
basename=$(basename $REPO_URL)
REPO_NAME=${basename%.*}

echo "Installing library '${REPO_NAME}' from folder ${REPO_DIR}/${REPO_NAME}"
cd "${REPO_DIR}/${REPO_NAME}"
${MAVEN_PATH} ${MAVEN_COMMAND} ${MAVEN_OPTS}

