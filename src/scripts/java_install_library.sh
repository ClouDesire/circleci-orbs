#!/bin/bash -ex
if [ "master" != "$CIRCLE_BRANCH" ]; then
  
  basename=$(basename $REPO_URL)
  REPO_NAME=${basename%.*}

  cd ${REPO_DIR}/${REPO_NAME}
  git branch
  ${MAVEN_PATH} ${MAVEN_COMMAND} ${MAVEN_OPTS}

fi;
