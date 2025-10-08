FROM php:8.2-fpm

WORKDIR /var/www

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev curl \
    && docker-php-ext-install pdo pdo_mysql zip mbstring exif pcntl bcmath gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY . .

RUN composer install --no-dev --optimize-autoloader

# Use Render's dynamic PORT environment variable
CMD ["sh", "-c", "php artisan serve --host=0.0.0.0 --port=${PORT:-8080}"]
