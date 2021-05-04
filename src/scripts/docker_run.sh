#!/bin/bash

if [ -f "${CONTAINER_ENV_VARS_FILE}" ]; then
  DOCKER_CMD_OPTIONS="$DOCKER_CMD_OPTIONS --env-file ${CONTAINER_ENV_VARS_FILE}"
fi

if [ "${CONTAINER_NAME}" == "" ]; then
  CONTAINER_NAME="$CIRCLE_PROJECT_REPONAME"
fi

if [ "${IMAGE_NAME}" == "" ]; then
  IMAGE_NAME="$CONTAINER_NAME"
fi

echo "Container name: ${CONTAINER_NAME}"
echo "Container port range: ${CONTAINER_PORT_RANGE}"
echo "Docker options: ${DOCKER_CMD_OPTIONS}"
echo "Image ref: ${IMAGE_NAME}:${IMAGE_VERSION}"

docker run -d --name "${CONTAINER_NAME}" -p "${CONTAINER_PORT_RANGE}" ${DOCKER_CMD_OPTIONS} "${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION}"
