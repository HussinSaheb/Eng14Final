# Eng14Final
# Contents

* [ What we have created. ](#what-we-created)
* [ Mongo Replica-set. ](#mongo-replica-set)
    1. [ How it works. ](#how-it-works)
        * [ To deploy the replica-set manually. ](#manual-replica)
* [ Diagrams. ](#diagrams)
* [ Multi AZ Project. ](#multi-az-app)
* [ ELK Stack. ](#elk-stack)

---

## <a name="what-we-created"> What we have created?</a>
We have created a 2-tier architecture which contains 3 Mongodb instances and 3 Node App instances. The architecture is placed within 3 availability zones in AWS, each containing a database instance and an app instance. Each instance is provisioned through cookbooks created in Chef, which are tested through both unit tests and integration tests. We have also created 3 cookbooks to provision an ELK stack, each for the Elasticsearch, Logstack, Kibana. The ELK stack is used to help manage, monitor and analyse logs within the architecture. This would be useful for debugging the architecture, recording any errors made within it. For the database, we have made one of the three instances the primary database, which will take on all the database requests made by the app instances. The other database instances are made into secondaries, which will be used replicate the primary at all times and will replace the primary once the current primary has been corrupted.

##  <a name="mongo-replica-set">Mongo Replica-set</a>

Our 2 tier architecture currently has a serious Single Point of Failure; the database tier.
We currently only run a single instance in a single availability zone. If this were to fail we would not only have down time but we would also have a serious loss of data.
Investigate how to create a replica set using mongo that allows three machines to replicate data and balance the load across three availability zones.

### <a name="how-it-works">how it works</a>
To deploy a replica-set, we need to make sure that mongo is installed and mongod service is running. So we made a mongo cookbook that would allowed us to create an AMI with packer to make sure that all DB instances have the two requirements to deploy a replica-set.

If using our mongo cookbook, you need to make sure that in your terraform file, you are using our mongo ami_id, which is **ami-0c388e9d21eea5bd5**.

Once everything is correctly setup, run:  
```
terraform init
```

This is to initialise a working directory containing our Terraform configuration files.

If terraform is initialised correctly, run:
```
terraform plan
```
This is to create an execution plan for you to see if everything in your terraform files meet all the requirements.

If all requirements are met, run:
```
terraform apply
```

When terraform apply is executed successfully, go on AWS, get the public IP address from your App instance and make a request to '/posts'.

You should be able to see the posts page of the web application.

Now, to check if the replica-set is deployed correctly and is working, go on AWS and terminate the Primary DB instance. When reloading the posts page, you should still be able to see all the posts page.

This is because when the Primary goes down, the other two Secondary members will undergo an 'election'. The member with a healthier state will get elected as the new Primary.

#### <a name="manual-replica">To deploy the replica-set manually</a>

This is what our mongo cookbook AMI will automatically do for you. Only do the following if you are not using the available AMI.
```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
```

This is to ensure the authenticity of software packages by verifying that they are signed with GPG keys, so we first have to import the key for the official MongoDB repository.

```
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
```

This is to create a list file for MongoDB.
```
sudo apt-get update
```
This is to update the package list.
```
sudo apt-get install -y mongodb-org
```
This will install several packages containing the latest version of MongoDB
```
sudo systemctl start mongod  
```
This is to start the mongod service

To check if your mongod service is running, you can run
```
mongod
```
and it will tell you the status of the service.

Now, you need to reconfigure your mongod.conf file.

To do so, run
```
sudo vi /etc/mongod.conf
```
or
```
sudo nano /etc/mongod.conf
```
Inside the file, you will need to make sure that under 'Net Interface', it should have the following lines:

```
net:
  port: 27017
  bindIp: 0.0.0.0
```
Port 27017 is the default port for MongoDB, and since we will be using several hosts which will ensure that MongoDB will listen for connections from applications on your configured addresses.

Under 'Replication', it should have the following lines:
```
replication:
  replSetName: Eng14
```
This is so that your replica-set members will fall under the same replica group.

Once you are done making the change to the mongod.conf file, save and exit from there and restart the mongod service with the following command:
```
sudo systemctl restart mongod
```

Now ssh into the mongo shell with the following command:
```
mongo
```

With the provision of our mongo cookbook and the image we've created using packer, the replica-set should have already been deployed.

To check if the replica-set exists, run:
```
rs.status()
```

That should then display a list of all the DBs, one should have a status of "Primary", and two should have a status of "Secondary".

If none are displayed, it would mean that the replica-set has not been initialised, you would need to run:
```
rs.initiate({_id: "replSetName", members: [{_id: 0, host: "your db private IP address:27017"}]})
```

Once your Primary DB has successfully been initialised, you can then add the other two DBs to the replica-set as a Secondary member.
```
rs.add({_id: 1, host: "your second db private IP address:27017"}, {_id: 2, host: "your third db private IP address:27017"})
```
Once the two are added to the replica-set successfully, when you run 'rs.status()', you should now be able to see all three members of the set, one Primary and two Secondaries.

To ensure that whatever is written onto the Primary member get replicated to the Secondary members, you need to setup a master-slave relationship for the set.
Exit the mongo shell.

```
mongod --master --dbpath /data/masterdb/
```
This command should be run inside the Primary virtual environment.

```
mongod --slave --source <hostname><:<port>> --dbpath /data/slavedb/
```
This command will set the other two members as a slave.

___

## <a name="diagrams">Diagrams</a>
| ![alt text](Images/NodeApp.png)| This is the diagram of the architecture, made using  https://cloudcraft.co/. This gives the overview of the architecture. |
| ------------- |:-------------:|
|![alt text](Images/Diagram1.jpg) - ![alt text](Images/Diagram3.jpg)|This shows the plan made in creating the replica set for the architecture.|
| ![alt text](Images/Diagram2.jpg)|This shows the plan made in planning the VPC for the database instances and where to put them within AWS.|
|![alt text](Images/Diagram4.jpg)| This is the plan of linking the ELK stack to the app and database.|



-----

##  <a name="multi-az-app">Multi AZ Project</a>
Using Terraform and AWS create a load balanced and autoscaled 2 tier architecture for the node example application.
The Architecture should be a "Highly Available" application. Meaning that it has redundancies across all three availabililty zones.
The application should connect to a single database instance.

#### Deployment
<<<<<<< HEAD
=======
For the deployment of the app minstances to multiple availability zones, all the configurations are done through terraform.


>>>>>>> cf41aac9ed34ebb590b62514985020cf4f929954

## <a name="elk-stack">ELK STACK</a>
Immutable architectures are notoriously difficult to debug because we no longer have access to the instances and thus do not have access to the logs for those machines.
Log consolidation allows us to have logs files broadcast to a central repository by the instances themselves which allows us to more easily view them.
The ELK stack is a commonly used system for this purpose.
Research the setup of the elk stack and create a cookbook for provisioning the required machines.
