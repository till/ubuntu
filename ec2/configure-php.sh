#!/bin/bash -ex
####################################################################################
#                                                                                  #
# This script adjusts the php.ini for cgi to your (or well, my,) liking.           #
#                                                                                  #
# Note: This script does not install PHP! :)                                       #
#                                                                                  #
#  * turn off error display and log instead                                        #
#  * turn off PHP HTTP header                                                      #
#  * fix up realpath_cache_*                                                       #
#  * up memory_limit and max_execution_time                                        #
#  * turn off magic_quotes_gpc (roflmaolollololol WAT?)                            #
#  * update pear install and install a package or two                              #
#                                                                                  #
# The variables are:                                                               #
#  * php_ini - the location of the php.ini file                                    #
#  * php_log - the location of the log file to log php issues to                   #
#  * the php-cgi user                                                              #
#                                                                                  #
####################################################################################
#                                                                                  #
# Author:  Till Klampaeckel                                                        #
# Email:   till@php.net                                                            #
# License: The New BSD License                                                     #
# Version: 0.1.0                                                                   #
#                                                                                  #
####################################################################################

php_ini=/etc/php5/cgi/php.ini
php_log=/var/log/php.log
www_user=www-data


touch $php_log
chown $www_user $php_log

# turn on error logging, turn off display of errors
sed -i "s,log_errors = Off,log_errors = On,g" $php_ini
sed -i "s,display_errors = On,display_errors = Off,g" $php_ini
sed -i "s,;error_log = filename,error_log = $php_log,g" $php_ini

# hide PHP
sed -i "s,expose_php = On,expose_php = Off,g" $php_ini

# realpath cache
sed -i "s,; realpath_cache_size=16k,realpath_cache_size=128k,g" $php_ini
sed -i "s,; realpath_cache_ttl=120,realpath_cache_ttl=3600,g" $php_ini

# up the memory_limit and max_execution_time
sed -i "s,memory_limit = 16M,memory_limit = 256M,g" $php_ini
sed -i "s,max_execution_time = 30,max_execution_time = 60,g" $php_ini

# fix ubuntu fuck ups
sed -u "s,magic_quotes_gpc = On,magic_quotes_gpc = Off,g" $php_ini

# update PEAR and install packages
pear channel-update pear.php.net
pear upgrade-all
pear install -f Crypt_HMAC2-beta
pear install -f HTTP_Session2
