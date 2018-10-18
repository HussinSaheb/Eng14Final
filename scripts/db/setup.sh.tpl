#!/bin/bash

rs.initiate( {
   _id : "Eng14",
   members: [
      { _id: 0, host: "10.1.3.10:27017" },
      { _id: 1, host: "10.1.4.10:27017" },
      { _id: 2, host: "10.1.5.10:27017" }
   ]
})

rs.reconfig({
   _id : "Eng14",
   members: [
      { _id: 0, host: "10.1.3.10:27017" },
      { _id: 1, host: "10.1.4.10:27017" },
      { _id: 2, host: "10.1.5.10:27017" }
   ]
}, {force : true})

rs.isMaster().primary
rs.isSlave()
rs.slaveOk()
