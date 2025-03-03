#!/bin/bash

set -e
docker compose down

# create backup
docker compose up --wait nc-db
docker compose exec -it nc-db pg_dumpall -U postgres >dump.sql
docker compose down

sudo mv /media/data/nextcloud/{db,db-old}
sudo mkdir /media/data/nextcloud/db
sudo chown 70 /media/data/nextcloud/db

# restore backup
docker compose pull --include-deps --policy always
docker compose up --wait nc-db
cat dump.sql | docker compose exec -T nc-db psql -U postgres

docker compose build
docker compose up --wait
