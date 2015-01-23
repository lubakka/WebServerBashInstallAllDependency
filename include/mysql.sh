#!/bin/bash

expect -c "

set timeout 2
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"$DATABASE_PASS\r\"

expect \"Change the root password?\"
send \"y\r\"

expect \"New password: \"
send \"$DATABASE_PASS_NEW\r\"

expect \"Re-enter new password: \"
send \"$DATABASE_PASS_NEW\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
"

