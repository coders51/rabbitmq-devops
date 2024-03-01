#!/bin/bash
#Overwrites the current erlang cookie
#usage
#   $> sudo ./set_erlang_cookie.sh "the-erlang-cookie"

SETUP_ERLANG_COOKIE=$1

if [ ! -z $1 ]
then
    echo "--------------------------------------------------------"
    echo "setting rabbitmq erlang cookie to ${SETUP_ERLANG_COOKIE}"
    echo "--------------------------------------------------------"
    #overwrite the erlang cookie
    systemctl stop rabbitmq-server
    chmod 666 /var/lib/rabbitmq/.erlang.cookie
    echo -n $SETUP_ERLANG_COOKIE > /var/lib/rabbitmq/.erlang.cookie
    chmod 400 /var/lib/rabbitmq/.erlang.cookie
    systemctl start rabbitmq-server 
    sleep 30
else
    echo "-------------------------------------"
    echo "Skipping rabbitmq erlang cookie setup"
    echo "-------------------------------------"
fi


    


