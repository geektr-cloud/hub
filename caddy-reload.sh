#!/usr/bin/env bash

cd  "${BASH_SOURCE[0]}"
docker-compose exec caddy pkill -USR1 caddy
