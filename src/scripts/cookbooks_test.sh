#!/bin/bash -e

if [ "$PARAM_KITCHEN_CONCURRENCY" -le "-1" ]; then
  export KITCHEN_CONCURRENCY="-c"
elif [ "$PARAM_KITCHEN_CONCURRENCY" -eq "0" ]; then
  export KITCHEN_CONCURRENCY=""
else
  export KITCHEN_CONCURRENCY="--concurrency=$PARAM_KITCHEN_CONCURRENCY"
fi

if [ -z $CONVERGE_NUMBER ]; then
  CONVERGE_NUMBER=1
fi

source "${BASH_ENV}"

echo "Install kitchen-openstack"
chef gem install kitchen-openstack

echo "Install kitchen-transport-speedy"
chef gem install kitchen-transport-speedy


LOCAL_SCRIPT='test-local.sh'
# If local override is present, execute it
if [ -x $LOCAL_SCRIPT ]; then
  echo "Executing kitchen from test-local.sh"
  ./$LOCAL_SCRIPT $PARAM_KITCHEN_SUITES $PARAM_KITCHEN_CONCURRENCY
else

  echo ">> Kitchen Concurrency => $PARAM_KITCHEN_CONCURRENCY"
  echo ">> Kitchen Suites => $PARAM_KITCHEN_SUITES"
  echo ">> Kitchen Suites to repeat: $PARAM_KITCHEN_REPEAT_SUITES"
  export KERNEL_UPGRADE_ACTION="reboot"
  echo ">> KERNEL_UPGRADE_ACTION => ${KERNEL_UPGRADE_ACTION}"
  chef exec kitchen converge "($PARAM_KITCHEN_SUITES)" $KITCHEN_CONCURRENCY

  if [ ! -z $PARAM_KITCHEN_REPEAT_SUITES ]; then
    PARAM_KITCHEN_REPEAT_SUITES="$(echo -e "${PARAM_KITCHEN_REPEAT_SUITES}" | tr -d '[:space:]')"

    echo "Repeat converge for ${PARAM_KITCHEN_REPEAT_SUITES}"

    PARAM_KITCHEN_REPEAT_SUITES=${PARAM_KITCHEN_REPEAT_SUITES//,/|}
    chef exec kitchen converge "($PARAM_KITCHEN_REPEAT_SUITES)"
  fi

  # https://github.com/inspec/kitchen-inspec/issues/167
  chef exec kitchen verify "($PARAM_KITCHEN_SUITES)"
fi

exit 0
