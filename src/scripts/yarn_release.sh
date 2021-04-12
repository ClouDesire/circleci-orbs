#!/bin/bash

YarnRelease() {
  
  cd "$PROJECT_DIR"

  echo "Releasing $RELEASE_VERSION"
  yarn publish
  
  yarn config set version-git-tag false
  yarn config set version-commit-hooks false

  echo "Updating package.json version to ${NEW_VERSION}-beta"
  yarn version --new-version "${NEW_VERSION}-beta"

  find ./ -name package.json -exec git add {} \;
  git commit -m "Preparing for next iteration - version set to ${NEW_VERSION}-beta"
  
  git push --set-upstream origin "${CIRCLE_BRANCH}" --tags

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  YarnRelease
fi
