#!/usr/bin/env bash
####################################################################################
#                                                                                  #
# This script setups CouchDB and the tools on an Amazon AWS EC2 instance.          #
#                                                                                  #
# Feel free to adjust APACHE_MIRROR, COUCHDB_VERSION and EBS_VOL below. The rest   #
# should work out of the box. When this script is done, you'll have a .deb sitting #
# on your EBS volume, use dpkg -i to install it.                                   #
#                                                                                  #
# The CouchDB tools are symlinked as /usr/local/bin/couchdb-dump and couchdb-load  #
# on the system.                                                                   #
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

export APACHE_MIRROR=http://apache.easy-webs.de/couchdb
export COUCHDB_VERSION=0.10.0
export COUCHDB_USER=root
export EBS_VOL=/couchdb
export INSTALL_YES_NO=no

# include shared functions
source ./functions

if [ ! -d $EBS_VOL ]; then
    echo "Error: $EBS_VOL doesn't exist."
    exit 1
fi

export PKG_NAME=apache-couchdb
export COUCHDB_FILE="${PKG_NAME}-${COUCHDB_VERSION}"
export COUCHDB_DOWNLOAD="${APACHE_MIRROR}/${COUCHDB_VERSION}/${COUCHDB_FILE}.tar.gz"

function couchdb_install {
    echo "Building CouchDB..."

    cd ${COUCHDB_FILE}/
    ./configure --prefix=$EBS_VOL/couchdb
    make
    checkinstall -y -D --install=${INSTALL_YES_NO} \
    --pkgname=$PKG_NAME --pkgversion=$COUCHDB_VERSION \
    --maintainer=till@php.net --pakdir=$EBS_VOL --pkglicense=Apache 

    echo "Package created in: ${EBS_VOL}"

    #replace $COUCHDB_USER in ${EBS_VOL}/couchdb/etc/defaults/couchdb
    #echo "bind_address = 0.0.0.0" >> ${EBS_VOL}/couchdb/etc/couchdb/local.ini
    #echo "port = 80" >> ${EBS_VOL}/couchdb/etc/couchdb/local.ini

    if [ $INSTALL_YES_NO -eq "no" ]; then
        echo "Please run dpkg -i and install it."
    else
        ln -s ${EBS_VOL}/couchdb/etc/init.d/couchdb /etc/init.d/couchdb
        ln -s ${EBS_VOL}/couchdb/etc/logrotate.d/couchdb /etc/logrotate.d/couchdb
        update-rc.d couchdb defaults
    fi
}

basics
couchdb_deps
couchdb_download
couchdb_install
couchdb_tools
