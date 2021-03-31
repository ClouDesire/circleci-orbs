#!/bin/bash

if [ "${CONTAINER_NAME}" == "" ]; then
  CONTAINER_NAME="$CIRCLE_PROJECT_REPONAME"
fi

if [ "${CURL_IMG_VERSION}" == "" ]; then
  CONTAINER_NAME="7.75.0"
fi

echo "Container name: ${CONTAINER_NAME}"
echo "Retries: ${CHECK_RETRIES}"
echo "Sleep time: ${SLEEP_TIME}"
echo "URL: ${CHECK_URL}"

docker run --network "container:${CONTAINER_NAME}" --rm "curlimages/curl:{CURL_IMG_VERSION}" \
  -f \
  --retry ${CHECK_RETRIES} \
  --retry-delay ${SLEEP_TIME} \
  --max-time 10 \
  --retry-all-errors \
  "${CHECK_URL}"

exit $?
