
`include "uvm_macros.svh"
import uvm_pkg::*;

class AES_Encrypt_env extends uvm_env;

  // Register the environment with the UVM factory
  `uvm_component_utils(AES_Encrypt_env)

  // Declare the components
  AES_Encrypt_agent agent;
  AES_Encrypt_scoreboard scb;
  AES_Encrypt_subscriber cov;
  AES_Encrypt_ref_model ref_model;

  // Declare the virtual interface
  virtual AES_Encrypt_if vif;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Create and configure sub-components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the virtual interface from the configuration database
    if (!uvm_config_db#(virtual AES_Encrypt_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found for AES_Encrypt_env")
    end

    // Create the agent, scoreboard, subscriber, and reference model
    agent = AES_Encrypt_agent::type_id::create("agent", this);
    scb = AES_Encrypt_scoreboard::type_id::create("scb", this);
    cov = AES_Encrypt_subscriber::type_id::create("cov", this);
    ref_model = AES_Encrypt_ref_model::type_id::create("ref_model", this);

    // Pass the virtual interface to the agent
    uvm_config_db#(virtual AES_Encrypt_if)::set(this, "agent", "vif", vif);
  endfunction

  // Connect phase: Connect the component interfaces
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the agent's analysis port to the reference model's input port
    agent.agent_ap.connect(ref_model.input_imp);

    // Connect the reference model's output port to the scoreboard's expected port
    ref_model.output_ap.connect(scb.expected_imp);

    // Connect the agent's analysis port to the scoreboard's actual port
    agent.agent_ap.connect(scb.actual_imp);

    // Connect the agent's analysis port to the subscriber's input port
    agent.agent_ap.connect(cov.sub_imp);
  endfunction

endclass
