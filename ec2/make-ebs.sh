#!/bin/bash

EBS_DEVICE=/dev/sdf
EBS_VOL=/couchdb

mkfs.ext3 $EBS_DEVICE
mount -t ext3 $EBS_DEVICE $EBS_VOL
echo "${EBS_DEVICE}  ${EBS_VOL}  ext3    defaults 0 0" >> /etc/fstab
