#!/bin/bash -e

if [ "$PARAM_KITCHEN_CONCURRENCY" -le "-1" ]; then
  export KITCHEN_CONCURRENCY="-c"
elif [ "$PARAM_KITCHEN_CONCURRENCY" -eq "0" ]; then
  export KITCHEN_CONCURRENCY=""
else
  export KITCHEN_CONCURRENCY="--concurrency=$PARAM_KITCHEN_CONCURRENCY"
fi
source "${BASH_ENV}"
retry -- chef exec kitchen destroy "($PARAM_KITCHEN_SUITES)" $KITCHEN_CONCURRENCY
