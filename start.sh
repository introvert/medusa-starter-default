#!/bin/sh
set -e

echo "Running database migrations..."
pnpm exec medusa db:migrate

echo "Starting Medusa server..."
exec pnpm exec medusa start
