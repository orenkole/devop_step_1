#!/bin/bash -xe
export DEBIAN_FRONTEND=noninteractive

sudo apt update
sudo apt install -y mysql-server
sudo sed -i 's/bind-address.*/bind-address = 192.168.45.102/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

mysql -u root -p${DB_ROOT_PASS} -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_ROOT_PASS}';"
mysql -u root -p${DB_ROOT_PASS} -e "CREATE DATABASE ${DB_NAME};"
mysql -u root -p${DB_ROOT_PASS} -e "CREATE USER '${DB_USER}'@'192.168.45.%' IDENTIFIED BY '${DB_PASS}';"
mysql -u root -p${DB_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'192.168.45.%';"
mysql -u root -p${DB_ROOT_PASS} -e "FLUSH PRIVILEGES;"