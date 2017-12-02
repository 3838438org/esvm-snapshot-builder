#!/usr/bin/env bash

set -e;

dir="$(pwd)"
repo="$dir/es_repo"

if [ -z "$ES_BRANCH" ]; then
  echo "ES_BRANCH environment variable must be set to run build.sh"
  exit 1
fi

if [ -z "$ES_REMOTE" ]; then
  echo "ES_REMOTE environment variable must be set to run build.sh"
  exit 1
fi

if [ ! -x "$dir/gradlew" ] || [ ! -x "$dir/build.sh" ]; then
  echo "esvm-snapshot-builder/build.sh must be run from within the repo"
fi


echo " -- cloning elasticsearch $ES_BRANCH to $repo"
git clone "$ES_REMOTE" --branch "$ES_BRANCH" --depth 1 "$repo"

echo " -- building elasticsearch"
cd "$repo"
"$dir/gradlew" clean :distribution:tar:assemble :distribution:zip:assemble --stacktrace
cd -

echo " -- copying artifacts to $dir/target"
mkdir -p "$dir/target"
find "$repo/distribution/zip" -name '*elasticsearch*.zip' -execdir cp '{}' "$dir/target/${ES_BRANCH}.zip" ';'
find "$repo/distribution/tar" -name '*.tar.gz' -execdir cp '{}' "$dir/target/${ES_BRANCH}.tar.gz" ';'