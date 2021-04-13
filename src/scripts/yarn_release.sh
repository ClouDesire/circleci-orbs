#!/bin/bash

YarnRelease() {
  
  cd "$PROJECT_DIR"

  echo "Releasing $RELEASE_VERSION"
  echo "//$NPM_REGISTRY/:_authToken=$NPM_TOKEN" > "${HOME}/.npmrc"
  npm publish --registry $NPM_REGISTRY
  git tag "${RELEASE_VERSION}"

  IFS='.' read -a semver <<< "$RELEASE_VERSION"
  NEW_VERSION="${semver[0]}.${semver[1]}.$((${semver[2]} + 1))"
  NEW_VERSION="${RELEASE_VERSION}-beta"
  
  yarn config set version-git-tag false
  yarn config set version-commit-hooks false

  echo "Updating package.json version to ${NEW_VERSION}"
  yarn version --new-version "${NEW_VERSION}"

  find ./ -name package.json -exec git add {} \;
  git commit -m "Preparing for next iteration - version set to ${NEW_VERSION}"
  
  git push --set-upstream origin "${CIRCLE_BRANCH}" --tags

}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
  YarnRelease
fi
