#!/bin/sh

# Variables
OWNER=ctco
REPO=zephyr-sync
TMPDIR=/tmp/$OWNER-$REPO
FORK_TO=sergeytrasko

# Functions
function cleanup {
    echo Performing clean-up...
    rm -rf $TMPDIR
}

function cloneRepo {
    echo Cloning repository...
    mkdir $TMPDIR
    cd $TMPDIR
    git clone https://github.com/$OWNER/$REPO.git

    cd $REPO
}

function tryUpdateVersions {
    echo Check that build is passing
    mvn clean test
    if [ $? -ne 0 ]
    then
        echo Tests are failing even before versions update
        return 1
    fi

    updateVersions
    if [[ `git status --porcelain` ]]; then
      echo Has changes, running tests
      mvn clean test
      if [ $? -eq 0 ]
      then
        echo Tests passed successfully, can proceed with pull request
        return 0
      else
        echo Some tests failed due to dependency update
        return 1
      fi
    else
      echo No changes
      return 0
    fi
}

function forkRepository {
    echo Forking original repository...
    # TODO implement properly - need to enter password
    curl -u $FORK_TO -d '' https://api.github.com/repos/$OWNER/$REPO/forks
}

function updateVersions {
    echo Updating versions...
    mvn org.codehaus.mojo:versions-maven-plugin:use-latest-versions
}

function commitChanges {
    echo Committing changes...
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
    updateVersions
    commitChanges
    createPullRequest
fi

popd

cleanup




