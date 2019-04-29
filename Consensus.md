Offscale DAG-based Consensus overview
-------------------------------------

There are [several types of consensus algorithms](https://hackernoon.com/a-hitchhikers-guide-to-consensus-algorithms-d81aae3eb0e3):

 1. [Proof-of-Work](https://en.bitcoinwiki.org/wiki/Proof-of-work)
 2. [Proof-of-Stake](https://en.bitcoinwiki.org/wiki/Proof-of-stake)
 3. Delegated Proof-of-Stake (DPoS)
 4. DAG (Directed Acyclic Graph) based consensus algorithm
 5. [Proof-of-Storage](https://github.com/ethereum/wiki/wiki/Problems#9-proof-of-storage)
 6. Proof-of-Authority (PoA)
 7. [Proof-of-Storage](https://github.com/ethereum/wiki/wiki/Problems#9-proof-of-storage)
 8. Proof-of-Weight
 9. Byzantine Fault Tolerance (BFT)

Section "1.2 Related Work" from [DEXON:A Highly Scalable, Decentralized DAG-Based Consensus Algorithm](https://eprint.iacr.org/2018/1112.pdf) outlines differences in these types of Consensus:

> *Proof-of-Work* Bitcoin [Nak08] is the first blockchain protocol whose consensus delivers Nakamoto consensus. This means that the Bitcoin system solves a mathematical puzzle as a proof to generate next block, and once a block has been followed by six continuous blocks, the block is confirmed.  This mechanism causes Bitcoin to have a latency of approximately one hour.  Even more problematically, proof-of-work-based consensus consumes exorbitant quantities of energy.

Known implementations: [Bitcoin](https://bitcoin.org/); [Euthereum](https://ethereum.org/); [Litecoin](https://litecoin.org/); [Dogecoin](http://dogecoin.com/).

> *Proof-of-Stake* Numerous  proof-of-stake  consensus  systems  [GHM+17,  HMW,  BHM18,  DGKR18]  have  been proposed  in  recent  years.   In  these  schemes,  the  nodes  with  adequate  stakes  have  the  right  to  propose  their blocks.  The probability that a node can propose a block is proportional to the stakes the node owns.

Known implementations: [Decred](https://www.decred.org/); [Ethereum](https://github.com/ethereum/wiki/wiki/Proof-of-Stake-FAQ); [Peercoin](https://peercoin.net/)

Ethereum Wiki page [ETHWP8] lists several problems with PoS approach, the major one is "Nothing at Stake":
> If there’s a fork in the chain, the optimal strategy for any validator is to validate on every chain, so that the validator gets their reward regardless of the outcome of the fork.[src](https://medium.com/@jonchoi/ethereum-casper-101-7a851a4f1eb0)

The problem is described in this [video](https://www.youtube.com/watch?v=pzIl3vmEytY)

*Delegated Proof-of-Stake* Is different from PoS as token holders vote to elect delegates to do validation of the blocks. The validators are shuffled periodically and given an order to deliver theirs blocks in. The number of validators is kept between 20 and 100. The main disadvantage of DPoS is its partially centralized architecture.

Known Implementations: [Steemit](https://steemit.com/@zanewithspoon); [EOS](https://eos.io/); [BitShares](https://bitshares.org/).

*Delegated Asynchronous Proof-of-Stake (DAPoS)* - see [Dispatch Protocol: Introduction to DAPoS](https://github.com/dispatchlabs/TechnicalDocs/blob/master/Introduction%20to%20DAPoS.pdf)

> *DAG-based consensus* Phantom, SPECTRE, IOTA, Conflux, and Mechcash are DAG-based consensus systems,all  of  which  are,  at  their  core,  variants  of  the  Nakamoto  consensus.   This  leads  two  disadvantages:   first, these  systems  demonstrate  low  performance  (throughput  is  low  and  latency  is  long);  second,  the  finality  is probabilistic, allowing some attacks (such as selfish-mining) to exist.  To conclude, constructing a DAG-based consensus with the Nakamoto consensus limits performance and safety.

> Algorand is a breakthrough proposed by Gilad et al.  [GHM+17], that reduces the communication complexity from *O(n^2)* to *O(n ln n)* and thus supports large population of nodes (e.g.  500K nodes).  They use a verifiable random function (VRF) to protect nodes from DDoS attack, and the VRF is also a lottery that decides which node has the right to propose a block or to vote for each round of their Byzantine agreement protocol.  The consensus of Algorand is based on Byzantine agreement among samples from the whole set of nodes.  Thus, the probability of the correctness of whole system is based on hypergeometric distribution.  This is the reason why Algorand can only tolerate less than one third of total number of nodes to be malicious while Algorand achieves high decentralised. 

> Dfinity [HMW] is a permissioned blockchain and is designed for large population of nodes (around 10K nodes). Dfinity contains a randomness beacon which generates new randomness by a VRF with information from new confirmed block.  They use the output of a VRF to select a leader and electors for a round.  By hypergeometric distribution,  Dfinity  only  samples  hundreds  of  nodes  to  notarise  a  block  instead  of  using  all  nodes,  and  the correctness holds with high probability.

> The consensus of Hashgraph [BHM18] adopts Byzantine agreement on a graph and their round-based structure costs a latency of *O(ln n)* for each round of Byzantine Agreement, which means its confirmation time increases with the number of nodes.  This limits the decentralised level of Hashgraph.

In [IOTA] each transaction is presented as a vertex in DAG and must consfirm two previos unapproved yet transactions (called tips). The trategy to choose tips to approve is very important and is a key to IOTA technology. In case of conflict a transaction with bigger confimation chain is chosen. Each transaction has confirmation confidence. Every 2 minutes IOTA foundation issues milestone transaction and all transactions approved by it are considered to have confirmation confidence of 100% immediately.

In RainBlocks/Nano [RAIBLK] uses block-lattice structure where each account mentains its own chain that only thay can write to, end everyone holds a copy of all chains. Each fund transfer consists of two transactions: send and receive. In case of conflicting transactions referencing the same block a voting process is started, it uses broadcasting to M voting repreentatives. The block with majority votes wins.

Known implementations: [IOTA](https://iota.org/); [Hashgraph](https://hashgraph.com/); [RaiBlocks/Nano](https://www.raiblocks.net/)

*Proof-of-Authority* is a consensus algorithm where transactions are validated by approved accounts/participants (kind like the "admins" of the system). This is a centralised system. Known implementations: [POA.Networks](https://poa.network/); [Euthereum Kovan testnet](https://kovan.etherscan.io/)

*Proof-of-Storage* Storage and bandwidth are scarce computational resources other to computational power and currentcy.
Known implementations: [Permacoin]; [Torcoin]

*Proof-of-Weight* is similar to PoS, but probability of "discovering" next block depends on some other to stake weighted value. *Proof-of-Reputation* can be accounted into this category. Known implemntations: [Algorand](https://people.csail.mit.edu/nickolai/papers/gilad-algorand-eprint.pdf); [Filecoin](https://filecoin.io/); [Chia](https://chia.network/)

*Byzantine Fault Tolerance (BFT)* is based on [classic problem in distributed computing](https://people.eecs.berkeley.edu/~luca/cs174/byzantine.pdf). Several cryptocurrency protocols use some version of BFT to come to consensus. [*Practical Byzantine Fault Tolerance (PBFT)*](http://pmg.csail.mit.edu/papers/osdi99.pdf) is in use by [Hyperledger Fabric](https://www.hyperledger.org/projects/fabric) with few < 20 preselected generals running PBFT. Drawbacks: Centralised/Permissioned. *Federated Byzantine Agreement (FBA)* - a solution to Byzantine genaral problem when each general responsible for their own chain and sorts messages as their come in to establish truth. Known implementations: [Stellar](https://www.stellar.org/); [Ripple](https://developers.ripple.com/xrp-ledger-overview.html).


Offscale engagement
-------------------

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

List of attacks on Consensus
----------------------------
 1. [Nothing-at-stake problem](https://ethereum.stackexchange.com/questions/2402/what-exactly-is-the-nothing-at-stake-problem)
 2. [Long range attack](https://blog.ethereum.org/2014/05/15/long-range-attacks-the-serious-problem-with-adaptive-proof-of-work/)
 3. [Sybil attack](https://en.wikipedia.org/wiki/Sybil_attack) E's of Sybil Resistance: Entry Cost; Existance Cost; Exit Penalty.
 4. [51% attack](https://www.investopedia.com/terms/1/51-attack.asp) See [www.crypto51.app on github](https://github.com/tdickman/crypto51)
 5. *Block Gap Synchronisation*: a block may not be properly broadcasted, causing the network to ignore subsequent blocks. [RAIBLK]
 6. *Transaction flooding*: a malicious entity could send many unnecessary but valid transactions [RAIBLK]. Solution: each transaction must incure a fee.
 7. *Penny-Spend Attack*: an attacker spends very small quantities to a large number of accounts in order to waste storage resources of nodes [RAIBLK].

References
----------

 * [Nak08; Satoshi Nakamoto.  Bitcoin:  A peer-to-peer electronic cash system, 2008.](https://bitcoin.org/bitcoin.pdf);
 * [GHM+17; Yossi Gilad, Rotem Hemo, Silvio Micali, Georgios Vlachos, and Nickolai Zeldovich. Algorand: Scaling byzantine agreements for cryptocurrencies. InProceedings of the 26th Symposium on OperatingSystems Principles, SOSP ’17, pages 51–68, New York, NY, USA, 2017. ACM.](http://delivery.acm.org/10.1145/3140000/3132757/p51-gilad.pdf?ip=203.206.230.39&id=3132757&acc=OA&key=4D4702B0C3E38B35%2E4D4702B0C3E38B35%2E4D4702B0C3E38B35%2EFD1C447234F14652&__acm__=1556073074_d3cb67ff2ad176041c2fe61d68a1b809)
 * [HMW; Timo Hanke, Mahnush Movahedi, and Dominic Williams.  Dfinity technology overview series consensus  system.    Whitepaper](https://dfinity.org/pdf-viewer/pdfs/viewer?file=../library/dfinity-consensus.pdf)
 * [BHM18; Leemon Baird, Mance Harmon, and Paul Madsen. Hedera: A governing council & public hashgraph network.   Whitepaper,  May  2018.](https://s3.amazonaws.com/hedera-hashgraph/hh-whitepaper-v1.1-180518.pdf)
 * [DGKR18; Bernardo  David,  Peter  Gazi,  Aggelos  Kiayias,  and  Alexander  Russell.    Ouroboros  praos:   Anadaptively-secure,  semi-synchronous  proof-of-stake blockchain.  InAdvances  in  Cryptology  -  EU-ROCRYPT 2018 - 37th Annual International Conference on the Theory and Applications of Cryp-tographic  Techniques,  Tel  Aviv,  Israel,  April  29  -  May  3,  2018  Proceedings,  Part  II, pages 66–98,2018.](https://cryptorating.eu/whitepapers/Cardano/573.pdf)
 * [ZW18; Zane Witherspoon, A Hitchhiker’s Guide to Consensus Algorithms](https://hackernoon.com/a-hitchhikers-guide-to-consensus-algorithms-d81aae3eb0e3)
 * [ETHWP8; Ethereum Problems, 8. Proof-of-Stake](https://github.com/ethereum/wiki/wiki/Problems#8-proof-of-stake)
 * [RAIBLK; Colin LeMahieu, RaiBlocks: A Feeless Distributed Cryptocurrency Network](https://www.raiblocks.net/media/RaiBlocks_Whitepaper__English.pdf)
 * [IOTA; Serguei Popov, The Tangle, April 30, 2018. Version 1.4.3](https://iota.org/IOTA_Whitepaper.pdf)