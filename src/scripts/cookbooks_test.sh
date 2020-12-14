#!/bin/bash -e
export KITCHEN_LOG_OVERWRITE=false
export PARAM_KITCHEN_SUITES=$1
export PARAM_KITCHEN_CONCURRENCY=$2
export CONVERGE_NUMBER=$3

if [ "$PARAM_KITCHEN_CONCURRENCY" == "false" ]; then
    export KITCHEN_CONCURRENCY=""
else
    export KITCHEN_CONCURRENCY="-c"
fi

if [ -z $CONVERGE_NUMBER ]; then
  CONVERGE_NUMBER=1
fi


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
    export KERNEL_UPGRADE_ACTION="reboot"
    echo ">> KERNEL_UPGRADE_ACTION => ${KERNEL_UPGRADE_ACTION}"
    chef exec kitchen converge "($PARAM_KITCHEN_SUITES)" $KITCHEN_CONCURRENCY
    # https://github.com/inspec/kitchen-inspec/issues/167
    chef exec kitchen verify "($PARAM_KITCHEN_SUITES)"
fi

exit 0
