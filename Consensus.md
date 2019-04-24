Offscale DAG-based Consensus overview
-------------------------------------

There are three types of consensus algorithms:

 1. [Proof-of-Work](https://en.bitcoinwiki.org/wiki/Proof-of-work)
 2. [Proof-of-Stake](https://en.bitcoinwiki.org/wiki/Proof-of-stake)
 3. DAG (Directed Acyclic Graph) based consensus algorithm

Section "1.2 Related Work" from [DEXON:A Highly Scalable, Decentralized DAG-Based Consensus Algorithm](https://eprint.iacr.org/2018/1112.pdf) outlines differences in these types of Consensus:

> *Proof-of-Work* Bitcoin [Nak08] is the first blockchain protocol whose consensus delivers Nakamoto consensus. This means that the Bitcoin system solves a mathematical puzzle as a proof to generate next block, and once a block has been followed by six continuous blocks, the block is confirmed.  This mechanism causes Bitcoin to have a latency of approximately one hour.  Even more problematically, proof-of-work-based consensus consumes exorbitant quantities of energy.

> *Proof-of-Stake* Numerous  proof-of-stake  consensus  systems  [GHM+17,  HMW,  BHM18,  DGKR18]  have  been proposed  in  recent  years.   In  these  schemes,  the  nodes  with  adequate  stakes  have  the  right  to  propose  their blocks.  The probability that a node can propose a block is proportional to the stakes the node owns.

> *DAG-based consensus* Phantom, SPECTRE, IOTA, Conflux, and Mechcash are DAG-based consensus systems,all  of  which  are,  at  their  core,  variants  of  the  Nakamoto  consensus.   This  leads  two  disadvantages:   first, these  systems  demonstrate  low  performance  (throughput  is  low  and  latency  is  long);  second,  the  finality  is probabilistic, allowing some attacks (such as selfish-mining) to exist.  To conclude, constructing a DAG-based consensus with the Nakamoto consensus limits performance and safety.

> Algorand is a breakthrough proposed by Gilad et al.  [GHM+17], that reduces the communication complexity from *O(n^2)* to *O(n ln n)* and thus supports large population of nodes (e.g.  500K nodes).  They use a verifiable random function (VRF) to protect nodes from DDoS attack, and the VRF is also a lottery that decides which node has the right to propose a block or to vote for each round of their Byzantine agreement protocol.  The consensus of Algorand is based on Byzantine agreement among samples from the whole set of nodes.  Thus, the probability of the correctness of whole system is based on hypergeometric distribution.  This is the reason why Algorand can only tolerate less than one third of total number of nodes to be malicious while Algorand achieves high decentralised. 

> Dfinity [HMW] is a permissioned blockchain and is designed for large population of nodes (around 10K nodes). Dfinity contains a randomness beacon which generates new randomness by a VRF with information from new confirmed block.  They use the output of a VRF to select a leader and electors for a round.  By hypergeometric distribution,  Dfinity  only  samples  hundreds  of  nodes  to  notarise  a  block  instead  of  using  all  nodes,  and  the correctness holds with high probability.

> The consensus of Hashgraph [BHM18] adopts Byzantine agreement on a graph and their round-based structure costs a latency of *O(ln n)* for each round of Byzantine Agreement, which means its confirmation time increases with the number of nodes.  This limits the decentralised level of Hashgraph.

References:

 * [Nak08; Satoshi Nakamoto.  Bitcoin:  A peer-to-peer electronic cash system, 2008.](https://bitcoin.org/bitcoin.pdf);
 * [GHM+17; Yossi Gilad, Rotem Hemo, Silvio Micali, Georgios Vlachos, and Nickolai Zeldovich. Algorand: Scal-ing byzantine agreements for cryptocurrencies. InProceedings of the 26th Symposium on OperatingSystems Principles, SOSP ’17, pages 51–68, New York, NY, USA, 2017. ACM.](http://delivery.acm.org/10.1145/3140000/3132757/p51-gilad.pdf?ip=203.206.230.39&id=3132757&acc=OA&key=4D4702B0C3E38B35%2E4D4702B0C3E38B35%2E4D4702B0C3E38B35%2EFD1C447234F14652&__acm__=1556073074_d3cb67ff2ad176041c2fe61d68a1b809)
 * [HMW; Timo Hanke, Mahnush Movahedi, and Dominic Williams.  Dfinity technology overview seriescon-sensus  system.    Whitepape](https://dfinity.org/pdf-viewer/pdfs/viewer?file=../library/dfinity-consensus.pdf)
 * [BHM18; Leemon Baird, Mance Harmon, and Paul Madsen. Hedera: A governing council & public hashgraph network.   Whitepaper,  May  2018.](https://s3.amazonaws.com/hedera-hashgraph/hh-whitepaper-v1.1-180518.pdf)
 * [DGKR18; Bernardo  David,  Peter  Gazi,  Aggelos  Kiayias,  and  Alexander  Russell.    Ouroboros  praos:   Anadaptively-secure,  semi-synchronous  proof-of-stake blockchain.  InAdvances  in  Cryptology  -  EU-ROCRYPT 2018 - 37th Annual International Conference on the Theory and Applications of Cryp-tographic  Techniques,  Tel  Aviv,  Israel,  April  29  -  May  3,  2018  Proceedings,  Part  II, pages 66–98,2018.](https://cryptorating.eu/whitepapers/Cardano/573.pdf)

Offscale is engaged in development of DAG-based Consensus algorithm.
It all has started from implementation of Fantom Foundation's Lachesis protocol,
but we have identified several major issues with it which need to be addressed
to have a working scalable Consensus algorithm:

 * Topological consensus on total ordering (later just ordering until otherwise specified) in Lachesis sorts events first by Atropos time, then by Lamport timestamp and then by event hash value. Offscale has identified that this ordering lead to having no consensus on ordering starting with much less number of nodes than anticipated. In addition, in some cases it may lead to reverse ordering for events from the very same node, which contradicts to initial requirement of preserving order of events from the very same node. 

 Offscale believes the better approach to resolve ambiguity in event ordering would be sorting first by Lamport timestamp and then by Atropos timestamp and finally by event hash value.

 * Lachesis protocol uses post-history to calculate Atropos timestamps. That causes delay until receiving next events from participating block before a node would be able to take a decision on Atropos time; secondly all nodes would receive new events in different order which leads to different results in Atropos time calculation among all nodes.

 Offscale believes it is better to use pre-history to calculate Atropos time. That guaranties each node would have the same pre-history for each event received; in addition Atropos time can be calculates as soon as an event is selected as an Atropos.

 We were able to resolve issues mentioned above and archive consensus on ordering uniformly on up to 22 nodes, while original version of Lachesis has intermittent inability to reach consensus on order of events starting from 7 nodes and permanently has no consensus on ordering starting with 11 nodes. Though the modifications made into DAG-based algorithm makes it significantly different to Lachesis protocol.


 * The remaining issue is related to the fact that Lachesis protocol is missing a mechanism deciding if current frame is closed, i.e. there will be no more events added into the frame from any participating node, and it is safe to start event ordering. That case is also reflects inability in the current design of the protocol to detect if a node went down or abnormally slow. That issue causes premature event ordering for the current frame resulting in an additional event arrival into current frame after the frame is finalised and pushed out. Consequently the procedure what to do with such late arrived events is not defined either.

 Offscale is working on the solution for this issue. Estimated delay in taking decision on a frame is *O(log n)*, where *n* is the number of nodes in the network and the logarithm base is equal to the number of parents taken for each event (currently we use 2 parents).
 
Please note, other protocols approach this problem with either electing a leader, who then decides on event ordering, either introducing a mechanism of synchronisation between nodes allowing frame "closure" within allocated time interval. We keen to find a method for "soft" synchronisation between nodes allowing dead node detection and automatic frame closure uniformly among all participating nodes.


Architecture of DAG-based consensus
-----------------------------------

The main difference of DAG-based consensus to Proof-of-Work and Proof-of-Stake consensuses is the absence of explicitly defined block of transactions as it is assumed for DAG-based consensus that every participating node would allocate the very same set of transactions in events within each frame and then sort that set of transactions uniformly on every node.

Therefore the Consensus node is seen by a client as a black-box receiving transactions from the client and giving back validated transactions received from all nodes in the network guaranteed to be ordered uniformly on all nodes of the network (including transaction fed through current node), i.e. each node in the network receives all transactions fed into the network in the very same order. Additional guarantee is that the order of transactions fed into the network from a particular node is preserved.

Thus the Consensus is not able to verify validity of any transaction fed into the network and that decision must be taken by upper layer, either it is a payment system, either a distributed database, either any other application.


Consensus on order vs Consensus on "it's happened"
--------------------------------------------------

Consensus on the fact that an event "has happened" is less strong than consensus on total event ordering and thus can be achieved faster and with less computation done. 

If an upper layer do not required uniformed order of the transactions on each node, the higher transactions throughput can be archived with a reduced version of the Consensus algorithm. And it does not required remaining issue of DAG-bases consensus to be solved.

