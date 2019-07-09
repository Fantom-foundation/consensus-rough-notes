# Offscale.io Node Membership Tool


## Purpose

The purpose of the Node Membership Tool (NMT) is to allow distributed algorithm
nodes join and leave the network of that distributed algorithm, and for the
participating nodes each to have a view on who the other participants are. A
particular type of such a distributed algorithm is decentralised
consensus. However the application of NMT is not limited to distributed
consensus and may span other types of distributed algorithm, although that is
only a possibility due to the initial design and is not an immediately required
feature. Distributed consensus in itself is a very big class of algorithms that
includes strongly consistent broadcast and, depending on your interpretation,
may also include weakly consistent broadcast.


## Outline of the Design

### Layers

NMT is a layer on top of a weakly or strongly consistent broadcast algorithm
such as those listed in **Rust Crates** below, or on top of a BFT consensus
algorithm. Note that weakly consistent broadcast can be more efficient than
strongly consistent broadcast and can scale to very large networks. NMT provides
an API to a replicated distributed algorithm node for reads and updates of the
membership list. The membership list is as consistent as the underlying
consensus protocol.


### Modules

The first module implements the membership list and the API to the client
algorithm. This API is what Lachesis tests will use when accessing the
membership list. The membership list structure is the same for any underlying
consensus algorithm.

The second module implements a plugin registry for pluggable consensus
algorithms using the [inventory crate](https://crates.io/crates/inventory). For
an example registry, see
https://github.com/poanetwork/parity-ethereum/blob/hbbft/ethcore/src/engines/registry.rs.

Each of the supported consensus algorithms must provide a compatible API. If it
does not exist yet, it should be introduced.


### Crates

```
                   +                     +
                   |  +----------------+ |       +--------+   +-----------+
                   |  |                | |       |        |   | Lachesis  |
+---------------+  |  |   membership   | |  +--->+  API   +-->+   v2.0    |
|               +---->+      list      | |  |    |        |   |           |
|  Tests        |  |  |                | |  |    +--------+   +-----------+
|               |  |  +--------+-------+ |  |
|               |  |           |         |  |    +--------+   +-----------+
+---------------+  |           v         |  |    |        |   |           |
                   |  +--------+-------+ |  +--->+  API   +-->+consensus 1|
                   |  |                | |  |    |        |   |           |
                   |  |     plugin     | |  |    +--------+   +-----------+
                   |  |    registry    +--->+
                   |  |                | |  |    +--------+   +-----------+
                   |  +----------------+ |  |    |        |   |           |
                   |                     |  +--->+  API   +-->+consensus 2|
  test crate       |   membership tool   |       |        |   |           |
                   +        crate        +       +--------+   +-----------+

                                                    consensus crates
```


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


## Rust Crates

- [hbbft](https://github.com/poanetwork/hbbft) HoneyBadgerBFT.

- [swim-rs](https://github.com/mhallin/swim-rs) is an implementation of the SWIM
  gossip protocol of Serf.

- [hyparview](https://github.com/sile/hyparview) is an implementation of
  HyParView.

- [plumcast](https://github.com/sile/plumcast) is an implementation of Plumtree.
