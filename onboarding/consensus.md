Offscale is engaged in development of a [Consensus algorithm](https://en.wikipedia.org/wiki/Consensus_%28computer_science%29) based on Directed
Acyclic Graph (DAG).

It has started from analysis of the implementation of Fantom Foundation's Lachesis protocol, which came into life with 3 papers:

1. [OPERA: REASONING ABOUT CONTINUOUS COMMON KNOWLEDGE IN ASYNCHRONOUS DISTRIBUTED SYSTEMS](../papers/OPERA-Reasoning-about-continuous-common-knowledge-in-asynchronous-distributed-systems.pdf); [on arxiv.org](https://arxiv.org/abs/1810.02186);

2. [FANTOM : A SCALABLE FRAMEWORK FOR ASYNCHRONOUS DISTRIBUTED SYSTEMS](../papers/Fantom__A_scalable_framework_for_asynchronous_distributed_systems.pdf); also available on [Fantom's github](https://github.com/Fantom-foundation/fantom-framework); [on arxiv.org](https://arxiv.org/abs/1810.10360);

3. [ONLAY: ONLINE LAYERING FOR SCALABLE ASYNCHRONOUS BFT SYSTEM](../papers/Fantom-Layer_v12.pdf); [on arxiv.org](https://arxiv.org/abs/1905.04867).

Offscale believes Fantom's Lachesis has several flaws in its design, thus preventing it from working on a reasonably high number of nodes (15+). Our nearest goal would be in constructing a TLA+ model of Lachesis to disprove its correctnes.

See [Asynchronous Consensus: A Model in TLA+](../papers/Asynchronous-Consensus-A-model-in-TLA+-Tarzia_499_paper.pdf) paper as a model for Lachesis analysis that needs to be done.

---

There also a related [Coq proof](https://www.hedera.com/hashgraph-coq.zip) of
Hashgraph being Byzantine fault tolerant. See also the [blog
post](https://www.hedera.com/blog/coq-proof-completed-by-carnegie-mellon-professor-confirms-hashgraph-consensus-algorithm-is-asynchronous-byzantine-fault-tolerant).

More advanced Coq proof automation for proofs of distributed protocols was
introduced in a [POPL paper](https://homes.cs.washington.edu/~ztatlock/pubs/diesel-sergey-popl18.pdf).
These techniques have been applied to building a formal model of a toy blockchain
consensus and proving its eventual consistency around the same time in a [CPP 
paper](https://ilyasergey.net/papers/toychain-cpp18.pdf), with proofs available
on [GitHub](https://github.com/certichain/toychain).

See more on Consensus and various types of it in [Consensus.md](../Consensus.md).
