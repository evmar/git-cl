#!/bin/bash

. ./test-lib.sh

setup_initsvn
setup_gitsvn

(
  cd git-svn
  git checkout -q -b work
  echo "some work done on a branch" >> test
  git add test; git commit -q -m "branch work"
  echo "some other work done on a branch" >> test
  git add test; git commit -q -m "branch work"

  test_expect_success "git-cl status has no issue" \
    "$GIT_CL status | grep -q 'No issue'"

  test_expect_success "git-cl upload wants a server" \
    "$GIT_CL upload 2>&1 | grep -q 'set your server'"

  git config rietveld.server localhost:8080

  test_expect_success "upload succeeds" \
    "$GIT_CL upload -m test master... | grep -q 'Issue created'"

  test_expect_success "git-cl status now knows the issue" \
    "$GIT_CL status | grep -q 'Issue number'"

  # Push a description to this URL.
  URL=$($GIT_CL status | sed -ne '/Issue number/s/[^(]*(\(.*\))/\1/p')
  curl --cookie dev_appserver_login="test@example.com:False" \
       --data-urlencode subject="test" \
       --data-urlencode description="foo-quux" \
       $URL/edit

  test_expect_success "git-cl dcommits ok" \
    "$GIT_CL dcommit"

  git checkout -q master
  git svn -q rebase >/dev/null 2>&1
  test_expect_success "dcommitted code has proper description" \
    "git show | grep -q 'foo-quux'"
)

cleanup
