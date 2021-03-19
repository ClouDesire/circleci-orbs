#!/bin/bash

if [ "${CONTAINER_NAME}" == "" ]; then
  CONTAINER_NAME="$CIRCLE_PROJECT_REPONAME"
fi
RETRIES="30"

docker run --network "container:${CONTAINER_NAME}" --rm curlimages/curl:7.75.0 --retry "${RETRIES}" --retry-all-errors "${CHECK_URL}"

#if [ "${EXECUTOR_IS_DOCKER}" == "true" ]; then
#else
#  for i in $(seq 1 ${RETRIES}); do
#    if [ $i -gt 1 ] && sleep ${SLEEP_TIME}; then
#      curl -sSf "${CHECK_URL}" && s=0 && break || s=$?;
#    fi
#  done;
#  exit $s
#fi
