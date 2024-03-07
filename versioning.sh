#!/bin/bash

# Function to update the pom.xml with a new version using Maven
update_pom_version() {
    local version=$1
    echo "Updating pom.xml to version $version"
    mvn versions:set -DnewVersion=$version
    mvn versions:commit
    push_to_origin $2
}

# Function to push the changes to current branch
push_to_origin() {
    local branch_name=$1
    git config --global user.name "Git Action"
    git config --global user.email "admin@users.noreply.github.com"
    git add ./pom.xml
    git commit -m "Update version in pom.xml"
    git push origin $branch_name
}

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
branch_name=$1
trigger_event=$2
# Main logic
if [[ $branch_name == opsrelease/* ]] && [[ $trigger_event == "create" ]]; then
    version=$(echo $branch_name | sed 's/release\///')
    update_pom_version $version $branch_version

elif [[ $branch_name == opsrelease/* ]]; then
    echo "elif 1 triggered"
    version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | sed 's/^v//')
    increment_version $version $increment minor

elif [[ $branch_name == opshotfix/* ]]; then
    echo "elif 2 triggered"
    version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | sed 's/^v//')
    increment_version $version $increment patch
    
elif [[ $branch_name == "main" ]] && [[ $trigger_event == "pull_request" ]]; then
    echo "elif 3 triggered"
    version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout | sed 's/^v//')
    increment_version $version $increment major

elif [[ $branch_name == "opsdevelopment" ]]; then
    current_version=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
    if [[ $current_version != *"-SNAPSHOT"* ]]; then
        new_version="${current_version}-SNAPSHOT"
        update_pom_version $new_version
    else
        echo "Development branch already has a SNAPSHOT version."
    fi

 else
     echo "Branch is neither a opsrelease nor opsdevelopment. No action taken."
fi
