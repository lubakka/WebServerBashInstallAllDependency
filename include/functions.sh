#!/bin/bash

. include/variable.sh

installpgk(){
if [ "$PKGSTOINSTALL" != "" ]; then
	echo -n "Some dependencies are missing. Want to install them? (Y/n): "
	read SURE
	if [[ $SURE = "Y" || $SURE = "y" || $SURE = "" ]]; then
		if which apt-get &> /dev/null; then
			apt-get update && apt-get upgrade -y
			sleep 3
			echo -n "Do you want install only web server? (Y/n): "
			read WEBS
			if [[ $WEBS = "Y" || $WEBS = "y" || $WEBS = "" ]]; 
			then
				apt-get install -y $PKGSTOINSTALLWEB
				sleep 3
                        	a2enmod rewrite suexec ssl actions include cgi dav_fs dav auth_digest
				sleep 3
				service	apache2 restart
			fi
		elif which zypper &> /dev/null; then
			zypper in -y $PKGSTOINSTALL
		elif which urpmi &> /dev/null; then
			urpmi $PKGSTOINSTALL
		elif which yum &> /dev/null; then
			yum install $PKGSTOINSTALL
			service httpd restart
			/etc/init.d/httpd restart
		elif which pacman &> /dev/null; then
			pacman -Sy $PKGSTOINSTALL
		else
			NOPKGMANAGER=TRUE
			echo "ERROR: impossible to found a package manager in your sistem. Please, install manually ${PKGSTOINSTALL[*]}."
		fi
		if [[ $? -eq 0 && ! -z $NOPKGMANAGER ]] ; then
			echo "All dependencies are satisfied."
		else
			echo "ERROR: impossible to install some missing dependencies. Please, install manually ${PKGSTOINSTALL[*]}."
		fi
	else
		echo "WARNING: Some dependencies may be missing. So, please, install manually ${PKGSTOINSTALL[*]}."
	fi
else
	echo "WARNING: Missing Packages to install!"
fi
}

secureMysql(){
	if [ -r include/mysql.sh ]; then
           . include/mysql.sh
	fi
}

installPhantomjs(){
	git clone git://github.com/ariya/phantomjs.git
	cd phantomjs
	git checkout 1.9
	./build.sh
}

show_help() {
cat << EOF
Usage: $(basename "$0") [-h] [-i] [-m user pass new_pass] [-p] [-a host user pass new_pass dbname] [-c host user pass dbname] ...
0. За помощ изпълнете следната команда "./setup.sh -h"
1. Изпълнете следната команда "./setup.sh -a <host> <user> <pass> <new_pass> <dbname>" за да инсталира всички необходими пакети за поддръжката на WEB SERVER за КСК-то
2. Изпълнете следната команда "./setup.sh -c <root> <pass> <host> <user_name> <user_pass> <dbname>"
3. Изпълнете следната команда "./setup.sh -w <url>" <url> - трявба да е пълен уеб адрес за да се добави конфигурация за apache2.
4. Редактирайте следния файл "/etc/php5/apache2/php.ini" добавете следния текст някъде или редактирайте 'date.timezone = "Europe/Sofia"'

Приятно ползване.

Option							GNU long option						Meaning
 -h, -?							--help							Show this help text.
 -i 							--packeg						Install dpkg for web server.
 -m <user> <pass> <new_pass>				--mysql_secure <user> <pass> <new_pass>			Mysql_secured_isntall.
 -p 							--phantomjs						Install Phantomjs.
 -a <host> <user> <pass> <new_pass> <dbname>		--auto <host> <user> <pass> <new_pass> <dbname>		Install automatic all.
 -c <root> <pass> <host> <user> <user_pass> <dbname> 	--createdb <host> <user> <pass> <dbname> 		Create databases for KSK.
 -k <root> <host> <port|null> <user> <dbname> <userpass>--ksk <host> <user> <dbname>				Install KSK to web root.
 -w <url>						--web <url>						Add config file to apache2 for KSK.
EOF
}

create_databases(){
	if [ -r include/create_mysql_databases.sh ]; then
           . include/create_mysql_databases.sh
	fi
}

apache2config(){
local FILE='/etc/apache2/sites-available/$1.conf'
touch $FILE
MKDIR=`which mkdir`
"$MKDIR -p /var/www/html/$1"
/bin/cat <<EOM >$FILE
<VirtualHost *:80>
     ServerName $1
     DocumentRoot /var/www/html/$1/web/
     <Directory /var/www/html/$1/web/>
         DirectoryIndex index.php index.html
         AllowOverride All
         Require all granted
     </Directory>
 </VirtualHost>
EOM

sudo a2ensite $1
sleep 5
sudo service apache2 reload
sleep 5
sudo service apache2 restart
}
