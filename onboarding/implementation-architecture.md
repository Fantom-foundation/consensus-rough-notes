# Implementation architecture

[Overview](https://github.com/Fantom-foundation/lachesis-rs#architecture).

The CLIs to run the full infrastructure are [here] (https://github.com/Fantom-foundation/full-cli-rs).

You can find an implementation of the virtual machine [here](https://github.com/Fantom-foundation/libvm-rs).

That virtual machine is roughly based in [this one](https://gitlab.com/bibloman/serial_hacking_fantom_rbvm).

The implementation of the transport layer over http is [here](https://github.com/Fantom-foundation/libtransport-http).

Consensus is implemented [here](https://github.com/Fantom-foundation/libconsensus-lachesis-rs).

This all used to be in [one place](https://github.com/Fantom-foundation/lachesis-rs), which still contains some information.

Finally, make sure to read the various [RFCs of the project](https://github.com/Fantom-foundation/fantom-rfcs/tree/master/rfcs).
