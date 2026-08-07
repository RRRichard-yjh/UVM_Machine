`include "uvm_macros.svh"

class AES_Encrypt_driver extends uvm_driver #(AES_Encrypt_seq_item);

  // Register the driver with the UVM factory
  `uvm_component_utils(AES_Encrypt_driver)

  // Virtual interface to communicate with the DUT
  virtual AES_Encrypt_if vif;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Get the virtual interface from the configuration database
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual AES_Encrypt_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found for AES_Encrypt_driver")
    end
  endfunction

  // Run phase: Drive the inputs to the DUT
  virtual task run_phase(uvm_phase phase);
    forever begin
      // Wait for the clock edge before getting the next item
      @(posedge vif.clk);

      // Get the next sequence item
      seq_item_port.get_next_item(req);

      // Drive the inputs to the DUT using non-blocking assignments
      vif.in  <= req.in;
      vif.key <= req.key;

      // Signal that the item has been processed
      seq_item_port.item_done();
    end
  endtask

endclass