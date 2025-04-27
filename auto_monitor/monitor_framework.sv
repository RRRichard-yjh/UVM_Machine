`ifndef module_name_MONITOR_SV
`define module_name_MONITOR_SV

class module_name_monitor extends uvm_monitor;

  `uvm_component_utils(module_name_monitor)
  // Declare a virtual interface

  // Declare analysis port named ap
  
  // Declare events

  // Declare sequence item to store monitored data

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Get the virtual interface
    
    // Create a new sequence item using type_id

    // Get global events
    
  endfunction

  // Run phase to monitor the signals
  virtual task run_phase(uvm_phase phase);

  endtask

endclass

`endif
