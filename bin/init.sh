#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

API_DIR=./nfdiv-case-api
FE_DIR=./nfdiv-frontend
SERVICE_AUTH_PROVIDER_API_BASE_URL=http://rpe-service-auth-provider-aat.service.core-compute-aat.internal

az acr login --name hmctspublic --subscription 8999dec3-0104-4a27-94ee-6588559729d1
az acr login --name hmctsprivate --subscription 8999dec3-0104-4a27-94ee-6588559729d1

[[ -d API_DIR ]] || git clone git@github.com:hmcts/nfdiv-case-api.git
[[ -d $FE_DIR ]] || git clone git@github.com:hmcts/nfdiv-frontend.git

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

cd $API_DIR && (./gradlew assemble -q > /dev/null 2>&1)
cd ../$FE_DIR && (yarn > /dev/null 2>&1)
cd ../

docker-compose up --build -d

./bin/ccd-import-definition.sh
