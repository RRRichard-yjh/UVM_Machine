`include "uvm_macros.svh"
import uvm_pkg::*;

class AES_Encrypt_monitor extends uvm_monitor;

  `uvm_component_utils(AES_Encrypt_monitor)

  virtual AES_Encrypt_if vif;
  uvm_analysis_port#(AES_Encrypt_seq_item) ap;
  AES_Encrypt_seq_item trans;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual AES_Encrypt_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found")
    end
    trans = AES_Encrypt_seq_item::type_id::create("trans");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      trans.in <= vif.in;
      trans.key <= vif.key;
      trans.out <= vif.out;
      trans.clk <= vif.clk;
      ap.write(trans);
    end
  endtask

endclass