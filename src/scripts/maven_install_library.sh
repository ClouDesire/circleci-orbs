#!/bin/bash -ex
basename=$(basename $REPO_URL)
REPO_NAME=${basename%.*}
cd ${REPO_DIR}/${REPO_NAME}
${MAVEN_PATH} ${MAVEN_COMMAND} ${MAVEN_OPTS}

