#!/bin/bash

cd /home/ubuntu/app
export DB_HOST=${db_host}
pm2 kill
pm2 start app.js
