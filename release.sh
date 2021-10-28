#!/bin/bash

DEV_BRANCH="dev"
MAIN_BRANCH="master"

set -e

if [ -f "./package.json" ]; then
  JS_PROJECT="TRUE"
fi

release() {
  VERSION_NBR=$(cat VERSION)
  if [ -z "$VERSION_NBR" ]; then
    VERSION_NBR="0.0.1"
  fi

  NEW_VERSION=$1
  if [ -z "$NEW_VERSION" ]; then
    NEW_VERSION="${VERSION_NBR%.*}.$((${VERSION_NBR##*.} + 1))"
  fi

  echo "Attempt to release version $VERSION_NBR and start working for $NEW_VERSION"

  # detect current branch
  BRANCH=$(git rev-parse --abbrev-ref HEAD)

  if [[ "$BRANCH" != "$DEV_BRANCH" ]]; then
    echo "ERROR: Checkout $DEV_BRANCH branch before tagging."
    exit 1
  fi

  if [ -z "$(git status --porcelain)" ]; then
    git pull origin $DEV_BRANCH

    VERSION=v$VERSION_NBR
    git tag -a $VERSION -m "Version $VERSION"
    git push origin $DEV_BRANCH --tags

    echo $NEW_VERSION >VERSION
    if [ -n "$JS_PROJECT" ]; then
      npm --no-git-tag-version version $NEW_VERSION
    fi
    git add VERSION
    git commit -a -m "Start dev for v$NEW_VERSION."
    git push origin $DEV_BRANCH
  else
    echo "ERROR: Working directory is not clean, commit or stash changes."
  fi
}

# check if there other changes than version number between main and dev branch
GREP_STR="VERSION"
# TODO: detect libs changes from package.json and do release if any
if [ -n "$JS_PROJECT" ]; then
  GREP_STR="VERSION\|.*package.*json"
fi
diff="$(git diff origin/$MAIN_BRANCH $DEV_BRANCH --name-only | grep -v $GREP_STR)"

if [ -z "$diff" ]; then
  printf "\nNo changes found. No need to release.\n"
  exit 0
fi

printf "\nDiff between $MAIN_BRANCH and $DEV_BRANCH: $diff\n"

workflows=`echo "$GATE" | tr ',' ' '`

for workflow in $(echo $workflows)
do
  badge=$(curl -s ${WORKFLOW_BADGE/'WORKFLOW_NAME'/"$workflow"})
  if [[ $(echo $badge | grep failing) ]]; then # check if required workflow is passing
    printf "\nBuild is not passing. Should not release changes.\n"
    exit 1
  fi
  if [[ $(echo $badge | grep 'Not Found') ]]; then # check if required workflow is found
    printf "\nBuild is not found. Should not release changes.\n"
    exit 1
  fi
done;

release $1
