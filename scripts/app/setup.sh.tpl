#!/bin/bash

cd /home/ubuntu/app
export DB_HOST=mongodb://${db_host1}
pm2 kill
pm2 start app.js


mongo mongodb://10.1.3.10 --eval "rs.initiate()" 
mongo mongodb://10.1.3.10 --eval "rs.add(10.1.4.10)" 
mongo mongodb://10.1.3.10 --eval "rs.add(10.1.5.10)" 
mongo mongodb://10.1.3.10 --eval "rs.isMaster()" 
mongo mongodb://10.1.3.10 --eval "rs.isSlave()" 
