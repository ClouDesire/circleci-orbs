#!/bin/bash -ex
# required for automerge
git config --global user.email "circleci@cloudesire.com"
git config --global user.name "CircleCI"

if [ "master" != "$CIRCLE_BRANCH" ]; then
  
  basename=$(basename $REPO_URL)
  REPO_NAME=${basename%.*}

  cd ${REPO_DIR}/${REPO_NAME}
  set +e
  git checkout "$CIRCLE_BRANCH" && git merge origin/master
  set -e
  git branch
  ./mvnw clean install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true
fi;