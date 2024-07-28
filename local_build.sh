#!/bin/bash
version="8.2"
printf " Building Maddy Mo for PHP $version\n"
./vendor/bin/zephir fullclean
./vendor/bin/zephir build
cp ext/modules/maddymo.so compiled/php$version-maddy-mo.so
sudo service php$version-fpm restart
echo " Maddy Mo build complete"