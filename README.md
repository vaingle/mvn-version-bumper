# Maven Versioning GitHub Action

## Overview

This GitHub Action automatically updates the version in Maven `pom.xml` files based on the branch name and event triggers in a Git repository. It's designed to facilitate version management in Maven projects, streamlining the release process in continuous integration/continuous deployment (CI/CD) workflows.

### Features

- **Automatic Versioning**: Sets the version in `pom.xml` based on the branch name.
- **Version Increment**: Supports major, minor, and patch version increments.
- **Customizable**: Configurable for different branch naming conventions and versioning strategies.

## Usage

To use this action in your workflow, add a step in your `.github/workflows` YAML file. Here is an example of how to configure the action:

```yaml
jobs:
  versioning:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v2
    - name: Run Versioning Script
      uses: <org>/<repo>@<version>
      with:
        trigger_event: ${{ github.event_name }}
        increment: 'patch'  # Options: 'major', 'minor', 'patch'
```

### Inputs

- `trigger_event` (required): The event that triggered the workflow (e.g., `create`, `push`).
- `increment` (optional): The type of version increment to apply (`major`, `minor`, `patch`). Default is `patch`.

## Setup

1. **Add the Action to Your Repository**: Copy `action.yml`, `Dockerfile`, and `versioning.sh` to your repository.
2. **Dockerfile**: Ensure the Dockerfile is set up with Maven and other dependencies.
3. **Workflow Configuration**: Add the action to your workflow as shown in the usage section.

## Action Logic

- For branches named `release/*`, the action sets the version in `pom.xml` based on the branch name (e.g., `release/v1.0.0` sets version `1.0.0`).
- For the `development` branch, the action appends `-SNAPSHOT` to the current version unless it already contains `-SNAPSHOT`.
- For merging into `release/*` branches, the action can automatically increment the version (major, minor, or patch) based on the specified input.
