#!/usr/bin/env bash

# <><> Commit Type <><>

# Build associative array of valid commmit types
#  [type]:[desc]
declare -A commitTypes
commitTypes["feat"]="Implementation of a new feature"
commitTypes["fix"]="A bug fix"
commitTypes["build"]="Changes to build system"
commitTypes["chore"]="Updating grunt tasks etc. No production code change"
commitTypes["ci"]="Changes to CI/CD pipeline"
commitTypes["docs"]="Documentation only changes"
commitTypes["perf"]="A code change that improves performance"
commitTypes["refactor"]="A code change that neither fixes a bug nor adds a feature"
commitTypes["style"]="Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)"
commitTypes["test"]="Adding missing tests or correcting existing tests"
commitTypes["WIP"]="An incomplete commit purely with the intent to push code off a local machine"

# Build \n deliminated string of valid commit types
# for use with fzf
typeMenu=""
for key in "${!commitTypes[@]}"; do
    typeMenu+="$key\n"
done

# Prompt user for commit type selection
type=$(printf $typeMenu | gum filter \
    --placeholder "Commit Type: "
)

printf "%b\n" "\033[1mCommit Type:\033[0m\n$type\n"

scope=$(gum input --prompt "Commit Scope (optional): ")
printf "%b\n" "\033[1mCommit Scope:\033[0m\n$scope\n"
if [ "$scope" != "" ]; then
    scope="($scope)"
fi

desc=$(gum input --prompt "Commit Description: ")
printf "%b\n" "\033[1mCommit Description:\033[0m\n$desc\n"

body=$(gum write --header "Commit Body (optional)[ctr-d to end]: ")
printf "%b\n" "\033[1mCommit Body:\033[0m\n$body\n"

breaking=false
gum confirm "Breaking Change?" --affirmative=Yes --negative=No && breaking=true
case "$breaking" in
    true) breaking="!" && breakingFooterKey="BREAKING CHANGE: " && breakingFooterVal=$(gum input --placeholder "Breaking Change Description: ")
    ;;
    *) breaking="" && breakingFooterKey="" && breakingFooterVal=""
    ;;
esac

# Build commit file
dir=$XDG_DATA_HOME/conventional-commit
file=$dir/commit
tmpFile=$file.tmp
commitFile=$file.fmt
mkdir -p $dir
touch $tmpFile

# write to file
printf "$type$scope$breaking: $desc\n\n$body\n\n$breakingFooterKey$breakingFooterVal\n" > $tmpFile
fmt $tmpFile > $commitFile

printf "Commit Message written to $tmpFile"

gum confirm "Confirm Commit?" --affirmative=Yes --negative=No && commit=true

case "$commit" in
    true) git commit --file $commitFile
    ;;
    *) exit 1
    ;;
esac

