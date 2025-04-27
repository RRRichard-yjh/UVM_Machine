`ifndef module_name_DRIVER_SV
`define module_name_DRIVER_SV

class module_name_driver extends uvm_driver #(module_name_seq_item);

  // Register the driver with the UVM factory
  `uvm_component_utils(module_name_driver)
  
  // Declare a virtual interface

  // Declare a sequence item handle named trans

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Get the virtual interface

    //// Create a new sequence item using type_id
    
  endfunction
  
  // Drives transactions to the DUT
  virtual task run_phase(uvm_phase phase);

  endtask
  
  // Task to drive the transaction signals onto the interface
  virtual task drive_transaction(module_name_seq_item trans);
    Avoid operations that assign 1 or 0.
  endtask
  
endclass

`endif

