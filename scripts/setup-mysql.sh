#!/bin/sh

mkdir -p /run/mysqld
mysql_install_db --user=root
mysqld --user=root
sleep 5
mysqladmin -u root password "CowSaysMoo"