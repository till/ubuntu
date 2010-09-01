#!/usr/bin/env python
import zlib

key = 'foo'

def lounge_hash(key, num_shards):
  return (zlib.crc32(key, 0) >> 16) % num_shards

shard_hash = lounge_hash(key, 16)


print shard_hash
print (zlib.crc32(key, 0))
print (zlib.crc32(key, 0) >> 16)