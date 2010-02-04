# What's this?

 * a bunch of scripts to get CouchDB-lounge setup
 * a work in progress
 * goal? - have deps, install them - be happy!

## loung-fest.sh

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
 * TODO: work in progress
