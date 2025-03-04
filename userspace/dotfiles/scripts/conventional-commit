#!/usr/bin/env bash

trap "exit" INT

# status codes
declare -A STATUS
STATUS["SUCCESS"]=0
STATUS["MISC"]=1
STATUS["MISUSE"]=2
STATUS["INVALID_INPUT"]=55

commitTypes=$(cat <<'EOF'
feat        Implementation of a new feature
fix         A bug fix
build       Changes to build system
chore       Updating grunt tasks etc. No production code change
ci          Changes to CI/CD pipeline
docs        Documentation only changes
perf        A code change that improves performance
refactor    A code change that neither fixes a bug nor adds a feature
style       Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
test        Adding missing tests or correcting existing tests
wip         An incomplete commit purely with the intent to push code off a local machine
EOF
)


# Prompt user for commit type selection
type=$(echo -e "$commitTypes" \
    | fzf \
    --header "Commit Type: " \
    --style full \
    --reverse \
    --height ~100% \
    | awk '{print $1}'
)

# Trim whitespace
type=$(echo "$type" | xargs)

if [ "$type" == "" ]; then
    echo "No Commit Type selected [required]" >&2
    exit "${STATUS['INVALID_INPUT']}"
fi


# Check if there is a local commit scopes file
scopesFile=$(git rev-parse --show-toplevel)
scopesFile="$scopesFile/.commit-scopes"
commitScopes=""
if [ -f "$scopesFile" ]; then
    # File exists, proceed to read it
    while IFS= read -r line; do
        commitScopes="$commitScopes\n$line"
        # the leading '\n' makes the default suggestion empty (ideal)
    done < "$scopesFile"
fi

# Prompt for commit scope selection
scope=$(echo -e "$commitScopes" \
    | fzf \
    --header "Commit Scope: (optional)" \
    --style full \
    --reverse \
    --height ~100% \
    --print-query
)

# Trim whitespace
scope=$(echo "$scope" | xargs)

desc=$(echo "" \
    | fzf \
    --header "Commit Description" \
    --style full \
    --reverse \
    --height ~100% \
    --print-query
)

# Trim whitespace
desc=$(echo "$desc" | xargs)

# If Desc is empty, open editor for long form writing
if [ "$desc" == "" ]; then
    desc=$(vipe)
fi


# Desc is required
if [ "$desc" == "" ]; then
    echo "No Commit Description provided [required]" >&2
    exit "${STATUS['INVALID_INPUT']}"
fi

breakingReason=$(echo "" \
    | fzf \
    --header "Provide reason for breaking change (optional)" \
    --style full \
    --reverse \
    --height ~100% \
    --print-query
)

breakingFlag=""
if [ "$breakingReason" != "" ]; then
    breakingReason="BREAKING CHANGE: $breakingReason"
    breakingFlag="!"
fi

# Build commit file
dir=$XDG_DATA_HOME/conventional-commit
file=$dir/commit
tmpFile=$file.tmp
commitFile=$file.fmt
mkdir -p "$dir"
touch "$tmpFile"

# write to file
echo -e "$type($scope)$breakingFlag: $desc\n\n$breakingReason\n" > "$tmpFile"
fmt "$tmpFile" > "$commitFile"

git commit --file "$commitFile"
echo ""
git status
exit "${STATUS['SUCCESS']}"
