#!/bin/bash

# Function to update the pom.xml with a new version using Maven
update_pom_version() {
    local version=$1
    echo "Updating pom.xml to version $version"
    mvn versions:set -DnewVersion=$version
    mvn versions:commit
}

# psudo code

# push_to_origin() {
#     local branch_name=$1
#     git config --global user.name="Github Action"
#     git config --global user.email="GithubAction@example.com"
#     git add ./pom.xml
#     git push origin $branch_name
# }

# Function to increment version
increment_version() {
    local version=$1
    local increment=$2
    local base_version=$(echo $version | cut -d'-' -f1)
    local major=$(echo $base_version | cut -d'.' -f1)
    local minor=$(echo $base_version | cut -d'.' -f2)
    local patch=$(echo $base_version | cut -d'.' -f3)

    case $increment in
        "major")
            major=$((major+1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor+1))
            patch=0
            ;;
        "patch")
            patch=$((patch+1))
            ;;
    esac

    update_pom_version "v${major}.${minor}.${patch}"
}

# Get current branch name
branch_name=$(git rev-parse --abbrev-ref HEAD)

# Main logic
if [[ $branch_name == release/* ]] && [[ $trigger_event == "create" ]]; then
    version=$(echo $branch_name | sed 's/release\///')
    update_pom_version $version

elif [[ $branch_name == release/* ]]; then
    echo "elif 1 triggered"
    version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | sed 's/^v//')
    increment_version $version $increment

elif [[ $branch_name == "development" ]]; then
    current_version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
    if [[ $current_version != *"-SNAPSHOT"* ]]; then
        new_version="${current_version}-SNAPSHOT"
        update_pom_version $new_version
    else
        echo "Development branch already has a SNAPSHOT version."
    fi

 else
     echo "Branch is neither a release nor development. No action taken."
fi
