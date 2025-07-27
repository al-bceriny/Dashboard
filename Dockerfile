FROM php:8.2-cli

WORKDIR /var/www

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    libzip-dev \
    zip \
    sqlite3 \
    libsqlite3-dev \
    libicu-dev \
    && docker-php-ext-install pdo pdo_sqlite zip intl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy project files
COPY . .

# Install Laravel dependencies
RUN composer install --no-interaction --optimize-autoloader --ignore-platform-reqs

# Set environment file
COPY .env.example .env

# Generate app key
# RUN php artisan key:generate
# RUN php artisan config:clear



# Frontend build
RUN npm install
RUN npm run build

RUN php artisan migrate --force

# Expose the port Render expects
EXPOSE 10000

# Start the Laravel server
CMD php artisan serve --host=0.0.0.0 --port=10000
