# Offscale.io Node Membership Tool


## Purpose

The purpose of the Node Membership Tool (NMT) is to allow distributed algorithm
nodes join and leave the network of that distributed algorithm, and for the
participating nodes each to have a view on who the other participants are. An
additional goal for NMT is arrangement of nodes into circles based on a metric
specified by the user.

A particular type of a distributed algorithm of interest is consensus. However
the application of NMT is not limited to consensus node membership and may span
other types of distributed algorithm, although that is only a possibility due to
the initial design and is not an immediately required feature.


## Outline of the Design


### Assumptions

We assume that nodes exchange messages via peer-to-peer, unreliable channels,
with a possibility of message reordering.

The starting set contains at least 3 nodes. Each of those nodes knows the rest
from the start.

Each circle may contain in the order of 10,000 nodes.


### Modules

1. Gossip graph builder: disseminates membership events (_alive_ or _faulty_)
   and maintains a local history of membership changes that can also be
   gossiped.  The membership list at a node can be computed by replaying the
   membership events in the gossip graph of that node. This component also
   implements the API to the client algorithm. This API is what Lachesis v2.0
   tests will use when accessing the membership circles. The membership circles
   are compiled at runtime from the local gossip graph.

2. Failure detector, switchable: either built-in (_ping_ or _ack_ or _pingreq_
   as in SWIM) or external via an API (possibly DAGx). Even when an external
   detector is configured, _pingreq_ messages should still be handled by the
   internal failure detector. In the prototype we will not have a built-in
   failure detector and will use a dummy external failure detector in order not
   to worry about the handling of _pingreq_ messages.

3. Node classifier: attributes a node into a circle based on a given user
   metric. This module contains a trait API for a user function that, given a
   node and membership circles not containing that node, places the node in a
   circle. Once the node is placed locally in a circle, the module outputs a
   gossip event.


### Crates

```
                          +                          +
                          |                          |
                          |   +------------------+   |   +------------------+
                          |   |                  |   |   |                  |
                          |   |                  |   |   |     external     |
                          |   | failure detector <-------+  failure detector|
                          |   |                  |   |   |                  |
                          |   |                  |   |   |                  |
                          |   +------------------+   |   +------------------+
                          |            |             |
                          |            |             |
     +----------------+   |   +--------v---------+   |
     |                |   |   |                  |   |
     |                |   |   |                  |   |
     |    tests       <------->  gossip graph    |   |
     |                |   |   |     builder      |   |
     |                |   |   |                  |   |
     +----------------+   |   +--------^---------+   |
             |            |            |             |
             |            |            |             |
             |            |   +------------------+   |
             |            |   |                  |   |
             |            |   |                  |   |
             +----------------> node classifier  |   |
                          |   |                  |   |
                          |   |                  |   |
                          |   +------------------+   |
                          |                          |
                          |                          |
                          |                          |
      test crate          |      node membership     |     failure detector
                          +           crate          +          crate
```


### Protocol

The protocol makes use of a local gossip graph at a node. The vertices in that
graph are events containing

1. a message,

2. a self-parent,

3. an other-parent,

4. the creator ID,

5. the cryptographic signature.

The reachability notions of being an ancestor, and seeing and strongly seeing
are the same as in HashGraph and Parsec.

Placement of a node X in a circle or removal of it requires agreement of a
supermajority of nodes (which can be restricted to the inner circle) in the
following sense: once a supermajority of nodes strongly see the node _alive_ or
_faulty_ event E in the gossip graph local to a node Y, node Y assumes that node
X placement or removal has been committed. Node Y then gossips the event E to
the nodes that do not strongly see E in the local gossip graph of node Y.


## Influences

### HBBFT DynamicHoneyBadger

[DynamicHoneyBadger](https://github.com/poanetwork/hbbft/blob/master/src/dynamic_honey_badger/mod.rs)
is a wrapper of the Rust implementation of HoneyBadgerBFT that adds a
distributed and strongly consistent node membership protocol where existing
nodes can propose and vote for adding or removing nodes from the network. This
protocol uses the blockchain to store the protocol state, that is, which nodes
are currently members in the network and which nodes are in transitional states.


### HashiCorp Serf

Serf is a tool for cluster membership, failure detection and recovery, and event
propagation. It uses a [gossip communication
protocol](https://www.serf.io/docs/internals/gossip.html). This protocol ensures
weak consistency of group membership knowledge. It was created to solve
scalability problems associated with traditional heart beat protocols. Weak
consistency of membership means that membership lists of different members are
allowed to be inconsistent across the group at any single moment in time.

Failure detection is done by monitoring processes using randomised peer-to-peer
probing. Group membership changes (and other events?) are gossiped as part of
ping and acknowledgement messages.

The membership list is made available to the application either directly in its
address space, or through a callback interface or an API.


### HashiCorp Consul

This is a tool for service discovery and configuration. The internal protocol is
based on the gossip protocol of Serf.


### HyParView

This is a membership protocol for reliable gossiped broadcast.


### Plumtree

Plumtree was created by the same team that created HyParView. It uses broadcast
trees for sending message payload. Channels that are not included in broadcast
trees are also used with a different purpose: failure recovery and broadcast
tree healing.


### MaidSafe Parsec

Parsec builds a gossip graph with its structure strongly influenced by HashGraph.


## Rust Crates

- [hbbft](https://github.com/poanetwork/hbbft) HoneyBadgerBFT.

- [swim-rs](https://github.com/mhallin/swim-rs) is an implementation of the SWIM
  gossip protocol of Serf.

- [hyparview](https://github.com/sile/hyparview) is an implementation of
  HyParView.

- [plumcast](https://github.com/sile/plumcast) is an implementation of Plumtree.

- [parsec](https://github.com/maidsafe/parsec/) MaidSafe PARSEC consensus.
