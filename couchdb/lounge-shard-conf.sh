#!/bin/bash
####################################################################################
#                                                                                  #
# This script creates CouchDB config files and start scripts.                      #
#                                                                                  #
# This has been tested on Ubunut 9.04, and I realize it could be improved. Please  #
# contribute. :-)                                                                  #
#                                                                                  #
####################################################################################
#                                                                                  #
# Author:  Till Klampaeckel                                                        #
# Email:   till@php.net                                                            #
# License: The New BSD License                                                     #
# Version: 0.1.0                                                                   #
#                                                                                  #
####################################################################################


ADMINS="user1 = password
user2 = password";

HTTPAUTHSECRET="this should be adjusted"

# We'll start at this port
PORT=5984

# this is the ebs volume we log to
LOG_EBS=/logs

# this is the ebs the databases will be on
DB_EBS=/couchdb_ebs

## Don't edit below.

NUMSERVERS=$1

function save_file {
    `echo "$2" >> ./$1`
}

function create {
    mkdir $1;
    touch $2;
}

if [ -z $NUMSERVERS ]; then
    echo "Use: ${0} NUMBEROFSERVERS";
    exit 1;
fi

conf=`cat ./local.ini-tpl`

#echo "$conf";

for (( i=1; i<=$NUMSERVERS; i++ ))
do

    shard_port=$((PORT+$i))

    local_config=${conf/ADMINS/$ADMINS}
    local_config=${local_config/HTTPAUTHSECRET/$HTTPAUTHSECRET}
    local_config=${local_config//PORTNUMBER/$shard_port}
    local_config=${local_config//LOGEBS/$LOG_EBS}
    local_config=${local_config//DBEBS/$DB_EBS}

    save_file "local-${shard_port}.ini" "$local_config"

    #create "${DBS_EBS}/${shard_port}" "${LOG_EBS}/couch-${shard_port}.log"
done

echo "Done creating ${NUMSERVERS} config files."
exit 0;