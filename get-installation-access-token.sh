#!/bin/sh -e
export PRIVATE_KEY=${1:?Usage: ${0} <private-key> <app-id> <lifetime-minutes>}
export APP_ID=${2:?Usage: ${0} <private-key> <app-id> <lifetime-minutes>}
export LIFETIME_MINUTES=${3:?Usage: ${0} <private-key> <app-id> <lifetime-minutes>}
repo=${GITHUB_REPOSITORY:?Missing required GITHUB_REPOSITORY environment variable}

[[ ! -z "$INPUT_REPO" ]] && repo=$INPUT_REPO

jwt=$(ruby $(dirname $0)/generate-jwt.rb)
installation_id=$(curl -s \
-H "Authorization: Bearer ${jwt}" \
-H "Accept: application/vnd.github.machine-man-preview+json" \
https://api.github.com/repos/${repo}/installation | jq -r .id)

if [ "$installation_id" = "null" ]; then
  echo "Unable to get installation ID. Is the GitHub App installed on ${repo}?"
  exit 1
fi

token=$(curl -s -X POST \
-H "Authorization: Bearer ${jwt}" \
-H "Accept: application/vnd.github.machine-man-preview+json" \
https://api.github.com/app/installations/${installation_id}/access_tokens | jq -r .token)

if [ "$token" = "null" ]; then
  echo "Unable to generate installation access token"
  exit 1
fi

echo ::set-output name=token::${token}
