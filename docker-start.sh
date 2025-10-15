#!/bin/bash

# Ensure environment variables override .env file for database configuration
echo "Configuring environment for production..."

# Set default database configuration if not provided by environment
export DB_CONNECTION=${DB_CONNECTION:-pgsql}
export SESSION_DRIVER=${SESSION_DRIVER:-database}
export CACHE_STORE=${CACHE_STORE:-database}

echo "Database configuration:"
echo "  DB_CONNECTION: $DB_CONNECTION"
echo "  DATABASE_URL: ${DATABASE_URL:0:50}..."
echo "  SESSION_DRIVER: $SESSION_DRIVER"
echo "  CACHE_STORE: $CACHE_STORE"

# Wait for database to be available (PostgreSQL)
echo "Waiting for database connection..."
until php artisan tinker --execute="DB::connection()->getPdo();" 2>/dev/null; do
    echo "Database not yet available, waiting 2 seconds..."
    sleep 2
done

echo "Database connection established!"

# Run migrations to ensure database is up to date
echo "Running database migrations..."
php artisan migrate --force

# Run database seeders if needed
echo "Running database seeders..."
php artisan db:seed --force || echo "Seeders skipped (may already exist)"

# Clear and cache config for production
php artisan config:clear
php artisan config:cache

# Start Apache in foreground
echo "Starting Apache server on port 10000..."
exec apache2-foreground