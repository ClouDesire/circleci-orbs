#!/bin/bash -ex

if [ "${STOP_COMMAND}" == "true" ]; then
  echo $STOP_COMMAND_REASON
  exit 0
fi

basename=$(basename $REPO_URL)
REPO_NAME=${basename%.*}

echo "Installing library '${REPO_NAME}' from folder ${REPO_DIR}/${REPO_NAME}"
echo "Maven path: ${MAVEN_PATH}"
echo "Maven command: ${MAVEN_COMMAND}"
echo "Maven options: ${MAVEN_CMD_OPTS}"

cd "${REPO_DIR}/${REPO_NAME}"
${MAVEN_PATH} ${MAVEN_COMMAND} ${MAVEN_CMD_OPTS}
