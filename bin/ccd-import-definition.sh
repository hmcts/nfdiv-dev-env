#!/usr/bin/env bash

CCD_DEF_DIR=./nfdiv-ccd-definitions
CCD_DEF_URL=${CCD_DEF_URL:-http://localhost:4451}
CURL_OPTS=${CURL_OPTS:--s -f}
CURL="curl $CURL_OPTS"

[[ -d $CCD_DEF_DIR ]] || (echo "No CCD definition directory, please run ./bin/init.sh" && exit)

cd "$CCD_DEF_DIR" && yarn && yarn reset-ccd-submodule && yarn generate-excel-local && yarn generate-bulk-excel-local;
cd ../

if [ -z "$SERVICE_TOKEN" ]
then
  SERVICE_TOKEN="$(./bin/s2s-token.sh)"
  USER_TOKEN="$(./bin/idam-token.sh)"
fi

export  SERVICE_TOKEN
export  USER_TOKEN

./bin/wait-for.sh "CCD" $CCD_DEF_URL

echo "Creating CCD Roles"
./bin/ccd-add-role.sh citizen
./bin/ccd-add-role.sh caseworker-divorce-courtadmin_beta
./bin/ccd-add-role.sh caseworker-divorce-systemupdate
./bin/ccd-add-role.sh caseworker-divorce-superuser
./bin/ccd-add-role.sh caseworker-divorce-pcqextractor
./bin/ccd-add-role.sh caseworker-divorce-courtadmin-la
./bin/ccd-add-role.sh caseworker-divorce-bulkscan
./bin/ccd-add-role.sh caseworker-divorce-courtadmin
./bin/ccd-add-role.sh caseworker-divorce-solicitor
./bin/ccd-add-role.sh caseworker-caa
./bin/ccd-add-role.sh caseworker-divorce

echo "Importing CCD divorce definition"
$CURL \
  $CCD_DEF_URL/import \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "ServiceAuthorization: Bearer ${SERVICE_TOKEN}" \
  -F file="@$CCD_DEF_DIR/definitions/divorce/xlsx/ccd-config-local.xlsx"

echo "Importing CCD bulk action definition"
$CURL \
  $CCD_DEF_URL/import \
  -H "Authorization: Bearer ${USER_TOKEN}" \
  -H "ServiceAuthorization: Bearer ${SERVICE_TOKEN}" \
  -F file="@$CCD_DEF_DIR/definitions/bulk-action/xlsx/ccd-nfdiv-bulk-action-config-local.xlsx"