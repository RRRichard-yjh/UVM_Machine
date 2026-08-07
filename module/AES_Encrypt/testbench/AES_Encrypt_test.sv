
//------------------------------------------------------------------------------
// Title: AES_Encrypt_test
// Description: UVM test for This is a description of AES_Encrypt_test.
//------------------------------------------------------------------------------

`include "uvm_macros.svh"

class AES_Encrypt_test extends uvm_test;
  `uvm_component_utils(AES_Encrypt_test)
  
  //Member variable declaration

  AES_Encrypt_env env;
  AES_Encrypt_base_sequence base_seq;
  AES_Encrypt_random_sequence seq1;
  AES_Encrypt_directed_sequence seq2;
  AES_Encrypt_add_func_seq seq3;

  virtual AES_Encrypt_if vif;


  function new(string name = "AES_Encrypt_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Add build phase code here
	
	if(!uvm_config_db#(virtual AES_Encrypt_if)::get(this,"","vif",vif))
        `uvm_error("AES_Encrypt_test","Can't get vif from the config db")
    uvm_config_db#(virtual AES_Encrypt_if)::set(this,"env","vif",vif);

 
	env = AES_Encrypt_env::type_id::create("env", this);
    base_seq=AES_Encrypt_base_sequence::type_id::create("base_seq");
    seq1=AES_Encrypt_random_sequence::type_id::create("seq1");
    seq2=AES_Encrypt_directed_sequence::type_id::create("seq2");
    seq3=AES_Encrypt_add_func_seq::type_id::create("seq3");

  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    
	// Add run phase code here
	base_seq.start(env.agent.sqr);
    #200;
    seq1.start(env.agent.sqr);
    #200;
    seq2.start(env.agent.sqr);
    #200;
    seq3.start(env.agent.sqr);
    #200;

    phase.drop_objection(this);
  endtask

endclass
