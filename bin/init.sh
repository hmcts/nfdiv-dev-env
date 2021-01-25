#!/usr/bin/env bash

ROOT_DIR="$(dirname "$0")/../"
CCD_DEF_DIR=$ROOT_DIR/nfdiv-ccd-definitions
COS_DIR=$ROOT_DIR/nfdiv-case-orchestration-service
CMS_DIR=$ROOT_DIR/nfdiv-case-maintenance-service
DFE_DIR=$ROOT_DIR/nfdiv-frontend

SERVICE_TOKEN="$(${ROOT_DIR}/bin/s2s-token.sh)"
USER_TOKEN="$(${ROOT_DIR}/bin/idam-token.sh)"

[ -z "$SERVICE_TOKEN" ] && >&2 echo "No service token" && exit
[ -z "$USER_TOKEN" ] && >&2 echo "No user token" && exit

export SERVICE_TOKEN
export USER_TOKEN

cd "$ROOT_DIR" || exit

[[ -d $CCD_DEF_DIR ]] || git clone git@github.com:hmcts/nfdiv-ccd-definitions.git
[[ -d $COS_DIR ]] || git clone git@github.com:hmcts/nfdiv-case-orchestration-service.git
[[ -d $CMS_DIR ]] || git clone git@github.com:hmcts/nfdiv-case-maintenance-service.git
[[ -d $DFE_DIR ]] || git clone git@github.com:hmcts/nfdiv-frontend.git

cd $COS_DIR && ./gradlew assemble
cd ../$CMS_DIR && ./gradlew assemble
cd ../$DFE_DIR && yarn
cd ../

az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1
az acr login --name hmctsprivate --subscription 8999dec3-0104-4a27-94ee-6588559729d1
docker-compose stop
docker-compose up --build -d

$ROOT_DIR./bin/ccd-import-definition.sh
