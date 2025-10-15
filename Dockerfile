# Use PHP 8.2 with Apache
FROM php:8.2-apache

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
    libpq-dev \
    nodejs \
    npm \
    && docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    zip \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Install npm dependencies and build frontend assets
RUN npm install && npm run build

# Configure Apache VirtualHost and ServerName
RUN echo '<VirtualHost *:80>\n    ServerName localhost\n    DocumentRoot /var/www/html/public\n    <Directory /var/www/html/public>\n        AllowOverride All\n        Require all granted\n    </Directory>\n    ErrorLog ${APACHE_LOG_DIR}/error.log\n    CustomLog ${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Set global ServerName to suppress warnings
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Set proper permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache \
    && chmod -R 755 /var/www/html/public

# Create production environment file from example
RUN cp .env.example .env \
    && sed -i 's/APP_NAME=Laravel/APP_NAME="Laravel Jenkins Render App"/' .env \
    && sed -i 's/APP_ENV=local/APP_ENV=production/' .env \
    && sed -i 's/APP_DEBUG=true/APP_DEBUG=false/' .env \
    && sed -i 's|APP_URL=http://localhost|APP_URL=https://laravel-jenkins-render-app-1.onrender.com|' .env \
    && sed -i 's/LOG_CHANNEL=stack/LOG_CHANNEL=stderr/' .env \
    && sed -i 's/LOG_LEVEL=debug/LOG_LEVEL=info/' .env \
    && sed -i 's/SESSION_DRIVER=database/SESSION_DRIVER=file/' .env \
    && sed -i 's/CACHE_STORE=database/CACHE_STORE=file/' .env \
    && sed -i 's/QUEUE_CONNECTION=database/QUEUE_CONNECTION=sync/' .env \
    && echo "# Database temporarily disabled" >> .env

# Note: Using file-based sessions and cache for simplicity

# Generate application key only (no config caching to allow runtime env vars)
RUN php artisan key:generate

# Clear any existing cached configuration files
RUN rm -rf storage/framework/cache/data/* \
    && rm -rf storage/framework/sessions/* \
    && rm -rf storage/framework/views/* \
    && rm -rf bootstrap/cache/config.php \
    && rm -rf bootstrap/cache/routes.php \
    && rm -rf bootstrap/cache/services.php

# Expose port that Render expects (Apache runs on 80, but we'll configure it for Render)
EXPOSE 10000

# Configure Apache to listen on port 10000 for Render
RUN sed -i 's/Listen 80/Listen 10000/' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:10000>/' /etc/apache2/sites-available/000-default.conf

# Create a startup script
COPY docker-start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-start.sh

# Use Apache's standard foreground command
CMD ["/usr/local/bin/docker-start.sh"]
