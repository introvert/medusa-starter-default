#!/bin/sh
set -e

echo "Running database migrations..."
medusa migrations run

echo "Starting Medusa server..."
exec medusa start
