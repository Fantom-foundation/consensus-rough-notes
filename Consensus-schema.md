The main issue
--
We rely on hashes of events and digital signatures - they provide no guarantee of being collision-free.
Additional research need to be done on what to do in case of such a collision.

# Schema of the Consensus layer

The black box view: the consensus layer receives events/transactions from locally connected clients and output two streams:

1. one of events from all participating nodes got into finality; it is guaranteed the events output in the same order on every participating nodes;
2. and the second of all events deemed invalid, meaning they will never get into finality (this mostly happens on invalid signature verification).


Two tasks/problems the consensus layer solves:

1. detecting if a node goes unresponsive so it would not be waited to commit a round into finality;
2. creating a linear order of all events of a frame based on lamport timestamps of the events and synchronisation patterns.


# DAG0

DAG0 version is simplified version of the algorithm without faulty node detection (assuming there is no Byzantine fault neither). The main goal of this version is
to provide base ground allowing to start implementing proofs in TLA+ and Coq.



The node (a peer)
==
The node is an autonomous participant in the network of Consensus, usually it's a standalone node, however, we consider a node any instance following this protocol and having the following unique attributes within the network:

* a pair of private/public key; the firstly created public key of the node becomes its unique identifier and must not change.
* an IP address and port number on which this node operates following DAG0 protocol.

The list of these unique attributes of the all nodes of the networks forms the peer list.

Other attributes of the node:

* current Lamport time on the node;
* current height number, indicating the index of the last event created by the node;
* current frame number;
* last finalised frame number.

Node procedures
--
1. Node main procedures, running in parallel:

* procedure A
```
loop:
    start heartbeat timer;
    select a peer, P, following peer selection algorithm;
    execute node sync procedure with peer P;
    wait until heartbeat timeout.
```
* procedure B
```
loop:
    receive a sync request from a peer, A;
    execute node sync reply procedure for peer A.
```

2. Frame finalisation procedure:

* all events in the frame are sorted according following rules:

 1. Smaller Lamport timestamp has priority;
 2. Smaller creator's index has priority;
 3. Smaller Lamport timestamp of `other (grand-)*parents` (recursively up to leaf events);
 4. Smaller hash value

*NB*: For large number of peers in the network, the Rule 3 would require significant amount of storage access operations and thus could be omitted or relaxed to other-parent's Lamport timestamp only.

* sorted events are finalised in the order.


3. Event finalisation procedure:

* process external transaction payload by pushing each transaction to the consumers;
* process internal transactions;
* strip off flag table (to save storage space, optional)

4. Node sync procedure (Procedure A):

* Send current gossip list and lamport time value to remote peer; (`SyncReq`->)
* receive a reply consisting of remote gossip list, remote lamport time value and pack of unknown messages; (`SyncReply`<-)
* process all unknown messages one by one in order in the pack by executing event insertion procedure for every unknown event;
* merge remote gossip list into current gossip list;
* set the lamport time value of the current node to the maximum of its current value and remote lamport time value;
* create a new event if needed referring the remote peer as other-parent.

5. Node sync reply procedure (Procedure B):

* receive remote gossip list and remote lamport time value; (`SyncReq`<-)
* create a bundle of all known messages not known by remote peer (these are events from each known peer whose lamport timestamp greater or equal to the value from corresponding coordinate in the remote gossip list);
* send bundled events to the remote peer along with current gossip list and current lamport time value; (`SyncReply`->)
* set the lamport time value of the current node to the maximum of its current value and remote lamport time value.

Lamport time
==
Lamport time is a virtual clock of a node that follows these rules:

1. there are two strategies to initialise it; one is with all nodes starts with its value set to 0, the other is to initialise it with the value of 13th byte of the node unique identifier; the former gives bigger number of events having the very same lamport timestamps in initial rounds of the algorithm;
2. on creation of an event the node increases its lamport time by 1 before assigning timestamp to the event;
3. on synchronisation with other peer the lamport time is set to the maximum value of lamport time on both peers.


Peer list
==
Peer list is the list of all members of the network of DAG0 nodes; each peer has the following attributes:

* unique id of the peer (PubKey; the first created public key of the node becomes its unique identifier which must not change)
* ip address and the port number of inter-dag-node network (port used by nodes to communicate with each other; default 12000)


Next peer selection
--
All peers are sorted by PubKey and there are `n` peers in total, `n > 1`;
`current` is the index of the current peer deciding on the next one to sync with.
`r` is the round number starting with `n >> 1` and `r >= 1`.
```
next = (current + r) % n
r = (r > 1) ? r >> 1 : n >> 1
```
where `%` is modulo n operation, `>>` is the operation of binary shift to the right.

Another, though simplified, approach would be to select next peer randomly from the peer list exclude current node and recently contacted peer. This approach is closer to real byzantine-like behaviour of a node not following prescribing next peer selection procedure but may lead to less optimal peer synchronisation pattern.

It is a question to simulation/modelling code to see how Next peer selection algorithm affects overall performance of the consensus layer.


