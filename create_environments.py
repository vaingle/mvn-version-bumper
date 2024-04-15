import os
import sys
import requests

# GitHub token
github_token = os.getenv('GITHUB_TOKEN')
if not github_token:
    raise ValueError("GitHub token not found. Please set the 'GITHUB_TOKEN' environment variable.")

# Repository details
username = 'your_username'
repository_name = 'your_repository_name'
base_branch = 'main'

# Environment name from command-line argument
environment = sys.argv[1]

# GitHub API base URL
base_url = 'https://api.github.com'

# Authentication headers
headers = {
    'Authorization': f'token {github_token}',
    'Accept': 'application/vnd.github.v3+json'
}

# Check if environment already exists
response = requests.get(
    f"{base_url}/repos/{username}/{repository_name}/statuses/{base_branch}",
    headers=headers
)
existing_env = any(status['context'] == environment for status in response.json())

if existing_env:
    print(f"Environment '{environment}' already exists.")
else:
    # Create new environment
    data = {
        "state": "pending",
        "target_url": "",
        "description": f"Setting up {environment} environment",
        "context": environment
    }
    response = requests.post(
        f"{base_url}/repos/{username}/{repository_name}/statuses/{base_branch}",
        json=data,
        headers=headers
    )
    if response.status_code == 201:
        print(f"Environment '{environment}' created successfully.")
    else:
        print(f"Failed to create environment '{environment}'.")
