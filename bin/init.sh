#!/usr/bin/env bash

ROOT_DIR="$(dirname "$0")/../"
CCD_DEF_DIR=$ROOT_DIR/nfdiv-ccd-definitions

az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1
docker-compose stop
docker-compose up -d

cd "$ROOT_DIR" || exit

[[ -d $CCD_DEF_DIR ]] || git clone git@github.com:hmcts/nfdiv-ccd-definitions.git

$ROOT_DIR./bin/import-ccd-definition.sh
