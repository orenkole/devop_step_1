#!/bin/bash
sudo useradd -m -s /bin/bash "${APP_USER}"
sudo usermod -aG sudo "${APP_USER}"
sudo echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-app-user
sudo su "${APP_USER}"
sudo apt update
sudo apt install -y openjdk-21-jre-headless
sudo apt install -y maven
sudo apt install -y mysql-client
cd PROJECT_DIR
chmod +x mvnw
echo "export MYSQL_URL=jdbc:mysql://192.168.45.102:3306/app_db" | sudo tee -a /etc/environment
echo "export MYSQL_USER=dbuser" | sudo tee -a /etc/environment
echo "export MYSQL_PASS=dbpassword" | sudo tee -a /etc/environment
./mvnw clean test package
sudo mkdir /home/${APP_USER}/APP_DIR
sudo cp target/*-petclinic-*.jar /home/${APP_USER}/APP_DIR/
JAR_FILE=$(sudo find /home/${APP_USER}/APP_DIR -type f -name "*.jar")
sudo java -jar ${JAR_FILE}
mysql -h 192.168.45.102 -P 3306 -u ${MYSQL_USER} -p${MYSQL_PASS}
