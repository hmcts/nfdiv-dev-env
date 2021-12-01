#!/usr/bin/env bash

set -eu

if [ "${ENVIRONMENT:-local}" != "local" ]; then
  exit 0;
fi

dir=$(dirname ${0})

email=${1}

IDAM_URI="http://localhost:5000"

apiToken=$(curl --silent --show-error --header 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' -d "username=${CCD_SYSTEM_UPDATE_USERNAME}&password=${CCD_SYSTEM_UPDATE_PASSWORD}" "${IDAM_URI}/loginUser")

curl --silent --show-error -H 'Content-Type: application/json' -H "Authorization: AdminApiAuthToken ${apiToken}" \
  ${IDAM_URI}/users?email=${email}