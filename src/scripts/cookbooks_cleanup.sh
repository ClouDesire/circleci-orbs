#!/bin/bash -e

if [ "$PARAM_KITCHEN_CONCURRENCY" == "true" ]; then
  export KITCHEN_CONCURRENCY="-c"
else
  export KITCHEN_CONCURRENCY=""
fi
source "${BASH_ENV}"
retry -- chef exec kitchen destroy "($PARAM_KITCHEN_SUITES)" $KITCHEN_CONCURRENCY
