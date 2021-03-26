#!/bin/bash

if [ "${CONTAINER_NAME}" == "" ]; then
  CONTAINER_NAME="$CIRCLE_PROJECT_REPONAME"
fi

echo "Container name: ${CONTAINER_NAME}"
echo "Retries: ${CHECK_RETRIES}"
echo "Sleep time: ${SLEEP_TIME}"
echo "URL: ${CHECK_URL}"

HTTP_RESPONSE_CODE=$(docker run --network "container:${CONTAINER_NAME}" --rm curlimages/curl:7.75.0 -s -o /dev/null -w "%{http_code}" --retry "${CHECK_RETRIES}" --retry-delay ${SLEEP_TIME} --max-time 10 --retry-all-errors "${CHECK_URL}")

echo "Request response code: ${HTTP_RESPONSE_CODE}"
if [ "${HTTP_RESPONSE_CODE}" != "200" ]; then
  exit 1
fi
