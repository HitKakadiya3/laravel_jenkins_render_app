#!/bin/bash

echo "=== Laravel Render Startup Script ==="
echo "Timestamp: $(date)"
echo "Working Directory: $(pwd)"
echo "User: $(whoami)"
echo "PHP Version: $(php --version | head -n 1)"

# Basic environment setup - minimal configuration
echo "Setting up minimal environment..."
export APP_ENV=production
export APP_DEBUG=false
export SESSION_DRIVER=file
export CACHE_STORE=file
export QUEUE_CONNECTION=sync
export LOG_CHANNEL=stderr

echo "Environment variables set:"
echo "  APP_ENV: $APP_ENV"
echo "  SESSION_DRIVER: $SESSION_DRIVER"
echo "  CACHE_STORE: $CACHE_STORE"

# Test basic PHP functionality
echo "Testing basic PHP..."
php -r "echo 'PHP is working: ' . date('Y-m-d H:i:s') . PHP_EOL;"

# Test Laravel bootstrap
echo "Testing Laravel bootstrap..."
if php artisan --version; then
    echo "✅ Laravel artisan is working"
else
    echo "❌ Laravel artisan failed"
    exit 1
fi

# Show actual .env file content for debugging
echo "=== .env File Content (relevant lines) ==="
grep -E '^(APP_|SESSION_|CACHE_|DB_|QUEUE_)' .env || echo "No relevant config found"
echo "=========================================="

# Test Laravel configuration reading BEFORE clearing cache
echo "Testing Laravel configuration (before cache clear)..."
php artisan tinker --execute="echo 'Session Driver: ' . config('session.driver'); echo 'Cache Store: ' . config('cache.default');" || echo "Config test failed"

# Clear any cached configuration
echo "Clearing cached configuration..."
php artisan config:clear || echo "Config clear failed"
php artisan cache:clear || echo "Cache clear failed"

# Force clear all cache files manually
rm -rf storage/framework/cache/data/* 2>/dev/null || true
rm -rf storage/framework/sessions/* 2>/dev/null || true  
rm -rf storage/framework/views/* 2>/dev/null || true
rm -rf bootstrap/cache/* 2>/dev/null || true

# Explicitly override session driver to file
echo "Forcing session driver to file..."
export SESSION_DRIVER=file
export CACHE_STORE=file
export QUEUE_CONNECTION=sync

# Verify the environment variables are set
echo "Environment variable check:"
echo "  SESSION_DRIVER: $SESSION_DRIVER"
echo "  CACHE_STORE: $CACHE_STORE"

# Test Laravel configuration reading AFTER clearing cache and setting env vars
echo "Testing Laravel configuration (after cache clear and env override)..."
php artisan tinker --execute="echo 'Session Driver: ' . config('session.driver'); echo 'Cache Store: ' . config('cache.default');" || echo "Config test failed"

# Test route loading
echo "Testing route loading..."
php artisan route:list --compact || echo "Route list failed"

# Test route loading
echo "Testing route loading..."
php artisan route:list --compact || echo "Route list failed"

# Skip database operations for now - just get Laravel working
echo "⚠️  Skipping database operations to focus on basic Laravel functionality"

# Set proper permissions
echo "Setting file permissions..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Final configuration
echo "=== Final Startup Configuration ==="
echo "SESSION_DRIVER: $SESSION_DRIVER"
echo "CACHE_STORE: $CACHE_STORE"
echo "APP_ENV: $APP_ENV"
echo "Log Channel: $LOG_CHANNEL"
echo "========================================="

# Test Apache configuration
echo "Testing Apache configuration..."
apache2ctl configtest

# Start Apache in foreground
echo "🚀 Starting Apache server on port 10000..."
echo "🔗 Health check will be available at: /health"
echo "🔗 Simple test will be available at: /test"
exec apache2-foreground