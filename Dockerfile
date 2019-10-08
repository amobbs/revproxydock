FROM php:7.2-fpm

# Copy composer.lock and composer.json and package.json
COPY composer.lock composer.json package.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    default-mysql-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

#Install node, NPM, Vue and Yarn
RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash -
RUN apt-get -y install nodejs
RUN npm install cross-env -g
RUN npm install vue 
RUN npm install vue-router
RUN npm install webpack

#RUN npm install -g @vue/cli

#RUN yarn
RUN npm install


# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer



# Copy existing application directory contents
COPY . /var/www

RUN chmod 775 -R storage


#Map Local Computer User to Docker user www-data
ARG MAINUSERID
RUN usermod -u $MAINUSERID www-data

# Change current user to www-data
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
