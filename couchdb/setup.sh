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
# on the system. Due to my lack of time, I have python26 hardcoded into it, but    #
# I promise I'll improve this later.                                               #
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
export PKG_NAME=apache-couchdb
export COUCHDB_VERSION=0.9.1
export COUCHDB_FILE="${PKG_NAME}-${COUCHDB_VERSION}"
export COUCHDB_DOWNLOAD="${APACHE_MIRROR}/${COUCHDB_VERSION}/${COUCHDB_FILE}.tar.gz"
export EBS_VOL=/couchdb


export COUCHDB_PYTHON_INSTALL=/usr/local/lib/python2.6/dist-packages/couchdb/tools
export APT_OPTS=" --yes --quiet"

echo "Creating build directory...\n"

mkdir -p ~/build
cd ~/build

function couchdb_deps {
    apt-get install $APT_OPTS checkinstall
    apt-get install $APT_OPTS subversion
    apt-get install $APT_OPTS automake autoconf libtool help2man
    apt-get install $APT_OPTS build-essential erlang libicu-dev libmozjs-dev libcurl4-openssl-dev
}

function couchdb_install {
    echo "Downloading CouchDB...\n"

    wget $COUCHDB_DOWNLOAD
    tar zxvf ${COUCHDB_FILE}.tar.gz

    echo "Building CouchDB...\n"

    cd ${COUCHDB_FILE}/
    ./configure --prefix=$EBS_VOL/couchdb
    make
    checkinstall -y -D --install=no \
    --pkgname=$PKG_NAME --pkgversion=$COUCHDB_VERSION \
    --maintainer=till@imagineeasy.com --pakdir=$EBS_VOL --pkglicense=Apache 

    echo "Package created in: ${EBS_VOL}\n"
    echo "Please run dpkg -i and install it.\n\n\n"
}

function couchdb_tools {
    echo "Installing dependencies for CouchDB tools...\n"

    apt-get install $APT_OPTS python-httplib2
    apt-get install $APT_OPTS python-simplejson

    echo "Building CouchDB tools... \n"

    mkdir -p ~/build
    cd ~/build/
    svn checkout http://couchdb-python.googlecode.com/svn/trunk/ ./couchdb-python-read-only-${COUCHDB_VERSION}

    cd couchdb-python-read-only-${COUCHDB_VERSION}
    python setup.py install

    echo "Symlinking tools... \n"

    chmod +x ${COUCHDB_PYTHON_INSTALL}/dump.py
    chmod +x ${COUCHDB_PYTHON_INSTALL}/load.py

    ln -s ${COUCHDB_PYTHON_INSTALL}/dump.py /usr/local/bin/couchdb-dump
    ln -s ${COUCHDB_PYTHON_INSTALL}/load.py /usr/local/bin/couchdb-load
}

couchdb_deps
couchdb_install
couchdb_tools
