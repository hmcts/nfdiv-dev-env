#!/usr/bin/env bash

ROOT_DIR="$(dirname "$0")/../"

docker-compose stop
docker-compose up -d idam-api fr-am fr-idm idam-web-public shared-db

$ROOT_DIR./bin/wait-for.sh "IDAM" http://localhost:5000

docker-compose up -d --build

echo "Starting services"
