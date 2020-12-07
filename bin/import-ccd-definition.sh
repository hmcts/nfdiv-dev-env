#!/usr/bin/env bash

ROOT_DIR="$(dirname "$0")/../"
CCD_DEF_DIR=$ROOT_DIR/nfdiv-ccd-definitions
CURL_OPTS=${CURL_OPTS:--v -f}
CURL="curl $CURL_OPTS"

[[ -d $CCD_DEF_DIR ]] || (echo "No CCD definition directory, please run ./bin/init.sh" && exit)

SERVICE_TOKEN="$(${ROOT_DIR}/bin/s2s-token.sh)"
USER_TOKEN="$(${ROOT_DIR}/bin/idam-token.sh)"

[ -z "$SERVICE_TOKEN" ] && >&2 echo "No service token" && exit
[ -z "$USER_TOKEN" ] && >&2 echo "No user token" && exit

cd "$CCD_DEF_DIR" && yarn && yarn reset-ccd-submodule && yarn generate-excel-local;
cd ../

echo "Importing CCD definition"

until curl -s http://localhost:4451/health
do
  echo "Waiting for CCD";
  sleep 10;
done

$CURL \
  http://localhost:4451/import \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "ServiceAuthorization: Bearer ${SERVICE_TOKEN}" \
  -F file="@$CCD_DEF_DIR/definitions/divorce/xlsx/ccd-config-local.xlsx"

