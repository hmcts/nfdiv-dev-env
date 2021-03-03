#!/usr/bin/env bash

API_DIR=./nfdiv-case-api
CCD_DEF_URL=${CCD_DEF_URL:-http://localhost:4451}
CURL_OPTS=${CURL_OPTS:--s -f}
CURL="curl $CURL_OPTS"

[[ -d $API_DIR ]] || (echo "No nfdiv-case-api directory, please run ./bin/init.sh" && exit)

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
cd "$API_DIR" && ./gradlew -q generateCCDConfig
./bin/process-and-import-ccd-definition.sh
cd ../

