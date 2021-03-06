#!/bin/bash

################################################################
# Module to create a secure perimeter
#
# ©Copyright IBM Corporation 2018.
# 
# LICENSE:Eclipse Public License, Version 2.0 - https://opensource.org/licenses/EPL-2.0
#
################################################################

if [ $# -ne 1 ]
  then
    echo "Usage : create_secure_perimeter.sh <Unique name for this secure perimeter - for example SP1>"

else
   workspace_name=$1

   cd secure_perimeter
   terraform workspace new ${workspace_name}
   # Remove these files as they may have been copied in during previous deployment - 
   # They cannot be deployed in first stage of deploying secure perimeter

   rm -f ./modules/monitoring_cluster/network_pod.tf
   rm -f ./modules/monitoring_cluster/health_pod.tf

   terraform init
   terraform apply
   result=$?
   # if monitoring cluster is up then create health and network pods 
   if [ ${result} -eq 0 ]
   then 

     cp ../health_pod.tf ./modules/monitoring_cluster
     terraform init
     terraform apply  -target=module.monitoring_cluster.module.health-pod -auto-approve

     cp ../network_pod.tf ./modules/monitoring_cluster
     terraform init
     terraform apply  -target=module.monitoring_cluster.module.network-pod -auto-approve
   else echo "Network and Health Pods not started since deployment did not complete successfully"
   fi
   
fi

