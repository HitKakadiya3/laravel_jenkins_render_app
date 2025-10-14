#!/bin/bash

# Ensure database exists and is properly set up
if [ ! -f /var/www/html/database/database.sqlite ]; then
    echo "Creating SQLite database..."
    touch /var/www/html/database/database.sqlite
    chmod 664 /var/www/html/database/database.sqlite
    chown www-data:www-data /var/www/html/database/database.sqlite
fi

# Run migrations to ensure database is up to date
echo "Running database migrations..."
php artisan migrate --force

# Clear and cache config for production
php artisan config:clear
php artisan config:cache

# Start PHP built-in server on port 10000 (Render's default)
echo "Starting Laravel application on port 10000..."
exec php artisan serve --host=0.0.0.0 --port=10000