
`include "uvm_macros.svh"
import uvm_pkg::*;

class AES_Encrypt_agent extends uvm_agent;

  // Register the agent with the UVM factory
  `uvm_component_utils(AES_Encrypt_agent)

  // Declare the components
  AES_Encrypt_sequencer sqr;
  AES_Encrypt_driver drv;
  AES_Encrypt_monitor mon;

  // Declare the virtual interface
  virtual AES_Encrypt_if vif;

  // Declare the analysis port for the monitor
  uvm_analysis_port#(AES_Encrypt_seq_item) agent_ap;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Create and configure sub-components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Instantiate the analysis port
    agent_ap = new("agent_ap", this);

    // Retrieve the virtual interface from the configuration database
    if (!uvm_config_db#(virtual AES_Encrypt_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found for AES_Encrypt_agent")
    end

    // Create the sequencer, driver, and monitor
    sqr = AES_Encrypt_sequencer::type_id::create("sqr", this);
    drv = AES_Encrypt_driver::type_id::create("drv", this);
    mon = AES_Encrypt_monitor::type_id::create("mon", this);

    // Pass the virtual interface to the driver and monitor
    uvm_config_db#(virtual AES_Encrypt_if)::set(this, "drv", "vif", vif);
    uvm_config_db#(virtual AES_Encrypt_if)::set(this, "mon", "vif", vif);
  endfunction

  // Connect phase: Connect the component interfaces
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the driver's seq_item_port to the sequencer's seq_item_export
    drv.seq_item_port.connect(sqr.seq_item_export);

    // Connect the monitor's analysis port to the agent's analysis port
    mon.ap.connect(agent_ap);
  endfunction

endclass
