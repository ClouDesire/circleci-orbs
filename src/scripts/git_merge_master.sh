#!/bin/bash -e
# Make sure that current branch is aligned to master

git clean -dxf
git config --global user.email "circleci@cloudesire.com" && git config --global user.name "CircleCI"
if [ "master" != $CIRCLE_BRANCH ]; then git fetch origin master && git merge --no-edit origin/master; fi
