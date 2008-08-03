#!/bin/bash

# Abort on error.
set -e

PWD=`pwd`
REPO_URL=file:///$PWD/svnrepo
GIT_CL=$PWD/../git-cl

# Set up an SVN repo that has a few commits to trunk.
setup_initsvn() {
  rm -rf svnrepo
  svnadmin create svnrepo

  rm -rf svn
  svn co -q $REPO_URL svn
  (
    cd svn
    echo "test" > test
    svn add -q test
    svn commit -q -m "initial commit"
    echo "test2" >> test
    svn commit -q -m "second commit"
  )
}

# Set up an svn checkout of the repo.
reset_svn() {
  rm -rf svn
  svn co -q $REPO_URL svn
}

# Set up a git-svn checkout of the repo.
setup_gitsvn() {
  rm -rf git-svn
  # There appears to be no way to make git-svn completely shut up, so we
  # redirect its output.
  git svn -q clone $REPO_URL git-svn >/dev/null 2>&1
}

cleanup() {
  rm -rf svnrepo svn git-svn
}

# Usage: test_expect_success "description of test" "test code".
test_expect_success() {
  set +e
  eval "$2"
  if [ $? != 0 ]; then
    echo "FAILURE: $1"
  fi
  set -e
}
