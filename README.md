# Sylius E-commerce Installation Script
This script automates the installation process of Sylius e-commerce platform on Ubuntu 24.04 server.
Features

## Complete automated installation of Sylius and all dependencies
PHP 8.2 setup with required extensions
MySQL database configuration
Nginx web server setup
Node.js and Yarn installation
Proper permissions configuration
Sample data loading

## Prerequisites

Ubuntu 24.04 server
Root or sudo access
Clean system (fresh installation recommended)

## Installation

Clone this repository:
git clone https://github.com/Jurgens92/SyliusInstall.git
cd syliusinstall

## Edit the configuration variables in setup.sh:

PROJECT_NAME="my-sylius-project"
PROJECT_PATH="/var/www/$PROJECT_NAME"
DOMAIN="your-domain.com"
DB_USER="sylius"
DB_PASSWORD="your_password"
DB_NAME="sylius"

## Make the script executable:
chmod +x setup.sh

## Run the installation script:
sudo ./setup.sh

## What the Script Does

System Updates

Updates package lists
Upgrades installed packages


## Installs Required Software

PHP 8.2 and extensions
MySQL Server
Nginx
Composer
Node.js and Yarn


## Configures Services

Sets up MySQL database
Configures Nginx virtual host
Sets proper file permissions
Installs Sylius dependencies


## Installs Sylius

Creates new Sylius project
Sets up database
Loads sample data
Configures environment



## Default Access
After installation:

Frontend: http://your-domain.com
Admin panel: http://your-domain.com/admin
Default admin credentials:

Username: sylius@example.com
Password: sylius


## Post-Installation

Change the default admin credentials
Configure SSL/HTTPS for production use
Review and adjust file permissions if needed
Configure backup solutions

## Troubleshooting
If you encounter issues:

Check Nginx error logs: /var/log/nginx/error.log
Check Sylius error logs: /var/www/my-sylius-project/var/log/
Verify PHP-FPM is running: systemctl status php8.2-fpm
Ensure database connectivity: mysql -u sylius -p

## Contributing

Fork the repository
Create your feature branch
Commit your changes
Push to the branch
Create a new Pull Request