Gossip list
==
Gossip list stores lamport timestamp and `height` value for every peer indicating when each peer has been communicated/seen last and what is the last event number known from that creator (of that peer created events);
Merging two gossip lists: the highest value of lamport timestamp corresponding to a peer in both lists is taken into merged gossip list.


Event
==
event is an atomic block of exchange between peers. The structure of the event:

* creator's public key
* creator's height index
* self-parent hash
* other-parent hash
* lamport timestamp
* transaction payload
* hash of all fields above
* map of digital signatures of the hash field above; one per each peer has been passed by
* frame number
* flag table

`frame number` and `flag table` fields are not passing over network in communication between nodes.

*NB*: signing hash field and all fields used in hash calculation provides better protection in case of hash collision but is more computational expensive.

Transaction payload
--
Transaction payload is an array of user transactions (could be an empty) following an array of internal transactions (could be an empty).
Internal transactions are used to handle dynamic node participation; to disseminate information about events failed in the consensus (or any future functionality within consensus layer).

Leaf event
--
Leaf event is the first event of a peer. It has special status as follow:

* it is created once a peer added into the network
* it has empty transaction payload.
* its index value is 0 (index is equal to creator's height at the time of event creation).
* its lamport timestamp is set to the initial value of node lamport time.
* its parents' hashes are set to zero.
* its Flag table table contains only that leaf event itself with value of frame equal to the current frame at the time of peer addition (at the time of network initialisation the value of current frame is 0);

The idea is that all leaf events can be created once corresponding peer is added into the network on each participating node; this means no communication is needed to pass leaf events between nodes and every new added peer knows leaf events of all other participants.

Event creation
--
A new event may be created after each time a node synchronises with other peer following `procedure A` and one of the following conditions is met:

* it has pending transactions received from clients or internal transactions not yet added into any other event;
* there is at least one known to the node non-finalised event with non-empty payload.

Event's attributes are filled following these rules:

* creator's pubkey is set to the pubkey of the current peer (who creates the event);
* creator's height index is set to the next index of the event created by the current peer (DAG0 doesn't rely on uniqueness of this value for all events created by a peer, though this property is for convenience);
* self-parent hash is set to the hash (ID) of the last event created by current peer;
* other-parent hash is set to the hash (ID) of the last known event of the peer just communicated following `procedure A`;
* lamport timestamp is set to the next value of the node lamport time (node's lamport time is increased by 1 before assigning to the event);
* transaction payload is created from pending internal and external (from customers) transactions;
* calculate hash (control sum) of the values of all fields above;
* sign hash above (or all fields above) with node's private key and put it into signatures map;
* the values of its frame number and flag table are calculated in event insertion procedure.


Event insertion procedure
--
Event insertion procedure is executed each time an event is inserted into local storage of a node and calculates these attributes of the event: frame number; flag table.

```
if self-parent.Frame == other-parent.Frame {

	rootFlagTable = strict-merge-flag-tables(self-parent.Frame, self-parent.FlagTable, other-parent.FlagTable)
	creatorRootFlagTable = derive-creator-table(rootFlagTable)

	if len(creatorRootTable) >= rootMajority {
		root = true
		frame = self-parent.Frame + 1
	} else {
		root = false
		frame = self-parent.Frame
	}

} else if self-parent > other-parent.Frame {
	root = false
	frame = self-parent.Frame
} else {
	root = true
	frame = other-parent.Frame
}
event.frame = frame
visibilisFlagTable = open-merge-flag-tables(node.last-finalised-frame  + 1, self-parent.visibilisFlagTable, other-parent.visibilisFlagTable)
if root {
	visibilisFlagTable[event.Hash] = frame
}
event.FlagTable = visibilisFlagTable
Store.InsertEvent(event)
creatorVisibilisFlagTable = derive-creator-table(visibilisFlagTable)
if len(creatorVisibilisFlagTable)=size(peer list) {
	frame-to-finalise-upto=min-frame-in-flag-table(creatorVisibilisFlagTable)
	for (frame = node.last-finalised-frame + 1; frame < frame-to-finalise-upto; frame++) {
		frame-finalisation-procedure(frame);
		node.last-finalised-frame + 1
	}
}
```


Block
==
Block is a set of events coming into finality all-together (in the current schema these events are from the same frame). In general, it is not required to have the very same events in the same frame on each node in condition the whole stream of events is ordered uniformly on every node. However, for compatibility with some applications (e.g. blockchain based cryptocurrencies) it would be required to bundle transactions into blocks uniformly across all nodes. Thus the goal of the DAG protocol is to ensure all peers choose the same events into each block and in the same order, but additional research might be requires to ensure this condition is met.


Rootmajority
==
Rootmajority is any number indicating threshold number of visible roots from current frame for an event before that event becomes root of a new frame.
This parameter is intended to regulate roughly the number of events of the same creator in a single frame. Could be of any
value strictly between `1` and `n`; `(n + 3) / 3` could be a good initial value for it. Additional research is required to see if that parameter could be per-node parameter (with modification of it value via internal transactions).


Flag table
==
A flag table is a map used in DAG algorithm. It stores  hashes (IDs) of visible roots; for each root it stores frame number of that root. `{event.hash: frame_number}`

Flag table merging procedure
--
1. Open procedure:

Open flag table merging procedure takes two flag tables and the frame number and forms a new flagtable which contains only those entries from any of source flag tables whose corresponding frame number is equal or greater to the frame number specified.

2. Strict procedure:

Strict flag table merging procedure takes two flag tables and the frame number and forms a new flag table which contains only those entries from any of source flag tables whose corresponding frame number is equal to the frame number specified.

Creator table derivation procedure
--
This procedure takes a flag table as an input and produce a map which stores creator's hashes of visible roots; for each root it stores minimal frame number. `{creator: min(x.frame_number) for x in keys of flagtable and x.creator = creator`}
```
result-creator-table = {}
for each pair (event.hash, frame_number) in input-flag-table
	creator = event.creator_hash
	if not exists result-creator-table{creator} ; then
		result-creator-table{creator} = frame_number
	else if result-creator-table{creator} > frame_number ; then
		     result-creator-table{creator} = frame_number
		 end
	end
```

Root
==
Leaf events are roots by default; Any event visible by `Rootmajority` roots of previous frames becomes root.

Visibilis
==
An event becomes Visibilis when the of its creator flag table becomes equal to the number of peers in the network. Once an event becomes Visibilis on the current node, the current node executes frame finalisation procedure.

Frame number
==
Frame number is a characteristic of an event which initial value is calculated in the event insertion procedure.

Frame
--
Frame is a set of all messages in the network having the same frame number.


# DAG1

This version includes iresponsive node detection mechanism allowing fault-tolerance.

Iresponsive node detection architecture could be based on [GEMS paper](papers/GEMS-Gossip-Enabled-Monitoring-Service-for-Scalable-Heterogeneous-Distributed-Systems-10.1.1.160.2604.pdf). We could also employ reachability algorithm based either on [Thorup's Algorithm](https://en.wikipedia.org/wiki/Reachability#Thorup's_Algorithm), either on [Kameda's Algorithm](https://en.wikipedia.org/wiki/Reachability#Kameda's_Algorithm); though these algorithms require graph to be planar which might be not the case of DAG with random peer connection pattern.


Node procedures different to ones of DAG0
==
1. Node main procedures, running in parallel:

* procedure A
```
loop:
  start heartbeat timer;
  select a peer, P, following peer selection algorithm;
	request a sync with peer P;
	sync all known events, gossip list/matrix and suspect list/matrix with peer P;
	check if conditions of current frame finality are met and close the current frame if yes;
	wait until heartbeat timeout.
```
* procedure B
```
loop:
    receive a sync request from a peer, A;
	sync all known events, gossip list/matrix and suspect list/matrix to peer A.
```


Byzantine fault
==
Definition: Byzantine fault is a condition when a participating peer/node presents different symptoms to different observers, intentionally or due to a specific failures.

Byzantine fault in case of DAG1: a creator sends different events with the same height number to different peers. There are two approaches to solve this issue:

1. Order such events by secondary attributes, e.g. lamport timestamp, parents' lamport timestamps, hashes of these events; thus we will order uniformly all correct events;
2. report such events as an error (a fork) and mark the creator of such events as faulty effectively excluding events of that creator from the current and further frames until the issue resolved (or that peer is deleted from the peer list).

Gossip list
==
Gossip list stores the pair of frame number and lamport timestamp for every peer indicating when each peer has been communicated/seen last;
Merging two gossip lists: the highest value of lamport timestamp corresponding to a peer in both lists is taken into merged gossip list.

Gossip matrix
==
Gossip lists from all peers ordered ordered by peer's pubkey form Gossip matrix.


Suspect vector/list and gossip matrix
==
Suspect vector is a vector whose *i*th element is set to 1 if peer *i* is suspected to have failed; otherwise is set to 0.
A peer is suspected to have failed in a frame if the lamport timestamp from gossip list corresponding to that peer is less
than the value in frame list corresponding to that frame.
The suspect vectors of all n peers form suspect matrix.

Postremus
==
Any visibilis visible second time to all peers (visible to all after becoming visibilis) becomes postremus.

Frame list
==
The map of all not finalised frames of a node; it stores frame numbers and for each frame number it associates the maximal lamport timestamp of an event in that frame.

Postremus procedure
--
When a peer detects new postremus the following procedure is performed:

* all parents who has not been market finalised are market finalised;
* if all events of the last not finalised frame are marked finalised that frame is finalised.

Majority
==
Majority is any number greater than `n/2`, where `n` is the number of peers. Majority of peers need to be deemed correctly running in the current frame to allow current frame be finalised.


Supermajority
==
Supermajority is any number greater than `(2n + 1) / 3`, where `n` is the number of peers. Supermajority of peers need to vote for the same resolution of a Byzantine fault.

Flag table
==
Flag table is a map indicating visibility of an event for root events of current or further frames;
Two versions of additional condition:

1. it stores hashes of visible roots; for each root it stores frame number at which this root becomes visible; or
2. it stores ID of creators whose roots are visible; for each creator it stores frame number at which this root becomes visible.
