#!/bin/bash
####################################################################################
#                                                                                  #
# This script creates CouchDB config files and start scripts.                      #
#                                                                                  #
# This has been tested on Ubunut 9.04, and I realize it could be improved. Please  #
# contribute. :-)                                                                  #
#                                                                                  #
# Notes:                                                                           #
#                                                                                  #
# For simplicity, all our shards will run on localhost, but on a different port.   #
# Take a look at PORT below to define the start port (of the first shard).         #
#                                                                                  #
# In the end, this script will leave you with "local-PORT.ini" files which are the #
# configuration files to each chart and a "nodelist" file, which contains some-    #
# thing like:                                                                      #
#  localhost PORT1                                                                 #
#  localhost PORT2                                                                 #
#  localhost PORT3                                                                 #
#                                                                                  #
# Use the "nodelist" file with update_shard_map.py.                                #
#                                                                                  #
# If INSTALL_YES_NO=yes, the local.ini files will be copied                        #
# to your $COUCHDB_EBS/etc/couchdb/ directory.                                     #
#                                                                                  #
# All files will be in ./work.                                                     #
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

WORKING="`pwd`/work"

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
    `echo "$2" >> $WORKING/$1`
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

nodelist=""

mkdir -p $WORKING;

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

    if [ $INSTALL_YES_NO -eq "yes" ]; then
        cp ${WORKING}/local-*.ini ${COUCHDB_EBS}/etc/couchdb/
    fi

    nodelist="${nodelist}localhost ${shard_port}"$'\n'

done

save_file "nodelist" "${nodelist}"

echo "Done!"
echo ""

echo "Created in ${WORKING}:"
echo " * nodelist (for update_shard_map.py)"
echo " * ${NUMSERVERS} local-*.ini's"
echo ""
exit 0;