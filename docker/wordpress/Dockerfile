FROM wordpress:6.5-php8.3-fpm

# Install WP-CLI.
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Install some MySQL client tools that WP CLI uses under the hood (as part of wp db).
RUN apt-get update && \
	apt-get install -y default-mysql-client && \
	rm -rf /var/lib/apt/lists/*
