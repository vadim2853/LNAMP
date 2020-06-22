#!/bin/sh
# server LNMAP
apt-get update && apt-get upgrade -y

# install nginx
apt-get install -y nginx
# replacement of configuration files nginx
rm -r /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/nginx.conf
cp -r ./conf/nginx/conf.d/ /etc/nginx/conf.d/
cp ./conf/nginx/nginx.conf /etc/nginx/nginx.conf

#install apache
apt-get install -y apache2 libapache2-mod-php
# replacement of configuration files apache
rm -r /etc/apache2/ports.conf /etc/apache2/mods-available/dir.conf /etc/apache2/apache2.conf
cp ./conf/apache/ports.conf /etc/apache2/ports.conf
cp ./conf/apache/apache2.conf /etc/apache2/apache2.conf
cp ./conf/apache/mods-available/dir.conf /etc/apache2/mods-available/dir.conf
#module management
a2dismod mpm_event
a2enmod mpm_prefork
a2enmod php7.2
a2enmod setenvif

# install mariadb
apt-get install -y mariadb-server
mysqladmin -u root password

#install php-fpm
apt-get install -y php php-fpm
apt-get install -y php-mysql php-mysqli

#install ftp-Server
apt-get install -y proftpd
ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=ftp --uid=33 --gid=33 --home=/var/www --shell=/usr/sbin/nologin
rm -r /etc/proftpd/proftpd.conf
cp ./conf/proftpd/proftpd.conf /etc/proftpd/proftpd.conf
cp ./conf/proftpd/custom.conf /etc/proftpd/conf.d/custom.conf


# paste site
rm -r /var/www/html
cp -r ./html /var/www/html
chmod -R 777 /var/www/html

# restart && enabled nginx, apache
systemctl enable apache2 mariadb php7.2-fpm proftpd
systemctl start apache2 mariadb php7.2-fpm
systemctl restart nginx php7.2-fpm proftpd
