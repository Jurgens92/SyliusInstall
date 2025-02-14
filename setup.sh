#!/bin/bash

# Exit on error
set -e

# Variables - MODIFY THESE
PROJECT_NAME="my-sylius-project"
PROJECT_PATH="/var/www/$PROJECT_NAME"
DOMAIN="your-domain.com"
DB_USER="sylius"
DB_PASSWORD="your_password"
DB_NAME="sylius"

# Function to check if command succeeded
check_command() {
   if [ $? -ne 0 ]; then
       echo "Error: $1 failed"
       exit 1
   fi
}

# Function to print section headers
print_section() {
   echo "----------------------------------------"
   echo "$1"
   echo "----------------------------------------"
}

print_section "Starting Sylius Installation"

# Update system
print_section "Updating System"
sudo apt update && sudo apt upgrade -y
check_command "System update"

# Add PHP repository
print_section "Adding PHP Repository"
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
check_command "PHP repository addition"

# Install PHP and required extensions
print_section "Installing PHP and Extensions"
sudo apt install -y php8.2 php8.2-common php8.2-cli php8.2-fpm \
   php8.2-intl php8.2-gd php8.2-curl php8.2-mbstring \
   php8.2-xml php8.2-zip php8.2-mysql
check_command "PHP installation"

# Install MySQL
print_section "Installing MySQL"
sudo apt install -y mysql-server
check_command "MySQL installation"

# Secure MySQL installation
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
check_command "MySQL configuration"

# Install Composer
print_section "Installing Composer"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
check_command "Composer installation"

# Install Node.js and Yarn
print_section "Installing Node.js and Yarn"
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g yarn
check_command "Node.js and Yarn installation"

# Install Nginx
print_section "Installing Nginx"
sudo apt install -y nginx
check_command "Nginx installation"

# Create Sylius project
print_section "Creating Sylius Project"
cd /var/www
composer create-project sylius/sylius-standard $PROJECT_NAME
check_command "Sylius project creation"

# Configure Nginx
print_section "Configuring Nginx"
sudo tee /etc/nginx/sites-available/sylius << EOL
server {
   listen 80;
   server_name $DOMAIN;
   root $PROJECT_PATH/public;

   location / {
       try_files \$uri /index.php\$is_args\$args;
   }

   location ~ ^/index\.php(/|$) {
       fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
       fastcgi_split_path_info ^(.+\.php)(/.*)$;
       include fastcgi_params;
       fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
       fastcgi_param DOCUMENT_ROOT \$realpath_root;
       internal;
   }

   location ~ \.php$ {
       return 404;
   }

   error_log /var/log/nginx/sylius_error.log;
   access_log /var/log/nginx/sylius_access.log;
}
EOL

# Enable Nginx configuration
sudo ln -sf /etc/nginx/sites-available/sylius /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
check_command "Nginx configuration"

# Configure environment
print_section "Configuring Environment"
cd $PROJECT_PATH
cp .env .env.local
sed -i "s#DATABASE_URL=.*#DATABASE_URL=mysql://$DB_USER:$DB_PASSWORD@127.0.0.1:3306/$DB_NAME#g" .env.local
check_command "Environment configuration"

# Install dependencies and build assets
print_section "Installing Dependencies and Building Assets"
composer install
check_command "Composer dependencies installation"
yarn install
check_command "Yarn dependencies installation"
yarn build
check_command "Asset building"

# Set permissions
print_section "Setting Permissions"
sudo chown -R www-data:www-data $PROJECT_PATH
sudo chmod -R 755 $PROJECT_PATH
sudo chmod -R 777 $PROJECT_PATH/var/cache
sudo chmod -R 777 $PROJECT_PATH/var/log
sudo chmod -R 777 $PROJECT_PATH/public/media
check_command "Permission setting"

# Setup database and load fixtures
print_section "Setting up Database"
cd $PROJECT_PATH
php bin/console doctrine:database:create --if-not-exists
check_command "Database creation"
php bin/console doctrine:migrations:migrate --no-interaction
check_command "Database migration"
php bin/console sylius:fixtures:load --no-interaction
check_command "Fixtures loading"

print_section "Installation Complete!"
echo "Your Sylius installation is available at: http://$DOMAIN"
echo "Admin panel: http://$DOMAIN/admin"
echo "Default admin credentials:"
echo "Username: sylius@example.com"
echo "Password: sylius"
echo ""
echo "Please change the admin credentials after logging in!"
echo "Don't forget to set up SSL/HTTPS for production use."
