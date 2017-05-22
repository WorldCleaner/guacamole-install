#!/bin/bash

VERSION="0.9.12"

# Server installieren
apt-get update
apt-get -y install build-essential libcairo2-dev libjpeg-turbo8-dev libpng12-dev libossp-uuid-dev libavcodec-dev libavutil-dev \
libswscale-dev libfreerdp-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev \
libvorbis-dev libwebp-dev jq tomcat8 freerdp

SERVER=$(curl -s 'https://www.apache.org/dyn/closer.cgi?as_json=1' | jq --raw-output '.preferred|rtrimstr("/")')

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
echo "[server]" >> /etc/guacamole/guacd.conf
echo "bind_host = localhost" >> /etc/guacamole/guacd.conf
echo "bind_port = 4822" >> /etc/guacamole/guacd.conf

# guacd enable & start
systemctl enable guacd
systemctl start guacd

# Cleanup
rm -rf guacamole-*
