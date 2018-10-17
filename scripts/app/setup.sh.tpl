#!/bin/bash

cd /home/ubuntu/app

export IP=$(nslookup ${ip} | grep Address: | tail -1 | cut -c 10-)
export DB_HOST=mongodb://$IP:27017
pm2 kill
pm2 start app.js
