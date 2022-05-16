#!/bin/sh
# Set desired PHP_FCGI_* environment variables
PHP_FCGI_MAX_REQUESTS=1000
export PHP_FCGI_MAX_REQUESTS

# The path to your FastCGI-enabled PHP executable
exec /usr/bin/php-cgi