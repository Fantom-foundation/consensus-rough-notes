```
// Each of fill-cli and light-cli executes the following
// code schema:

CLI_config = CLI.load_configuration(file_with_configuration)
switch(CLIconfig.vm_type) {
	case VM0:
		VM0_config = VM0_CONFIG::new(CLI_config);
		vm = VM0::new(VM0_config);
	case VM1:
		VM1_config = VM1_CONFIG::new(CLI_config);
		vm = VM1::new(VM1_config);
	...
	case VMn:
		VMn_config = VMn_CONFIG::new(CLI_config);
		vm = VMn::new(VMn_config);
	default: error("unknown VM")
}
vm.run();


// Each vm implementation should configure and start Consensus
// using the following schema:

VMx::new(vm_config: VMx_CONFIG) {
	// create object vm according vm_config
	switch(vm_config.consensus_type) {
		case DAG:
			dag_config = DAGconfig::new(vm_config);
			consensus = DAG<VM_DATA_TYPE_OF_CONSENSUS_ON>::new(dag_config);
		case RAFT:
			raft_config = RAFTconfig::new(vm_config);
			consensus = RAFT<VM_DATA_TYPE_OF_CONSENSUS_ON>::new(raft_config);
		default: error("unknown Consensus")
	}
	vm.consensus = consensus;
	(rx, tx) = create_channel::<VM_DATA_TYPE_OF_CONSENSUS_ON>();
	vm.set_listen_channel_for_incoming_transactions(rx);
	consensus.register_channel(tx);
	// or it can register callback function for incomming transaction:
	// consensus.register_callback(vm.fn_process_incomming_transaction);
	consensus.run();
}

// Each consensus implamantation should configure and start Transport
// using the following schema:

CONSENSUS<D>::new(config: CONSENSUS_CONFIG) {
	// create object consensus according config
	// Note: COND below is the data type transmitted between instances of the same consensus
	//       PL below is PeerList type
	switch (config.transport_type) {
		case TCP:
			transport_cfg = TCPTransportConfiguration::<COND>::new(config);
		default: error("Unknown transport type");
	}
	(rx, tx) = create_channel::<COND>();
	consensus.set_listen_channel_for_incoming_data(rx);
	transport_cfg.register_channel(tx);
	// or it can register callback function for incomming data:
	// transport_cfg.register_callback(consnensus.fn_process_incomming_data);
	switch (config.transport_type) {
		case TCP:
			transport = TCPTransport::<Id,COND,Error,PL>::new(transport_cfg);
		default: error("Unknown transport type");
	}
	consensus.transport = transport;
	transport.run();
}
```

The same idea should be applied to other layers, i.e. each layer only configure and set up running
a layer next below it whose services would be used.
