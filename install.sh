#!/bin/bash

VERSION="0.9.12"

# Server installieren
apt-get update
apt-get -y install build-essential libcairo2-dev libjpeg-turbo8-dev libpng12-dev libossp-uuid-dev libavcodec-dev libavutil-dev \
libswscale-dev libfreerdp-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev \
libvorbis-dev libwebp-dev jq tomcat8 freerdp

SERVER=$(curl -s 'https://www.apache.org/dyn/closer.cgi?as_json=1' | jq --raw-output '.preferred|rtrimstr("/")')

# Serverconfig
echo "" >> /etc/default/tomcat8
echo "# GUACAMOLE EVN VARIABLE" >> /etc/default/tomcat8
echo "GUACAMOLE_HOME=/etc/guacamole" >> /etc/default/tomcat8

# Download der Dateien
wget ${SERVER}/incubator/guacamole/${VERSION}-incubating/source/guacamole-server-${VERSION}-incubating.tar.gz

# Entpacken
tar -xzf guacamole-server-${VERSION}-incubating.tar.gz

# Ordner erstellen
mkdir /etc/guacamole

# GUACD installieren
cd guacamole-server-${VERSION}-incubating
./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
cd ..

# Guacamole deployen
mv guacamole-${VERSION}-incubating.war /etc/guacamole/guacamole.war
ln -s /etc/guacamole/guacamole.war /var/lib/tomcat8/webapps/
ln -s /usr/local/lib/freerdp/* /usr/lib/x86_64-linux-gnu/freerdp/.

# restart tomcat
service tomcat8 restart

# Configs guacamole.properties anpassen
echo "[server]" >> /etc/guacamole/guacamole.properties
echo "bind_host = localhost" >> /etc/guacamole/guacamole.properties
echo "bind_port = 4822" >> /etc/guacamole/guacamole.properties

#guacd.conf

# guacd enable & start
systemctl enable guacd
systemctl start guacd

# Cleanup
rm -rf guacamole-*




# Test automatische konfiguration Apache & Reverse Proxy

# sudo apt-get install apache2 openssl -y
# sudo a2enmod ssl
# sudo a2enmod proxy
# sudo a2enmod proxy_wstunnel
# sudo a2enmod proxy_http
# weitere mods

# sudo rm /etc/apache2/sites-enabled/000-default.conf
# sudo touch /etc/apache2/sites-enabled/000-default.conf
# echo "<VirutalHost *:80>" >> /etc/apache2/sites-enabled/000-default.conf
# echo "ServerName mydomain.de" >> /etc/apache2/sites-enabled/000-default.conf
# echo "Redirect permanent / https://mydomain.de/" >> /etc/apache2/sites-enabled/000-default.conf
# echo "</VirtualHost>" >> /etc/apache2/sites-enabled/000-default.conf

# echo "<VirutalHost *:443>" >> /etc/apache2/sites-enabled/000-default.conf
# echo "</VirutalHost>" >> /etc/apache2/sites-enabled/000-default.conf

# mkdir /etc/apache2/ssl
# openssl req -new -days 1095 -newkey rsa:4096bits -sha512 -x509 -nodes -out /etc/apache2/server.crt -keyout /etc/apache2/server.key
