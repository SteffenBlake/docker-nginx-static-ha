#!/bin/ash

cp -R /static/* /www

nginx -g "daemon off;"
