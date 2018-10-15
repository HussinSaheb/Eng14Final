#!/bin/bash

cd /home/ubuntu/app
export DB_HOST=${dbip}
pm2 kill
pm2 start app.js
