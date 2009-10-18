#!/bin/bash
####################################################################################
#                                                                                  #
# This script setups chef and all dependencies from opscode's APT repository.      #
#                                                                                  #
# This is from (+ rubygems1.8):                                                    #
# http://blog.opscode.com/blog/2009/09/02/apt-repository-for-chef/                 #
#                                                                                  #
####################################################################################
#                                                                                  #
# Author:  Till Klampaeckel                                                        #
# Email:   till@php.net                                                            #
# License: The New BSD License                                                     #
# Version: 0.1.0                                                                   #
#                                                                                  #
####################################################################################

RELEASE_NAME=jaunty

echo "deb http://apt.opscode.com/ $RELEASE_NAME universe" >> /etc/apt/sources.list.d/opscode.list

curl -s http://apt.opscode.com/packages@opscode.com.gpg.key | apt-key add -

apt-get -y update
apt-get -y install rubygems1.8
apt-get -y install ohai chef