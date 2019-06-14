Offscale is engaged in development of a [Consensus algorithm](https://en.wikipedia.org/wiki/Consensus_%28computer_science%29) based on Directed
Acyclic Graph (DAG).

It has started from analysis of the implementation of Fantom Foundation's Lachesis protocol, which came into life with 3 papers:

1. [OPERA: REASONING ABOUT CONTINUOUS COMMON KNOWLEDGE IN ASYNCHRONOUS DISTRIBUTED SYSTEMS](papers/OPERA-Reasoning-about-continuous-common-knowledge-in-asynchronous-distributed-systems.pdf); [on arxiv.org](https://arxiv.org/abs/1810.02186);

2. [FANTOM : A SCALABLE FRAMEWORK FOR ASYNCHRONOUS DISTRIBUTED SYSTEMS](papers/Fantom__A_scalable_framework_for_asynchronous_distributed_systems.pdf); also available on [Fantom's github](https://github.com/Fantom-foundation/fantom-framework); [on arxiv.org](https://arxiv.org/abs/1810.10360);

3. [ONLAY: ONLINE LAYERING FOR SCALABLE ASYNCHRONOUS BFT SYSTEM](papers/Fantom-Layer_v12.pdf); [on arxiv.org](https://arxiv.org/abs/1905.04867).

Offscale believes Fantom's Lachesis has several flaws in the design preventin it to work on resonable high number of nodes (15+). Our nearest goal would be in constructing a TLA+ model of Lachesis and desproving its correctnes using it.

See [Asynchronous Consensus: A Model in TLA+](papers/Asynchronous-Consensus-A-model-in-TLA+-Tarzia_499_paper.pdf) paper as a model for Lachesis analysis need to be done.

See more on Consensus and various types of it in [Consensus.md](Consensus.md).

