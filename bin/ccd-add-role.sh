#!/usr/bin/env bash
## Usage: ./ccd-add-role.sh role [classification]
##
## Options:
##    - role: Name of the role. Must be an existing IDAM role.
##    - classification: Classification granted to the role; one of `PUBLIC`,
##        `PRIVATE` or `RESTRICTED`. Default to `PUBLIC`.
##
## Add support for an IDAM role in CCD.

CCD_DEF_URL=${CCD_DEF_URL:-http://localhost:4451}
CURL_OPTS=${CURL_OPTS:--s -f}
CURL="curl $CURL_OPTS"

role=$1
classification=${2:-PUBLIC}

if [ -z "$role" ]
  then
    echo "Usage: ./ccd-add-role.sh role [classification]"
    exit 1
fi

case $classification in
  PUBLIC|PRIVATE|RESTRICTED)
    ;;
  *)
    echo "Classification must be one of: PUBLIC, PRIVATE or RESTRICTED"
    exit 1 ;;
esac

$CURL -XPUT \
  $CCD_DEF_URL/api/user-role \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "ServiceAuthorization: Bearer ${SERVICE_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"role":"'${role}'","security_classification":"'${classification}'"}'
