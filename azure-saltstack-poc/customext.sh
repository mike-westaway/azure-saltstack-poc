#!/bin/bash

echo $(date +"%F %T%z") "starting script customext.sh"

# arguments
saltmasterdns=${1}

#adminUsername=${1}
#adminPassword=${2}
#storageName=${3}
#vnetName=${4}
#subnetName=${5}
#clientid=${6}
#secret=${7}
#tenantid=${8}
#nsgname=${9}
#ingestionkey=${10}

echo "----------------------------------"
echo "INSTALLING SALT MINION"
echo "----------------------------------"

curl -s -o $HOME/bootstrap_salt.sh -L https://bootstrap.saltstack.com
sh $HOME/bootstrap_salt.sh -A $saltmasterdns -p python-pip git 2017.7

#easy_install-2.7 pip==9.0.1
#yum install -y gcc gcc-c++ git make libffi-devel openssl-devel python-devel
#curl -s -o $HOME/requirements.txt -L https://raw.githubusercontent.com/ritazh/azure-saltstack-elasticsearch/master/requirements.txt
#pip install -r $HOME/requirements.txt

echo $(date +"%F %T%z") "ending script customext.sh"
