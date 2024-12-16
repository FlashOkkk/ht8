#!/bin/bash

# Оновлення системи
yum update -y || apt update -y
yum install -y httpd || apt install -y apache2

# Запуск і автозапуск Apache
systemctl start httpd || systemctl start apache2
systemctl enable httpd || systemctl enable apache2

# Створення простого веб-сайту
echo "<html><h1>Welcome to My Website</h1><p>This is hometask 8 Apache2 server with HTTPS</p></html>" > /var/www/html/index.html

# Генерація самопідписаного сертифіката
mkdir -p /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=UA/ST=Zhytomyr/L=Zhytomyr/O=MyCompany/OU=IT/CN=example.com"

# Налаштування Apache для використання HTTPS
if [ -f /etc/httpd/conf.d/ssl.conf ]; then
  echo "
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
" > /etc/httpd/conf.d/ssl.conf
else
  echo "
<VirtualHost *:443>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
</VirtualHost>
" > /etc/apache2/sites-available/default-ssl.conf

  a2enmod ssl
  a2ensite default-ssl.conf
fi

# Перезапуск Apache
systemctl restart httpd || systemctl restart apache2
