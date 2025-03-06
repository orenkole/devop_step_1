#!/bin/bash

# Create user if it doesn't exist
if ! id "${APP_USER}" &>/dev/null; then
  sudo useradd -m -s /bin/bash "${APP_USER}"
  sudo usermod -aG sudo "${APP_USER}"
  echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/90-app-user > /dev/null
fi

# Install dependencies
sudo apt update
sudo apt install -y openjdk-21-jre-headless maven mysql-client

# Ensure project directory exists and fix permissions
if [ ! -d "${PROJECT_DIR}" ]; then
  echo "Error: ${PROJECT_DIR} does not exist!"
  exit 1
fi
sudo chown -R "${APP_USER}:${APP_USER}" "${PROJECT_DIR}"
sudo chmod -R 755 "${PROJECT_DIR}"

# Build the application
cd "${PROJECT_DIR}" || { echo "Project directory not found"; exit 1; }
chmod +x mvnw
./mvnw -B clean test package

# Set up application directory
sudo mkdir -p "/home/${APP_USER}/${APP_DIR}"
sudo chown -R "${APP_USER}:${APP_USER}" "/home/${APP_USER}/${APP_DIR}"

# Copy JAR file
sudo cp target/*-petclinic-*.jar "/home/${APP_USER}/${APP_DIR}/"

# Run application if JAR exists
JAR_FILE=$(sudo find "/home/${APP_USER}/${APP_DIR}" -type f -name "*.jar" | head -n 1)
if [[ -f "$JAR_FILE" ]]; then
  sudo -u "${APP_USER}" java -jar "$JAR_FILE"
else
  echo "Error: No JAR file found in /home/${APP_USER}/${APP_DIR}"
  exit 1
fi
