#!/usr/bin/env bash

CCD_DEF_DIR=./nfdiv-ccd-definitions
COS_DIR=./nfdiv-case-orchestration-service
CMS_DIR=./nfdiv-case-maintenance-service
DFE_DIR=./nfdiv-frontend

az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1
az acr login --name hmctsprivate --subscription 8999dec3-0104-4a27-94ee-6588559729d1

[[ -d $CCD_DEF_DIR ]] || git clone git@github.com:hmcts/nfdiv-ccd-definitions.git
[[ -d $COS_DIR ]] || git clone git@github.com:hmcts/nfdiv-case-orchestration-service.git
[[ -d $CMS_DIR ]] || git clone git@github.com:hmcts/nfdiv-case-maintenance-service.git
[[ -d $DFE_DIR ]] || git clone git@github.com:hmcts/nfdiv-frontend.git


docker-compose stop
docker-compose pull
docker-compose up -d idam-api fr-am fr-idm idam-web-public shared-db

./bin/wait-for.sh "IDAM" http://localhost:5000

echo "Starting IDAM set up"

./bin/idam-setup.sh

SERVICE_TOKEN="$(./bin/s2s-token.sh)"
USER_TOKEN="$(./bin/idam-token.sh)"

[ -z "$SERVICE_TOKEN" ] && >&2 echo "No service token" && exit
[ -z "$USER_TOKEN" ] && >&2 echo "No user token" && exit

cd $COS_DIR && (./gradlew assemble -q > /dev/null 2>&1)
cd ../$CMS_DIR && (./gradlew assemble -q > /dev/null 2>&1)
cd ../$DFE_DIR && (yarn > /dev/null 2>&1)
cd ../

docker-compose up --build -d

./bin/ccd-import-definition.sh