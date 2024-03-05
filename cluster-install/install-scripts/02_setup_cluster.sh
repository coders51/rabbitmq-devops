#!/bin/bash
#First setup the node with setup.sh, then use this script to join a cluster.
#usage
#   $> sudo 02_setup_cluster.sh "rabbit@the-cluster-node" "the-erlang-cookie"
#
SETUP_CLUSTER_HOST=$1
SETUP_ERLANG_COOKIE=$2

#overwrite the erlang cookie
./set_erlang_cookie.sh $SETUP_ERLANG_COOKIE


#prepare the local node to join the cluster
echo "--------------------------------------------"
echo "Preparing the local node to join the cluster"
echo "--------------------------------------------"
rabbitmqctl stop_app
rabbitmqctl reset


#join operation request
echo "----------------------------------------------------------"
echo "Issuing cluster join request to node ${SETUP_CLUSTER_HOST}"
echo "----------------------------------------------------------"
rabbitmqctl join_cluster $SETUP_CLUSTER_HOST

#start node apps
echo "------------------------------"
echo "Starting internal rabbitmq app"
echo "------------------------------"
rabbitmqctl start_app