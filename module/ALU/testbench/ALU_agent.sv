
`include "uvm_macros.svh"
import uvm_pkg::*;

class ALU_agent extends uvm_agent;

  // Register the agent with the UVM factory
  `uvm_component_utils(ALU_agent)

  // Declare the components
  ALU_sequencer sqr;
  ALU_driver drv;
  ALU_monitor mon;

  // Declare the virtual interface
  virtual ALU_if vif;

  // Declare the analysis port for the monitor to broadcast data
  uvm_analysis_port#(ALU_seq_item) agent_ap;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    // Instantiate the analysis port
    agent_ap = new("agent_ap", this);
  endfunction

  // Build phase: Create sub-components and configure the interface
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve the virtual interface from the configuration database
    if (!uvm_config_db#(virtual ALU_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NO_VIF", "Virtual interface not found for ALU_agent")
    end

    // Pass the virtual interface to the driver and monitor
    uvm_config_db#(virtual ALU_if)::set(this, "drv", "vif", vif);
    uvm_config_db#(virtual ALU_if)::set(this, "mon", "vif", vif);

    // Instantiate the sequencer, driver, and monitor
    sqr = ALU_sequencer::type_id::create("sqr", this);
    drv = ALU_driver::type_id::create("drv", this);
    mon = ALU_monitor::type_id::create("mon", this);
  endfunction

  // Connect phase: Connect the component interfaces
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect the driver and sequencer
    drv.seq_item_port.connect(sqr.seq_item_export);

    // Connect the monitor's analysis port to the agent's analysis port
    mon.ap.connect(agent_ap);
  endfunction

endclass
