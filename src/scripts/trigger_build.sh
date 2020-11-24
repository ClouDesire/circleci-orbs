
if [ "${CIRCLE_BRANCH}" == "master" ]; then
  PROJECT_NAME=cookbook-cd-appdeploy ./ci-conf/circleci/trigger_build.sh
  PROJECT_NAME=cookbook-cd-nginx     ./ci-conf/circleci/trigger_build.sh
  echo "Triggered master upstream builds"
  exit 0
fi


IFS=';' read -ra projects_array <<< "$PROJECTS"

for i in "${projects_array[@]}"
do
  if [ "${COOKBOOK_BRANCH}" != "master" ]; then
    PROJECT_NAME=$i BRANCH_NAME=${COOKBOOK_BRANCH} ./ci-conf/circleci/trigger_build.sh
    echo "Triggered build of ${i} on branch ${COOKBOOK_BRANCH}"
  fi
done