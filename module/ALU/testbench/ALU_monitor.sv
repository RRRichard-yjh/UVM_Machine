`include "uvm_macros.svh"
import uvm_pkg::*;

class ALU_monitor extends uvm_monitor;

  `uvm_component_utils(ALU_monitor)

  virtual ALU_if vif;
  uvm_analysis_port#(ALU_seq_item) ap;
  ALU_seq_item trans;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ALU_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found for ALU monitor")
    end
    trans = ALU_seq_item::type_id::create("trans");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      collect_data();
    end
  endtask

  virtual task collect_data();
    trans.a_operand <= vif.a_operand;
    trans.b_operand <= vif.b_operand;
    trans.Operation <= vif.Operation;
    trans.ALU_Output <= vif.ALU_Output;
    trans.Exception <= vif.Exception;
    trans.Overflow <= vif.Overflow;
    trans.Underflow <= vif.Underflow;
    trans.clk <= vif.clk;
    ap.write(trans);
  endtask

endclass