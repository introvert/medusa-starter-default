#!/bin/sh
set -e

echo "Running database migrations..."
pnpm exec medusa migrations run

echo "Starting Medusa server..."
exec pnpm exec medusa start
