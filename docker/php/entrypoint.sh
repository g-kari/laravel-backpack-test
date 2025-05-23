#!/bin/bash

# Change ownership if laravel files exist
if [ -d "/var/www/app" ]; then
    chown -R www:www /var/www
fi

# Start supervisor
if [ -f "/etc/supervisor/conf.d/supervisor.conf" ]; then
    supervisord -c /etc/supervisor/supervisord.conf
fi

# Execute the original command
exec "$@"