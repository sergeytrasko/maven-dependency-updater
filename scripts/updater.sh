#!/bin/sh

# Variables
OWNER=IgorGursky
REPO=zephyr-sync
TMPDIR=/tmp/$OWNER-$REPO
FORK_TO=sergeytrasko
GIT_PASSWORD=$(<../.env)

# Functions
function cleanup {
    echo Performing clean-up...
    rm -rf $TMPDIR
}

function cloneRepo {
    echo Cloning repository to $TMPDIR/$2...
    mkdir $TMPDIR
    cd $TMPDIR
    git clone https://github.com/$1/$2.git $1-$2

    cd $1-$2
}

function tryUpdateVersions {
    echo Check that build is passing...
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
    curl -u $FORK_TO:$GIT_PASSWORD -d '' https://api.github.com/repos/$OWNER/$REPO/forks
    cloneRepo $FORK_TO $REPO
}

function updateVersions {
    echo Updating versions...
    mvn org.codehaus.mojo:versions-maven-plugin:use-latest-versions
}

function commitChanges {
    echo Committing changes...
    git commit -am "Versions update"
    git push
}

function createPullRequest {
    echo Creating pull request...
    curl -u $FORK_TO:$GIT_PASSWORD -d '{"title": "Version update", "head": "'$FORK_TO':master", "base": "master"}' https://api.github.com/repos/$OWNER/$REPO/pulls
}

# Main routine
pushd $(pwd)

cloneRepo $OWNER $REPO
if tryUpdateVersions; then
    echo Has version changes and tests have passed
    forkRepository
    updateVersions
    commitChanges
    createPullRequest
fi

popd

cleanup




