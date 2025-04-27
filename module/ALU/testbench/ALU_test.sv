
//------------------------------------------------------------------------------
// Title: ALU_test
// Description: UVM test for This is a description of ALU_test.
//------------------------------------------------------------------------------

`include "uvm_macros.svh"

class ALU_test extends uvm_test;
  `uvm_component_utils(ALU_test)
  
  //Member variable declaration

  ALU_env env;
  ALU_base_sequence base_seq;
  ALU_random_sequence seq1;
  ALU_directed_sequence seq2;
  ALU_line_coverage_seq seq3;
  ALU_add_branch_code_seq seq4;
  ALU_toggle_sequence seq5;
  ALU_add_cond_code_seq seq6;
  ALU_add_func_seq seq7;
  ALU_line_coverage_seq_1 seq8;

  virtual ALU_if vif;


  function new(string name = "ALU_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Add build phase code here
	
	if(!uvm_config_db#(virtual ALU_if)::get(this,"","vif",vif))
        `uvm_error("ALU_test","Can't get vif from the config db")
    uvm_config_db#(virtual ALU_if)::set(this,"env","vif",vif);

 
	env = ALU_env::type_id::create("env", this);
    base_seq=ALU_base_sequence::type_id::create("base_seq");
    seq1=ALU_random_sequence::type_id::create("seq1");
    seq2=ALU_directed_sequence::type_id::create("seq2");
    seq3=ALU_line_coverage_seq::type_id::create("seq3");
    seq4=ALU_add_branch_code_seq::type_id::create("seq4");
    seq5=ALU_toggle_sequence::type_id::create("seq5");
    seq6=ALU_add_cond_code_seq::type_id::create("seq6");
    seq7=ALU_add_func_seq::type_id::create("seq7");
    seq8=ALU_line_coverage_seq_1::type_id::create("seq8");

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
    seq4.start(env.agent.sqr);
    #200;
    seq5.start(env.agent.sqr);
    #200;
    seq6.start(env.agent.sqr);
    #200;
    seq7.start(env.agent.sqr);
    #200;
    seq8.start(env.agent.sqr);
    #200;

    phase.drop_objection(this);
  endtask

endclass
