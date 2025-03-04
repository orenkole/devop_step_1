#!/bin/bash

sudo useradd -m -s /bin/bash "${APP_USER}"
sudo usermod -aG sudo "${APP_USER}"
echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-app-user > /dev/null
sudo apt update
sudo apt install -y openjdk-21-jre-headless maven mysql-client
sudo chown -R "${APP_USER}:${APP_USER}" "${PROJECT_DIR}"
sudo chmod -R 755 "${PROJECT_DIR}"
cd "${PROJECT_DIR}" || { echo "Project directory not found"; exit 1; }
chmod +x mvnw
./mvnw -B clean test package
sudo mkdir -p "/home/${APP_USER}/${APP_DIR}"
sudo chown -R "${APP_USER}:${APP_USER}" "/home/${APP_USER}/${APP_DIR}"
sudo cp target/*-petclinic-*.jar "/home/${APP_USER}/${APP_DIR}/"
JAR_FILE=$(sudo find "/home/${APP_USER}/${APP_DIR}" -type f -name "*.jar" | head -n 1)
sudo -u "${APP_USER}" bash -c "cd /home/${APP_USER}/${APP_DIR} && java -jar ${JAR_FILE}"
mysql -h "${DB_HOST}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}"