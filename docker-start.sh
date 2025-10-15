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

# Debug: Show all database-related environment variables
echo "=== Environment Variables Debug ==="
env | grep -E '^(DB_|DATABASE_|SESSION_|CACHE_)' | sort

# Clear any cached configuration to ensure environment variables are used
echo "Clearing cached configuration..."
php artisan config:clear
php artisan cache:clear

# Wait for database to be available (PostgreSQL)
echo "Waiting for database connection..."
until php artisan tinker --execute="DB::connection()->getPdo();" 2>/dev/null; do
    echo "Database not yet available, waiting 2 seconds..."
    sleep 2
done

echo "Database connection established!"

# Test database write permissions
echo "Testing database write permissions..."
php artisan tinker --execute="try { DB::statement('CREATE TABLE test_table_temp (id int)'); DB::statement('DROP TABLE test_table_temp'); echo 'Database write permissions: OK'; } catch (Exception \$e) { echo 'Database write error: ' . \$e->getMessage(); }"

# Debug: Show current database configuration
echo "=== Database Debug Information ==="
php artisan tinker --execute="echo 'Database: ' . config('database.default'); echo 'Connection: ' . config('database.connections.' . config('database.default') . '.driver');"

# Check if database is empty (first deployment)
echo "Checking existing tables..."
php artisan tinker --execute="try { \$tables = DB::select('SELECT name FROM sqlite_master WHERE type=\"table\"'); echo 'SQLite tables found: ' . count(\$tables); } catch (Exception \$e) { try { \$tables = DB::select('SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname = \"public\"'); echo 'PostgreSQL tables found: ' . count(\$tables); } catch (Exception \$e2) { echo 'Could not check tables: ' . \$e2->getMessage(); } }"

# Run migrations to ensure database is up to date
echo "Running database migrations..."
php artisan migrate --force --verbose

# Verify sessions table was created
echo "Verifying sessions table exists..."
php artisan tinker --execute="try { DB::table('sessions')->count(); echo 'Sessions table exists and accessible'; } catch (Exception \$e) { echo 'Sessions table error: ' . \$e->getMessage(); }"

# Run database seeders if needed
echo "Running database seeders..."
php artisan db:seed --force || echo "Seeders skipped (may already exist)"

# Clear and cache config for production
php artisan config:clear
php artisan config:cache

# Start Apache in foreground
echo "Starting Apache server on port 10000..."
exec apache2-foreground