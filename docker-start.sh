#!/bin/bash

# Ensure environment variables override .env file for database configuration
echo "Configuring environment for production..."

# TEMPORARY: Use file sessions to avoid database issues
export SESSION_DRIVER=${SESSION_DRIVER:-file}
export CACHE_STORE=${CACHE_STORE:-file}
export DB_CONNECTION=${DB_CONNECTION:-pgsql}

echo "Database configuration:"
echo "  DB_CONNECTION: $DB_CONNECTION"
echo "  DATABASE_URL: ${DATABASE_URL:0:50}..."
echo "  SESSION_DRIVER: $SESSION_DRIVER (temporary file-based)"
echo "  CACHE_STORE: $CACHE_STORE (temporary file-based)"

# Debug: Show all database-related environment variables
echo "=== Environment Variables Debug ==="
env | grep -E '^(DB_|DATABASE_|SESSION_|CACHE_)' | sort

# Clear any cached configuration to ensure environment variables are used
echo "Clearing cached configuration..."
php artisan config:clear
php artisan cache:clear

# Wait for database to be available (PostgreSQL)
echo "Waiting for database connection..."
DB_CONNECTED=false
for i in {1..30}; do
    if php artisan tinker --execute="DB::connection()->getPdo();" 2>/dev/null; then
        echo "Database connection established!"
        DB_CONNECTED=true
        break
    else
        echo "Database not yet available, attempt $i/30, waiting 2 seconds..."
        sleep 2
    fi
done

if [ "$DB_CONNECTED" = false ]; then
    echo "⚠️  WARNING: Database connection failed after 60 seconds"
    echo "⚠️  Starting app without database-dependent features"
    echo "⚠️  Using file-based sessions and cache"
    export SESSION_DRIVER=file
    export CACHE_STORE=file
    export QUEUE_CONNECTION=sync
else
    echo "✅ Database connection successful"
fi

# Test database write permissions
echo "Testing database write permissions..."
php artisan tinker --execute="try { DB::statement('CREATE TABLE test_table_temp (id int)'); DB::statement('DROP TABLE test_table_temp'); echo 'Database write permissions: OK'; } catch (Exception \$e) { echo 'Database write error: ' . \$e->getMessage(); }"

# Debug: Show current database configuration
echo "=== Database Debug Information ==="
php artisan tinker --execute="echo 'Database: ' . config('database.default'); echo 'Connection: ' . config('database.connections.' . config('database.default') . '.driver');"

# Check if database is empty (first deployment)
echo "Checking existing tables..."
php artisan tinker --execute="try { \$tables = DB::select('SELECT name FROM sqlite_master WHERE type=\"table\"'); echo 'SQLite tables found: ' . count(\$tables); } catch (Exception \$e) { try { \$tables = DB::select('SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname = \"public\"'); echo 'PostgreSQL tables found: ' . count(\$tables); } catch (Exception \$e2) { echo 'Could not check tables: ' . \$e2->getMessage(); } }"

# Run migrations only if database is connected
if [ "$DB_CONNECTED" = true ]; then
    echo "Running database migrations..."
    php artisan migrate --force --verbose

    # Verify sessions table was created (only if using database sessions)
    if [ "$SESSION_DRIVER" = "database" ]; then
        echo "Verifying sessions table exists..."
        php artisan tinker --execute="try { DB::table('sessions')->count(); echo 'Sessions table exists and accessible'; } catch (Exception \$e) { echo 'Sessions table error: ' . \$e->getMessage(); }"
    fi

    # Run database seeders if needed
    echo "Running database seeders..."
    php artisan db:seed --force || echo "Seeders skipped (may already exist)"
else
    echo "⚠️  Skipping migrations - database not available"
fi

# Clear and cache config for production
php artisan config:clear
php artisan config:cache

# Final configuration summary
echo "=== Final Application Configuration ==="
echo "SESSION_DRIVER: $SESSION_DRIVER"
echo "CACHE_STORE: $CACHE_STORE"
echo "DB_CONNECTION: $DB_CONNECTION"
echo "Database Connected: $DB_CONNECTED"
echo "========================================="

# Start Apache in foreground
echo "Starting Apache server on port 10000..."
exec apache2-foreground