#!/usr/bin/env bash

ROOT_DIR="$(dirname "$0")/../"
CCD_DEF_DIR=$ROOT_DIR/nfdiv-ccd-definitions

SERVICE_TOKEN="$(${ROOT_DIR}/bin/s2s-token.sh)"
USER_TOKEN="$(${ROOT_DIR}/bin/idam-token.sh)"

[ -z "$SERVICE_TOKEN" ] && >&2 echo "No service token" && exit
[ -z "$USER_TOKEN" ] && >&2 echo "No user token" && exit

export SERVICE_TOKEN
export USER_TOKEN

az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1
docker-compose stop
docker-compose up -d

cd "$ROOT_DIR" || exit

[[ -d $CCD_DEF_DIR ]] || git clone git@github.com:hmcts/nfdiv-ccd-definitions.git

$ROOT_DIR./bin/ccd-import-definition.sh
