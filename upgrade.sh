#!/bin/bash

set -xe
docker compose down

# build and upgrade
docker compose pull --include-deps --policy always --ignore-buildable
docker compose build

docker compose up --wait

