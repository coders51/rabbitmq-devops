#!/bin/bash
#usage
#   $> sudo 01_setup.sh ["the-erlang-cookie"]
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

echo "-------------------"
echo "Installing rabbitmq"
echo "-------------------"
## Install rabbitmq-server and its dependencies
apt-get install rabbitmq-server -y --fix-missing

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

echo "-------------------"
echo "Adding default user"
echo "-------------------"
rabbitmqctl add_user rabbit rabbit
rabbitmqctl set_user_tags rabbit administrator
rabbitmqctl set_permissions -p / rabbit ".*" ".*" ".*"

#overwrite the erlang cookie
./set_erlang_cookie.sh $1