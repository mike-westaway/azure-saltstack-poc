#!/bin/bash

echo $(date +"%F %T%z") "starting script customext.sh"

# arguments
adminUsername=${1}
adminPassword=${2}
storageName=${3}
vnetName=${4}
subnetName=${5}
clientid=${6}
secret=${7}
tenantid=${8}
nsgname=${9}
ingestionkey=${10}

echo "----------------------------------"
echo "INSTALLING SALT MINION"
echo "----------------------------------"

curl -s -o $HOME/bootstrap_salt.sh -L https://bootstrap.saltstack.com
sh $HOME/bootstrap_salt.sh -p python-pip git 2017.7

easy_install-2.7 pip==9.0.1
yum install -y gcc gcc-c++ git make libffi-devel openssl-devel python-devel
curl -s -o $HOME/requirements.txt -L https://raw.githubusercontent.com/ritazh/azure-saltstack-elasticsearch/master/requirements.txt
pip install -r $HOME/requirements.txt

vmPrivateIpAddress=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-08-01&format=text")
vmLocation=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-08-01&format=text")
resourceGroupName=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/resourceGroupName?api-version=2017-08-01&format=text")
subscriptionId=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/subscriptionId?api-version=2017-08-01&format=text")

echo "----------------------------------"
echo "CONFIGURING AGENTS"
echo "----------------------------------"

mkdir -p /srv/salt
echo "
base:
  '*':
    - common_packages
    - logging
" | tee /srv/salt/top.sls

echo "
common_packages:
    pkg.installed:
        - names:
            - git
            - tmux
            - tree
" | tee /srv/salt/common_packages.sls

echo "
Add LogDNA agent yum repo:
  pkgrepo.managed:
    - name: logdna-agent
      humanname: LogDNA Agent
      baseurl: http://repo.logdna.com/el6/
      gpgcheck: 0

Install LogDNA agent:
  pkg.installed:
    - name: install packages
    - refresh: True
    - pkgs:
      - logdna-agent

Configure LogDNA Agent:
  file.managed:
    - name: /etc/logdna.conf
    - contents: |
        logdir = /var/log
        key = $ingestionkey

Ensure LogDNA agent is running:
  cmd.run:
    - name: service logdna-agent start
    - onlyif: if service logdna-agent status | grep Running; then exit 1; else exit 0; fi

Ensure LogDNA agent is started at boot:
  cmd.run:
    - name: chkconfig logdna-agent on
    - onlyif: if chkconfig | grep logdna-agent | grep on; then exit 1; else exit 0; fi
" | tee /srv/salt/logging.sls


echo "----------------------------------"
echo "INSTALLING AGENTS"
echo "----------------------------------"

cd /srv/salt
salt -G '*' state.highstate

echo $(date +"%F %T%z") "ending script customext.sh"
