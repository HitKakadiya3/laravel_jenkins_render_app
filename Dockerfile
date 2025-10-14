# Use PHP 8.2 CLI for a lighter image suitable for web services
FROM php:8.2-cli

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    curl \
    nginx \
    sqlite3 \
    libsqlite3-dev \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_sqlite \
    zip \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy composer files first for better caching
COPY composer.json composer.lock* ./

# Install PHP dependencies
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copy application files
COPY . .

# Complete composer installation and optimize for production
RUN composer dump-autoload --optimize --classmap-authoritative --no-dev

# Set proper permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Copy production environment file
COPY .env.production .env

# Create database directory and file
RUN mkdir -p /var/www/html/database \
    && touch /var/www/html/database/database.sqlite \
    && chmod 664 /var/www/html/database/database.sqlite \
    && chown www-data:www-data /var/www/html/database/database.sqlite

# Generate application key and setup database
RUN php artisan key:generate \
    && php artisan migrate --force \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Expose port that Render expects
EXPOSE 10000

# Create a startup script
COPY docker-start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-start.sh

# Use the startup script
CMD ["/usr/local/bin/docker-start.sh"]
