#!/bin/bash

for i in $(seq 1 30); do
  if [ $i -gt 1 ] && sleep ${SLEEP_TIME}; then
    curl -sSf "${CHECK_URL}" && s=0 && break || s=$?;
  fi
done;
exit $s