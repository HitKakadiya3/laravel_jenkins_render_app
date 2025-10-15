#!/bin/bash

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