#!/bin/sh
# server LNMAP

# conf install skript
echo select DB name
read db_name
echo select DB user $db_name
read db_user
echo select DB user password $db_user
read db_pass
echo create ftp-user
read ftp_user

#update system
apt-get update && apt-get upgrade -y
apt-get install -y wget

# install nginx
apt-get install -y nginx
# replacement of configuration files nginx
rm -r /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/nginx.conf
cp -r ./conf/nginx/conf.d/ /etc/nginx/
cp ./conf/nginx/nginx.conf /etc/nginx/nginx.conf

# install apache
apt-get install -y apache2 libapache2-mod-php
# replacement of configuration files apache
rm -r /etc/apache2/ports.conf /etc/apache2/mods-available/dir.conf /etc/apache2/apache2.conf
cp ./conf/apache/ports.conf /etc/apache2/ports.conf
cp ./conf/apache/apache2.conf /etc/apache2/apache2.conf
cp ./conf/apache/mods-available/dir.conf /etc/apache2/mods-available/dir.conf
# module management
a2dismod mpm_event
a2enmod mpm_prefork
a2enmod php7.2
a2enmod setenvif

# install mariadb && create DB
apt-get install -y mariadb-server
mysql -u root << EOF
CREATE DATABASE $db_name DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON $db_name.* TO $db_user@localhost IDENTIFIED BY '$db_pass' WITH GRANT OPTION;
EOF

# install php-fpm
apt-get install -y php php-fpm
apt-get install -y php-mysql php-mysqli

# install ftp-Server
apt-get install -y proftpd
ftpasswd --passwd --file=/etc/proftpd/ftpd.passwd --name=$ftp_user --uid=33 --gid=33 --home=/var/www --shell=/usr/sbin/nologin
rm -r /etc/proftpd/proftpd.conf
cp ./conf/proftpd/proftpd.conf /etc/proftpd/proftpd.conf
cp ./conf/proftpd/custom.conf /etc/proftpd/conf.d/custom.conf


# paste site
rm -r /var/www/html
wget https://ru.wordpress.org/latest-ru_RU.tar.gz
tar -zxvf latest-ru_RU.tar.gz
cp -r wordpress /var/www/
mv /var/www/wordpress /var/www/html
chmod -R 777 /var/www/html

# restart && enabled nginx, apache
systemctl enable apache2 mariadb php7.2-fpm proftpd
systemctl start apache2 mariadb php7.2-fpm
systemctl restart nginx php7.2-fpm proftpd
