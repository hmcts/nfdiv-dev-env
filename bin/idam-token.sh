#!/bin/env bash

IMPORTER_USERNAME=${1:-nfdiv@hmcts.net}
IMPORTER_PASSWORD=${2:-Pa55word11}
IDAM_URI="https://idam-api.aat.platform.hmcts.net"
REDIRECT_URI="http://localhost:3300/oauth2/callback"
CLIENT_ID="fact_admin"
CLIENT_SECRET="fact_admin_secret"
CURL_OPTS=${CURL_OPTS:--s -f --retry 5}
CURL="curl $CURL_OPTS"
JQ="docker run --rm -i imega/jq"

res=$($CURL -u "${IMPORTER_USERNAME}:${IMPORTER_PASSWORD}" -XPOST "${IDAM_URI}/oauth2/authorize?redirect_uri=${REDIRECT_URI}&response_type=code&client_id=${CLIENT_ID}" -d "")
test "$?" != "0" && >&2 echo "No IDAM code: $res" && exit 1
code=$(echo "$res" | $JQ -r .code)

res=$($CURL -H "Content-Type: application/x-www-form-urlencoded" -u "${CLIENT_ID}:${CLIENT_SECRET}" -XPOST "${IDAM_URI}/oauth2/token?code=${code}&redirect_uri=${REDIRECT_URI}&grant_type=authorization_code" -d "")
test "$?" != "0" && >&2 echo "No IDAM token: $res" && exit 1
token=$(echo "$res" | $JQ -r .access_token)

echo "$token"
