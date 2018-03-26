#!/bin/sh

# If a BRIGADE_REPO_AUTH_TOKEN is provided, return that
if [ ! -z "${BRIGADE_REPO_AUTH_TOKEN+x}" ] ; then
  echo $BRIGADE_REPO_AUTH_TOKEN

# Else, if all of the proper environmental variables
#  to use a Github App are provided, use that instead
#  to authenticate against Github and get a limited-lifetime
#  OAuth token
elif [ ! -z "${BRIGADE_REPO_GITHUB_APP_IDENTIFIER+x}" ] && \
	[ ! -z "${BRIGADE_REPO_GITHUB_APP_INSTALLATION_ID+x}" ] && \
	[ ! -z "${BRIGADE_REPO_GITHUB_APP_PRIVATE_KEY+x}" ] ; then
  curl -s -XPOST "https://api.github.com/installations/$BRIGADE_REPO_GITHUB_APP_INSTALLATION_ID/access_tokens" \
	  -H 'Accept: application/vnd.github.machine-man-preview+json' \
	  -H "Authorization: Bearer $(bash /jwt-auth.sh RS256 '{"iss": "'$BRIGADE_REPO_GITHUB_APP_IDENTIFIER'"}' "$BRIGADE_REPO_GITHUB_APP_PRIVATE_KEY")" \
		| jq -r .token
fi
