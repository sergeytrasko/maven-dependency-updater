#!/bin/sh

# Variables
OWNER=ctco
REPO=cukes
TMPDIR=/tmp/$OWNER-$REPO

# Functions
function cleanup {
    echo Performing clean-up...
#    rm -rf $TMPDIR
}

function cloneRepo {
    echo Cloning repository...
    mkdir $TMPDIR
    cd $TMPDIR
    git clone https://github.com/$OWNER/$REPO.git

    cd $REPO
}

function tryUpdateVersions {
    echo Trying to update versions
    mvn org.codehaus.mojo:versions-maven-plugin:use-latest-versions
    if [[ `git status --porcelain` ]]; then
      echo Has changes, running tests
      mvn clean test
      if [ $? -eq 0 ]
      then
        echo Tests passed successfully, can proceed with pull request
        return 0
      else
        echo Some tests failed
        return 1
      fi
    else
      echo No changes
      return 0
    fi
}

function forkRepository {
    echo Forking original repository...
    # TODO implement
}

function createPullRequest {
    echo Creating pull request...
    # TODO implement

}

# Main routine
pushd $(pwd)

cloneRepo
if tryUpdateVersions; then
    echo Has version changes and tests have passed
    forkRepository
    tryUpdateVersions
    createPullRequest
fi

popd

cleanup




