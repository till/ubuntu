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

CHROOT=/

# this is the ebs volume we log to
LOG_EBS=${CHROOT}logs

# this is the ebs the databases will be on
DB_EBS=${CHROOT}couchdb_ebs

# this is where couchdb is installed
COUCHDB_EBS=${CHROOT}couchdb

# this is the user to run couchdb with
COUCHDB_USER=root

## Don't edit below.

NUMSERVERS=$1

function save_file {
    `echo "$2" >> ./$1`
}

function create {
    mkdir $1;
    touch $2;
    touch $3;
}

if [ -z $NUMSERVERS ]; then
    echo "Use: ${0} NUMBEROFSERVERS";
    exit 1;
fi

conf=`cat ./local.ini-tpl`

#echo "$conf";

nodelist=""

for (( i=1; i<=$NUMSERVERS; i++ ))
do

    shard_port=$((PORT+$i))

    local_config=${conf/ADMINS/$ADMINS}
    local_config=${local_config/HTTPAUTHSECRET/$HTTPAUTHSECRET}
    local_config=${local_config//PORTNUMBER/$shard_port}
    local_config=${local_config//LOGEBS/$LOG_EBS}
    local_config=${local_config//DBEBS/$DB_EBS}

    pid_file="/var/run/couch-${shard_port}.pid"
    db_dir="${DBS_EBS}/${shard_port}"
    log_file="${LOG_EBS}/couch-${shard_port}.log"

    save_file "local-${shard_port}.ini" "$local_config"

    #create "{$db_dir}" "${log_file}" "${pid_file}"

    init_cmd="sudo su -c'/usr/bin/couchdb"
    init_cmd="${init_cmd} -c ${COUCHDB_EBS}/etc/couchdb/local-${shard_port}.ini"
    init_cmd="${init_cmd} -b -r 5"
    init_cmd="${init_cmd} -p ${pid_file}"
    init_cmd="${init_cmd} -o /dev/null -e /dev/null'"
    init_cmd="${init_cmd} ${COUCHDB_USER}"

    echo "${init_cmd}"
    echo ""


    nodelist="${nodelist}localhost_${shard_port}"$'\n'

done

save_file "nodelist" "${nodelist}"

echo "Done!"
echo ""

echo "Created in `pwd`:"
echo " * nodelist (for update_shard_map.py)"
echo " * ${NUMSERVERS} local-*.ini's"
echo ""
exit 0;