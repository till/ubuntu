#!/bin/bash
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
export INSTALL_YES_NO=yes

if [ ! -d $EBS_VOL ]; then
    echo "Error: $EBS_VOL doesn't exist."
    exit 1
fi

export PKG_NAME=apache-couchdb
export COUCHDB_FILE="${PKG_NAME}-${COUCHDB_VERSION}"
export COUCHDB_DOWNLOAD="${APACHE_MIRROR}/${COUCHDB_VERSION}/${COUCHDB_FILE}.tar.gz"

PYTHON_VERSION=$(python -V 2>&1 |sed s,Python,,)
PYTHON_VERSION=${PYTHON_VERSION/ /}
export PYTHON_VERSION=${PYTHON_VERSION%.*}

export COUCHDB_PYTHON_INSTALL="/usr/local/lib/python${PYTHON_VERSION}/dist-packages/couchdb/tools"
export APT_OPTS=" --yes --quiet"
export APT_POST=" > /dev/null 2>&1"

function basics {

    echo "Fixing the basics..."

    apt-get update $APT_OPTS $APT_POST
    apt-get clean $APT_OPTS $APT_POST
    apt-get upgrade $APT_OPTS $APT_POST

    echo "Creating build directory..."

    mkdir -p ~/build
    cd ~/build
}

function couchdb_deps {
    apt-get install $APT_OPTS checkinstall $APT_POST
    apt-get install $APT_OPTS subversion $APT_POST
    apt-get install $APT_OPTS automake autoconf libtool help2man $APT_POST
    apt-get install $APT_OPTS build-essential erlang libicu-dev libmozjs-dev libcurl4-openssl-dev $APT_POST
}

function couchdb_install {
    echo "Downloading CouchDB..."

    wget $COUCHDB_DOWNLOAD
    tar zxvf ${COUCHDB_FILE}.tar.gz

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

    if [ $INSTALL_YES_NO -eq "no" ] then
        echo "Please run dpkg -i and install it."
    else
        ln -s ${EBS_VOL}/couchdb/etc/init.d/couchdb /etc/init.d/couchdb
        ln -s ${EBS_VOL}/couchdb/etc/logrotate.d/couchdb /etc/logrotate.d/couchdb
        update-rc.d couchdb defaults
    fi
}

function couchdb_tools {
    echo "Installing dependencies for CouchDB tools..."

    apt-get install $APT_OPTS python-httplib2 $APT_POST
    apt-get install $APT_OPTS python-simplejson $APT_POST

    echo "Building CouchDB tools... "

    mkdir -p ~/build
    cd ~/build/
    svn checkout http://couchdb-python.googlecode.com/svn/trunk/ ./couchdb-python-read-only-${COUCHDB_VERSION}

    cd couchdb-python-read-only-${COUCHDB_VERSION}
    python setup.py install

    echo "Symlinking tools... "

    chmod +x ${COUCHDB_PYTHON_INSTALL}/dump.py
    chmod +x ${COUCHDB_PYTHON_INSTALL}/load.py

    # create /usr/local/bin, because it might not be there :O
    BIN_LOCAL=/usr/local/bin
    mkdir -p $BIN_LOCAL

    ln -sf ${COUCHDB_PYTHON_INSTALL}/dump.py ${BIN_LOCAL}/couchdb-dump
    ln -sf ${COUCHDB_PYTHON_INSTALL}/load.py ${BIN_LOCAL}/couchdb-load
}

basics
couchdb_deps
couchdb_install
couchdb_tools
