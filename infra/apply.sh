#!/usr/bin/env bash

. ../data/env.sh

if [ ! -d "plans" ]; then
  mkdir plans
fi

planfile="plans/$(date -Is | tr ':+' '_Z')"

terraform plan -out "$planfile"

while [ -z "$looks_ok" ]; do
  read -rp "Does this look ok?[Y/n]" looks_ok
  looks_ok="${looks_ok,,}"
  case "${looks_ok:-yes}" in
  y | yes) looks_ok="yes" ;;
  n | no) looks_ok="no" ;;
  *) looks_ok="" ;;
  esac
done

if [ "${looks_ok}" == 'yes' ]; then
  terraform apply "$planfile"
fi

