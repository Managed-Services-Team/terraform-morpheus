#! /bin/bash
sudo apt-get update
mkdir /var/www/html
sudo apt-get install -y apache2 mariadb-server php libapache2-mod-php php-mcrypt php-mysql
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl start mysql
sudo systemctl enable mysql
echo "<?php>phpinfo();</>" | sudo tee /var/www/html/index.php
