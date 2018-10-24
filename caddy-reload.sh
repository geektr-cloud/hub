#!/usr/bin/env bash

cd  "${BASH_SOURCE[0]}"
docker-compose exec -T caddy pkill -USR1 caddy
