`include "uvm_macros.svh"

class ALU_driver extends uvm_driver #(ALU_seq_item);

  // Register the driver with the UVM factory
  `uvm_component_utils(ALU_driver)

  // Virtual interface to communicate with the DUT
  virtual ALU_if vif;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Get the virtual interface from the configuration database
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ALU_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NO_VIF", "Virtual interface not found for ALU_driver")
    end
  endfunction

  // Run phase: Drive signals to the DUT
  virtual task run_phase(uvm_phase phase);
    forever begin
      // Wait for the clock edge before fetching the next item
      @(posedge vif.clk);

      // Get the next sequence item from the sequencer
      seq_item_port.get_next_item(req);

      // Drive the inputs to the DUT using non-blocking assignments
      drive_transfer(req);

      // Indicate that the current sequence item is complete
      seq_item_port.item_done();
    end
  endtask

  // Task to drive the inputs to the DUT
  virtual task drive_transfer(ALU_seq_item req);
    // Use non-blocking assignments to simulate hardware behavior
    vif.a_operand <= req.a_operand;
    vif.b_operand <= req.b_operand;
    vif.Operation <= req.Operation;

    // Wait for a small delay to simulate hardware propagation
    #1;
  endtask

endclass