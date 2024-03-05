#!/bin/bash
#usage
#   $> sudo 01_setup.sh ["rabbitmq-server 3 minor version"]
#
echo "---------------------"
echo "Installing base tools"
echo "---------------------"
apt-get update -y
apt-get install curl gnupg apt-transport-https net-tools -y

echo "----------------------------"
echo "Adding rabbitmq repositories"
echo "----------------------------"
./cloudsmith_repos.sh

echo "-------------------------"
echo "Indexing new repositories"
echo "-------------------------"
## Update package indices
apt-get update -y

echo "-----------------"
echo "Installing erlang"
echo "-----------------"
## Install Erlang packages
apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl


## Install rabbitmq-server and its dependencies
if [ -z "$1" ]; then
    echo "-------------------"
    echo "Installing latest version of rabbitmq"
    echo "-------------------"
    sudo apt-get install rabbitmq-server -y --fix-missing
else
    latest_patch=$(apt list -a rabbitmq-server 2>/dev/null | grep -oP "3.12.\K(\d{1,2}-\d{1,2})" | sort -V | tail -n 1)
    if [ -z "$latest_patch" ]; then
        echo "...could not find any version of minor $1, aborting"
        exit 1
    fi
    echo "-------------------"
    echo "Installing version 3.$1.$latest_patch of rabbitmq"
    echo "-------------------"
    sudo apt-get install rabbitmq-server=3.$1.$latest_patch -y --fix-missing
fi

echo "---------------------------"
echo "Enabling rabbitmq at startup"
echo "---------------------------"
#start rabbitmq and make it run at startup
systemctl enable rabbitmq-server
sleep 30

echo "--------------------------"
echo "Enabling management plugin"
echo "--------------------------"
#enable management plugin
rabbitmq-plugins enable rabbitmq_management
#metrics for prometheus
rabbitmq-plugins enable rabbitmq_prometheus

echo "-------------------"
echo "Adding default user"
echo "-------------------"
rabbitmqctl add_user rabbit rabbit
rabbitmqctl set_user_tags rabbit administrator
rabbitmqctl set_permissions -p / rabbit ".*" ".*" ".*"
