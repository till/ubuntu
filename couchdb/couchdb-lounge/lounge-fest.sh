#!/bin/bash
####################################################################################
#                                                                                  #
# This script setups CouchDB lounge and the tools on an Amazon AWS EC2 instance.   #
#                                                                                  #
# Feel free to adjust APACHE_MIRROR, COUCHDB_VERSION and EBS_VOL below. The rest   #
# should work out of the box. When this script is done, you'll have a .deb sitting #
# on your EBS volume, use dpkg -i to install it.                                   #
#                                                                                  #
# The CouchDB tools are symlinked as /usr/local/bin/couchdb-dump and couchdb-load  #
# on the system.                                                                   #
#                                                                                  #
# This has been tested on Ubuntu 9.04, and I realize it could be improved. Please  #
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

export APACHE_MIRROR=http://apache.easy-webs.de/couchdb
export COUCHDB_VERSION=0.10.0
export COUCHDB_USER=root
export EBS_VOL=/couchdb
export INSTALL_YES_NO=yes

# include shared functions
source ./../functions

if [ ! -d $EBS_VOL ]; then
    echo "Error: $EBS_VOL doesn't exist."
    exit 1
fi

export PKG_NAME=apache-couchdb
export COUCHDB_FILE="${PKG_NAME}-${COUCHDB_VERSION}"
export COUCHDB_DOWNLOAD="${APACHE_MIRROR}/${COUCHDB_VERSION}/${COUCHDB_FILE}.tar.gz"

export LOUNGE_FILES="${EBS_VOL}/couchdb-lounge"

source ./functions-lounge

basics
couchdb_deps
couchdb_download
lounge_download
lounge_merge_patch
couchdb_install
lounge_install_dumbproxy
lounge_install_pythonlounge
lounge_install_smartproxy
#couchdb_tools


echo ""
echo "Create the following directory: /var/log/lounge/replicator."
echo "You'll need to chown it, in case your CouchDB doesn't run as root."
echo ""