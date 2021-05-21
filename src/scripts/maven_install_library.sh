#!/bin/bash -ex

basename=$(basename $REPO_URL)
REPO_NAME=${basename%.*}
TMP_REPO_NAME="${REPO_NAME//-/_}"
TMP_REPO_NAME=$(echo ${TMP_REPO_NAME} | tr '[:lower:]' '[:upper:]')

STOP_COMMAND="${TMP_REPO_NAME}_STOP_COMMAND"
STOP_COMMAND_REASON="${TMP_REPO_NAME}_STOP_COMMAND_REASON"
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
