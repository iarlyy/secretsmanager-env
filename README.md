* docker entrypoint example

```
#! /bin/bash
set -e

ENV_FILE="/app/secret-env"

if [ -n "${ENV_SECRET_NAME}" ]; then
  /app/bin/secretsmanager_env --output export ${ENV_SECRET_NAME} > ${ENV_FILE}
  source ${ENV_FILE}
fi


if [ -z "$1" ]; then
  set -- <my application default command goes here>> "$@"
fi

exec "$@"

```
