#!/bin/bash

set -e
set -o pipefail

values_arg=""

helpFunction() {
  echo ""
  echo "Usage: $0 -e <environment> -r <release> -v <values>"
  exit 1
}

while getopts e:r:v: flag
do
  case $flag in
    e) environment=$OPTARG;;
    r) release=$OPTARG;;
    v) values=$OPTARG;;
    ?) helpFunction;;
  esac
done

if [ -n "$values" ]; then
  values_arg="--state-values-set=$values"
fi

# Add chart repositories defined in state file
helmfile -q -e "$environment" repos

function render {
  echo "Rendering to gitopsManifests/$environment"

  rm -rf "gitopsManifests/$environment"
  mkdir -p "gitopsManifests/$environment"

  release_list=$(helmfile -q -e "$environment" list | awk 'NR!=1 && $3=="true" { print $1 }')
  line_count=$(echo "$release_list" | wc -l)
  echo "Found $line_count releases:"
  echo "$release_list"

  counter=0
  echo "$release_list" | while read -r release
  do
    counter=$((counter+1))
    echo "Rendering $counter/$line_count: $release"
    helmfile -q -e "$environment" --selector "name=$release" template --args='--include-crds' --skip-deps $values_arg > "gitopsManifests/$environment/$release.yaml"
  done
}

if [[ -n "$release" ]]
then
  echo "Rendering single release: $release"
  rm -f "gitopsManifests/$environment/$release.yaml"
  mkdir -p "gitopsManifests/$environment"

  helmfile -q -e "$environment" --selector "name=$release" template --args='--include-crds' $values_arg > "gitopsManifests/$environment/$release.yaml"
else
  render
fi
