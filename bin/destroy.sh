#!/usr/bin/env bash

docker-compose stop
docker system prune -f
docker volume prune -f
