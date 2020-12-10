#!/bin/env bash

MICROSERVICE="${1:-ccd_gw}"
CURL_OPTS="${CURL_OPTS:--s -f --retry 5}"

token=$(curl $CURL_OPTS -X POST \
  -H "Content-Type: application/json" \
  -d '{"microservice":"'${MICROSERVICE}'"}' \
  http://rpe-service-auth-provider-aat.service.core-compute-aat.internal/testing-support/lease)

test "$?" != "0" && >&2 echo "No S2S token" && exit 1

echo $token
