FROM php:8.2-cli

# Set working directory
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
    gnupg \
    && docker-php-ext-install pdo pdo_sqlite zip intl

# ✅ Install Node.js (for Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# ✅ Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy project files
COPY . .

# Install Laravel dependencies
RUN composer install --no-interaction --optimize-autoloader --ignore-platform-reqs

# Set environment file
COPY .env.example .env

# Generate Laravel app key
RUN php artisan key:generate
RUN php artisan config:clear

# ✅ Frontend build using Vite
RUN npm install
RUN npm run build

# Run database migrations
RUN php artisan migrate --force

# Expose port Render expects
EXPOSE 10000

# Start Laravel app
CMD php artisan serve --host=0.0.0.0 --port=10000
