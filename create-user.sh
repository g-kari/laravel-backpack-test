#!/bin/bash

# Create a user for accessing the admin panel
cd /var/www
php artisan backpack:user --name="Admin User" --email=admin@example.com --******