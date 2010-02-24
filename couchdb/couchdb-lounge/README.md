# What's this?

 * a bunch of scripts to get CouchDB-lounge setup
 * a work in progress
 * goal? - have deps, install them - be happy!


## lounge-fest.sh

 * installs all dependencies
 * installs CouchDB
 * installs CouchDB-lounge components
 * TODO: configuration/setup of all components


## local.ini-tpl

 * a template to create configs for the shards from


## lounge-shard-conf.sh

 * uses local.ini-tpl
 * configs are create in the same dir
 * setup the configs for the shards
 * use: ./lounge-shard-conf.sh NUMBER-OF-SHARDS-HERE
 * configs:
  * LOG_EBS - dir where the logs will be stored
  * DB_EBS - where the dbs will be stored
  * COUCHDB_EBS - where couchdb is installed (1 GB ebs)
  * CHROOT - optional, if you run this with a prefix (for testing)


## lounge-shard-init

 * a script to start the shards


# How does it work?

 * clone the entire `ubuntu` repository
 * run `./lounge-fest.sh`
 * run `./lounge-shard-conf.sh NUMBER_OF_SHARDS`
 * run `./update_shards_map.py work/nodelist NUMBER_OF_SHARDS LEVEL_OF_REDUNDANCY > /etc/lounge/shards.conf`
 * copy `lounge-shard-init` to `/etc/init.d/`

 * start:
   * `/etc/init.d/lounge-shard-init`
   * `/etc/init.d/smartproxyd start`
   * `/etc/init.d/nginx-lounge start`


# Todo

 * log rotation for all shards/for couchdb_logs dir
 * seperate view dirs for all shards
 * figure out how to prefix the lounge install
 * provide a patch of /etc/init.d/nginx-lounge
 * provide a config script so ppl don't need to edit bash scripts
 * add replication_notifier.py to install/setup scripts
   * steps:

    apt-get install python-pycurl
    cd /couchdb/couchdb-lounge
    sudo install -m 755 replicator/replication_notifier.py /var/lib/lounge/

   * paste the following into `couchdb/etc/default.ini`:

    [update_notification]
    replicator = /usr/bin/python /var/lib/lounge/replication_notifier.py

# Possibly issues

 * `update_shards_map.py` seems to have a bug (if it generated an empty array in `/etc/lounge/shards.conf`, remove it)
 * nginx-lounge will refuse to start when `/etc/lounge/shards.conf` is incorrect

# Credits

 * Thanks to [Lena Herrmann][0] for testing. ;)
 * Thanks to [Randall Leeds][1] (of Meebo) for helping/debugging.
 * Thank you, [EasyBib][2], for allowing me to work on cool stuff.

[0]: http://lenaherrmann.net/
[1]: http://twitter.com/tilgovi
[2]: http://www.easybib.com/
