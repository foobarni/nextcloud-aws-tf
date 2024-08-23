#!/bin/bash
set -e

# Create nextcloud directory
mkdir -p /home/ubuntu/nextcloud
cd /home/ubuntu/nextcloud

# Generate environment variables

# Variables passed from Terraform
EMAIL="${email}"
DOMAIN_NAME="${domain_name}"
NEXTCLOUD_ADMIN_USER="${aws_cli_profile}"

generate_password() {
    openssl rand -base64 16
}

MYSQL_ROOT_PASSWORD=$(generate_password)
MYSQL_PASSWORD=$(generate_password)
MYSQL_DATABASE=nextcloud_db
MYSQL_USER=nextcloud_user
MYSQL_HOST=db

NEXTCLOUD_ADMIN_PASSWORD=$(generate_password)

# Write environment variables to file
cat <<EOF > .env.nextcloud
# Environment variables for Nextcloud setup
EMAIL=$EMAIL
DOMAIN_NAME=$DOMAIN_NAME

MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_USER=$MYSQL_USER
MYSQL_HOST=$MYSQL_HOST

NEXTCLOUD_ADMIN_USER=$NEXTCLOUD_ADMIN_USER
NEXTCLOUD_ADMIN_PASSWORD=$NEXTCLOUD_ADMIN_PASSWORD
NEXTCLOUD_TRUSTED_DOMAINS=$DOMAIN_NAME
EOF

# Install Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Docker Compose if it's not included in the Docker package
if ! command -v docker-compose &> /dev/null; then
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

sudo usermod -aG docker ubuntu

# Create docker-compose.yaml
cat <<EOF > docker-compose.yaml
volumes:
  nextcloud:
  db:

services:
  db:
    image: mariadb:10.6
    restart: always
    command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
    volumes:
      - db:/var/lib/mysql
    env_file:
      - .env.nextcloud

  app:
    image: nextcloud:apache
    restart: always
    volumes:
      - nextcloud:/var/www/html
    env_file:
      - .env.nextcloud
    depends_on:
      - db

  web:
    image: nginx:alpine
    restart: always
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./nextcloud.conf:/etc/nginx/conf.d/default.conf
      - /etc/letsencrypt:/etc/letsencrypt:ro
    env_file:
      - .env.nextcloud
    depends_on:
      - app
EOF

# Create nextcloud.conf
cat <<EOF > nextcloud.conf
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN_NAME;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;
    server_name $DOMAIN_NAME;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;

    location / {
        proxy_pass http://app:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        client_max_body_size 10G;
        client_body_buffer_size 400M;
        proxy_read_timeout 3600;
        proxy_connect_timeout 3600;
        proxy_send_timeout 3600;
        proxy_request_buffering off;
        proxy_buffering off;
    }
}
EOF

# Install certbot and generate standalone certificate
sudo apt-get install -y software-properties-common certbot
sudo certbot certonly --standalone -d "$DOMAIN_NAME" --non-interactive --agree-tos -m "$EMAIL"

# Spin up nextcloud
sudo docker-compose up -d

echo "Nextcloud setup is complete! Access your instance at: https://$DOMAIN_NAME"
echo "--------------------------------------"
echo "Admin credentials:"
echo "Username: $NEXTCLOUD_ADMIN_USER"
echo "Password: $NEXTCLOUD_ADMIN_PASSWORD"
echo "--------------------------------------"

