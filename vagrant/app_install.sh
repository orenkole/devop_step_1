#!/bin/bash

sudo useradd -m -s /bin/bash "${APP_USER}"
sudo usermod -aG sudo "${APP_USER}"
echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-app-user > /dev/null
sudo apt update
sudo apt install -y openjdk-21-jre-headless maven mysql-client
cd "${PROJECT_DIR}" || { echo "Project directory not found"; exit 1; }
chmod +x mvnw
./mvnw clean test package
sudo mkdir -p "/home/${APP_USER}/${APP_DIR}"
sudo cp target/*-petclinic-*.jar "/home/${APP_USER}/${APP_DIR}/"
JAR_FILE=$(sudo find "/home/${APP_USER}/${APP_DIR}" -type f -name "*.jar" | head -n 1)
sudo -u "${APP_USER}" java -jar "${JAR_FILE}"
mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASS}"