#!/usr/bin/env bash

ROOT_DIR="$(dirname "$0")/../"
CCD_DEF_DIR=$ROOT_DIR/nfdiv-ccd-definitions
CCD_DEF_URL=${CCD_DEF_URL:-http://localhost:4451}
CURL_OPTS=${CURL_OPTS:--s -f}
CURL="curl $CURL_OPTS"

[[ -d $CCD_DEF_DIR ]] || (echo "No CCD definition directory, please run ./bin/init.sh" && exit)

cd "$CCD_DEF_DIR" && yarn && yarn reset-ccd-submodule && yarn generate-excel-local;
cd ../

echo "Importing CCD definition"

until $CURL $CCD_DEF_URL/health
do
  echo "Waiting for CCD";
  sleep 10;
done

$ROOT_DIR./bin/ccd-add-role.sh citizen
$ROOT_DIR./bin/ccd-add-role.sh caseworker-divorce-courtadmin_beta
$ROOT_DIR./bin/ccd-add-role.sh caseworker-divorce-systemupdate
$ROOT_DIR./bin/ccd-add-role.sh caseworker-divorce-superuser
$ROOT_DIR./bin/ccd-add-role.sh caseworker-divorce-pcqextractor
$ROOT_DIR./bin/ccd-add-role.sh caseworker-divorce-courtadmin-la
$ROOT_DIR./bin/ccd-add-role.sh caseworker-divorce-bulkscan
$ROOT_DIR./bin/ccd-add-role.sh caseworker-divorce-courtadmin
$ROOT_DIR./bin/ccd-add-role.sh caseworker-divorce-solicitor

$CURL \
  $CCD_DEF_URL/import \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "ServiceAuthorization: Bearer ${SERVICE_TOKEN}" \
  -F file="@$CCD_DEF_DIR/definitions/divorce/xlsx/ccd-config-local.xlsx"

