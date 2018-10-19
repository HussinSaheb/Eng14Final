#!/bin/bash

mongo mongodb://10.1.3.10/eng14 --eval "rs.initiate({_id:'Eng14', members: [{_id:1, host:'10.1.3.10:27017'}]})"
mongo mongodb://10.1.3.10/eng14 --eval "rs.add( '10.1.4.10:27017')"
mongo mongodb://10.1.3.10/eng14 --eval "rs.add( '10.1.5.10:27017' )"
mongo mongodb://10.1.3.10/eng14 --eval "db.isMaster().primary"
mongo mongodb://10.1.3.10/eng14 --eval "rs.slaveOk()"
