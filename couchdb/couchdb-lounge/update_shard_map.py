#!/usr/bin/env python
#
# Credits:
# http://code.google.com/p/couchdb-lounge/wiki/ShardsConfandYou

import sys
try:
    import json
except ImportError:
    # python < 2.6 
    import simplejson as json

def next(i, lst):
    """Increment a list index with wraparound."""
    return (i+1)%len(lst)

def remove_dupes(lst):
    """Remove duplicates from a list, not preserving order."""
    return dict([(el, 1) for el in lst]).keys()

def has_dupes(lst):
    """Determine if a list contains any duplicate entries."""
    return len(lst)!=len(remove_dupes(lst))

def validate(node_map, nodes):
    """Check if a node map is acceptable:

    1. Nodes should all have approximately the same number of primary shards.
    2. A shard should not be replicated to the same node twice.

    This is just a sanity check.  If the map generating algorithm is valid,
    this function should always succeed.
    """
    shard_count = [0 for node in nodes]
    for map in node_map:
        # condition 2: no repeated nodes in replication map for a given shard
        assert (not has_dupes(map)), "Shard %s has duplicates in its replication map" % shard
        primary = map[0]
        shard_count[primary] += 1
    
    # condition 1: check that shards are distributed evenly 
    min, max = 9999999, -1
    for count in shard_count:
        if count < min:
            min = count
        if count > max:
            max = count
    spread = max - min
    assert (0 <= spread and spread <= 1), "Shards are not distributed evenly"

def main(nodefile, num_shards, redundancy):
    num_shards = int(num_shards)
    redundancy = int(redundancy)
    shards = range(num_shards)
    nodes = []
    for node in file(nodefile).readlines():
        item = node.split()
        if len(item) == 1:
            item.append(5984)
        nodes.append(item)

    nodes.sort()

    assert redundancy < len(nodes), "You can't have n+%d redundancy with %d nodes." % (redundancy, len(nodes))

    # assign shards to nodes
    node_map = [[] for shard in shards]
    node_i = 0
    # shard1: A, B, C, D ...
    # shard2: B, C, D, E ...
    # and so, wrapping around
    for shard in shards:
        # node_i is the primary 
        node_map[shard].append(node_i)

        # node_j is the secondaries
        node_j = next(node_i, nodes)
        for k in range(redundancy):
            node_map[shard].append(node_j)
            node_j = next(node_j, nodes)

        node_i = next(node_i, nodes)
    
    validate(node_map, nodes)
    print json.dumps(dict(shard_map=node_map, nodes=nodes))

if __name__=='__main__':
    if len(sys.argv)!=4:
        print "Usage: update_shard_map <node list file> <number of shards> <level of redundancy>"
        sys.exit(1)
    try:
        main(*sys.argv[1:4])
    except AssertionError, e:
        print "Replication map is invalid:", str(e)
        sys.exit(1)
    except:
        raise
