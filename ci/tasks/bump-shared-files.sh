#!/bin/bash

set -eu

pushd repo
export ref=$(git rev-parse HEAD)
popd

pushd source-repo

sed "s/ref:.*/ref: ${ref}/g" ../repo/vendir.tmpl.yml > ./ci/vendir.yml

pushd ci
vendir sync
popd

mkdir -p ./.github/workflows
if [[ -f ./yarn.lock ]]; then
  cp ./ci/vendor/actions/nodejs-*.yml ./.github/workflows/
fi

cp ./ci/vendor/actions/spelling.yml ./.github/workflows

if [[ -f ./docker-compose.yml ]]; then
  cp ./ci/vendor/actions/test-integration.yml
fi

if [[ -z $(git config --global user.email) ]]; then
  git config --global user.email "bot@galoy.io"
fi
if [[ -z $(git config --global user.name) ]]; then
  git config --global user.name "CI Bot"
fi

(
  cd $(git rev-parse --show-toplevel)
  git add -A
  git status
  git commit -m "ci(shared): bump vendored ci files"
)
