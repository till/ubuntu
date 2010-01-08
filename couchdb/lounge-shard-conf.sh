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


ADMINS="user = password
user2 = password";

HTTPAUTHSECRET="this should be adjusted"

PORT=5984

#echo "$ADMINS";
#exit;

## Don't edit below.

NUMSERVERS=$1

function save_file {
    `echo $2 >> ./$1`
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
    local_config=${local_config/PORTNUMBER/$shard_port}

    save_file "local-${shard_port}.ini" "$local_config"
done

# replace: PORTNUMBER, HTTPAUTHSECRET, ADMINS
