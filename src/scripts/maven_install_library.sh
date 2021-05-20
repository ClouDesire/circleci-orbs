#!/bin/bash -ex

basename=$(basename $REPO_URL)
REPO_NAME=${basename%.*}

STOP_COMMAND="${REPO_NAME}_STOP_COMMAND"
STOP_COMMAND_REASON="${REPO_NAME}_STOP_COMMAND_REASON"
if [ "${!STOP_COMMAND}" == "true" ]; then
  echo "${!STOP_COMMAND_REASON}"
  exit 0
fi

echo "Installing library '${REPO_NAME}' from folder ${REPO_DIR}/${REPO_NAME}"
echo "Maven path: ${MAVEN_PATH}"
echo "Maven command: ${MAVEN_COMMAND}"
echo "Maven options: ${MAVEN_CMD_OPTS}"

cd "${REPO_DIR}/${REPO_NAME}"
${MAVEN_PATH} ${MAVEN_COMMAND} ${MAVEN_CMD_OPTS}
