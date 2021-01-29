#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

IMPORTER_USERNAME=${1:-ccd.importer@hmcts.net}
IMPORTER_PASSWORD=${2:-Pa55word11}
IDAM_URI="http://localhost:5000"
REDIRECT_URI="http://localhost:3001/oauth2/callback"
CLIENT_ID="divorce"
CLIENT_SECRET=${OAUTH2_CLIENT_SECRET}
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
