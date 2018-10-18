#!/bin/bash

cd /home/ubuntu/app
export DB_HOST=mongodb://${db_host1}:27017/posts
pm2 kill
pm2 start app.js
