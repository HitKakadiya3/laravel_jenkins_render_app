#!/bin/bash

echo "=== MINIMAL LARAVEL STARTUP ==="
echo "Timestamp: $(date)"
echo "Working Directory: $(pwd)"

# Force file-based sessions by directly modifying .env
echo "Forcing file-based sessions..."
sed -i 's/SESSION_DRIVER=.*/SESSION_DRIVER=file/' .env
sed -i 's/CACHE_STORE=.*/CACHE_STORE=file/' .env
sed -i 's/QUEUE_CONNECTION=.*/QUEUE_CONNECTION=sync/' .env

# Show what we actually have in .env
echo "=== .env Configuration ==="
grep -E '^(SESSION_DRIVER|CACHE_STORE|QUEUE_CONNECTION)' .env
echo "=========================="

# Clear ALL caches
echo "Clearing all caches..."
rm -rf storage/framework/cache/* 2>/dev/null || true
rm -rf storage/framework/sessions/* 2>/dev/null || true
rm -rf storage/framework/views/* 2>/dev/null || true
rm -rf bootstrap/cache/* 2>/dev/null || true

# Force clear any potential opcache
php -r "if (function_exists('opcache_reset')) { opcache_reset(); echo 'OPCache cleared'; }"

# Delete and recreate config cache to force reload
rm -f bootstrap/cache/config.php
rm -f bootstrap/cache/services.php
rm -f bootstrap/cache/packages.php

# Show actual config file contents
echo "=== Config File Contents ==="
echo "session.php driver line:"
grep "'driver'" config/session.php || echo "Not found"
echo "cache.php default line:"
grep "'default'" config/cache.php || echo "Not found"
echo "============================="

# Test Laravel config
echo "Testing Laravel configuration..."
php -r "
require 'vendor/autoload.php';
\$app = require_once 'bootstrap/app.php';
\$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();
echo 'Session Driver: ' . config('session.driver') . PHP_EOL;
echo 'Cache Store: ' . config('cache.default') . PHP_EOL;
"

# Set proper permissions
echo "Setting permissions..."
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Start Apache
echo "Starting Apache on port 10000..."
echo "Checking Apache configuration..."
apache2ctl configtest

echo "Verifying Apache ports configuration..."
grep -n "Listen" /etc/apache2/ports.conf
grep -n "VirtualHost" /etc/apache2/sites-available/000-default.conf

echo "Checking if files exist in public directory..."
ls -la /var/www/html/public/

echo "Starting Apache in foreground..."
exec apache2-foreground