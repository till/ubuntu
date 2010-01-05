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

export LOUNGE_FILES="${EBS_VOL}/couchdb-lounge"

function lounge_download {
    cd $EBS_VOL && git clone git://github.com/tilgovi/couchdb-lounge.git
}

function lounge_merge_patch {
    cd ${EBS_VOL}/${COUCHDB_FILE}/src && patch -p1 < ${EBS_VOL}/couchdb-lounge/couchdb/designonly_replication-${COUCHDB_VERSION}.patch
}

# Install the JSON-C lib for dumbproxy
# We install 0.7, because > 0.7 is f'd up
function lounge_install_dumbproxy_dep {

    local version=0.7

    cd $EBS_VOL
    wget http://oss.metaparadigm.com/json-c/json-c-${version}.tar.gz
    tar -xf json-c-${version}.tar.gz
    cd json-c-${version}/
    ./configure
    make
    checkinstall -y -D  --install=${INSTALL_YES_NO} \
    --showinstall=no \
    --pkgname=json-c --pkgversion=${version} \
    --maintainer=till@php.net --pakdir=$EBS_VOL --pkglicense=free
}

# Install the dumbproxy module
function lounge_install_dumbproxy {

    lounge_install_dumbproxy_dep

    cd ${EBS_VOL}/couchdb-lounge/dumbproxy
    ./configure && make 
    checkinstall -y -D  --install=${INSTALL_YES_NO} \
    --showinstall=no \
    --pkgname=couchdb-lounge-dumbproxy --pkgversion=${COUCHDB_VERSION} \
    --maintainer=till@php.net --pakdir=$EBS_VOL --pkglicense=Meebo \
    --requires='json-c'
}

function lounge_install_pythonlounge {
    cd ${EBS_VOL}/couchdb-lounge/python-lounge
    python setup.py install
}

function lounge_install_smartproxy {

    local deps="python-twisted, python-cjson, python-simplejson, python-pyicu"

    apt-get install $APT_OPTS ${deps//,/}

    cd ${EBS_VOL}/couchdb-lounge/smartproxy
    make
    checkinstall -y -D  --install=${INSTALL_YES_NO} \
    --showinstall=no \
    --pkgname=couchdb-lounge-smartproxy --pkgversion=${COUCHDB_VERSION} \
    --maintainer=till@php.net --pakdir=$EBS_VOL --pkglicense=Meebo \
    --requires="${deps}"
}

function couchdb_install {
    echo "Building CouchDB..."

    cd ${EBS_VOL}/${COUCHDB_FILE}/
    ./configure --prefix=$EBS_VOL/couchdb
    make
    checkinstall -y -D --install=${INSTALL_YES_NO} \
    --showinstall=no \
    --pkgname=$PKG_NAME --pkgversion=$COUCHDB_VERSION \
    --maintainer=till@php.net --pakdir=$EBS_VOL --pkglicense=Apache \
    --requires="${COUCHDB_DEPS}"

    echo "Package created in: ${EBS_VOL}"

    #replace $COUCHDB_USER in ${EBS_VOL}/couchdb/etc/defaults/couchdb
    #echo "bind_address = 0.0.0.0" >> ${EBS_VOL}/couchdb/etc/couchdb/local.ini
    #echo "port = 80" >> ${EBS_VOL}/couchdb/etc/couchdb/local.ini

}

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
