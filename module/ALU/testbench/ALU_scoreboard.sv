
`include "uvm_macros.svh"
import uvm_pkg::*;

class ALU_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(ALU_scoreboard)

   // Analysis FIFO to receive actual DUT transactions from the monitor
   uvm_tlm_analysis_fifo #(ALU_seq_item) scb_act_fifo;

   // Reference model instance
   ALU_RefModel ref_model;

   // Statistical counters
   int match_count = 0;
   int mismatch_count = 0;
   int total_checked = 0;

   real Pass_rate = 0.0;

   // Constructor
   function new (string name="ALU_scoreboard", uvm_component parent =null);
      super.new(name,parent);
   endfunction

   // Build phase: Initialize components
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      scb_act_fifo = new("scb_act_fifo", this);
      ref_model = new();
   endfunction

   // Run phase: Compare actual DUT outputs with reference model outputs
   task run_phase(uvm_phase phase);
      ALU_seq_item act_item;
      ALU_seq_item exp_item = new();

      forever begin
         // Get actual DUT transaction from the FIFO
         scb_act_fifo.get(act_item);

         // Generate expected output using the reference model
         ref_model.Operate(
            act_item.a_operand,
            act_item.b_operand,
            act_item.Operation,
            exp_item.ALU_Output,
            exp_item.Exception,
            exp_item.Overflow,
            exp_item.Underflow
         );

         // Compare actual and expected outputs
         compare_outputs(act_item, exp_item);
      end
   endtask

   // Function to compare actual and expected outputs
   function void compare_outputs(ALU_seq_item act_item, ALU_seq_item exp_item);
      total_checked++;

      // Check if actual output is in X state
      if (act_item.ALU_Output === 32'bx || act_item.Exception === 1'bx || 
          act_item.Overflow === 1'bx || act_item.Underflow === 1'bx) begin
         return;
      end

      // Compare each output field
      if (act_item.ALU_Output !== exp_item.ALU_Output) begin
         `uvm_error("SCB", $sformatf("ALU_Output mismatch! Actual: %h, Expected: %h", 
                                     act_item.ALU_Output, exp_item.ALU_Output))
         mismatch_count++;
      end else if (act_item.Exception !== exp_item.Exception) begin
         `uvm_error("SCB", $sformatf("Exception mismatch! Actual: %b, Expected: %b", 
                                     act_item.Exception, exp_item.Exception))
         mismatch_count++;
      end else if (act_item.Overflow !== exp_item.Overflow) begin
         `uvm_error("SCB", $sformatf("Overflow mismatch! Actual: %b, Expected: %b", 
                                     act_item.Overflow, exp_item.Overflow))
         mismatch_count++;
      end else if (act_item.Underflow !== exp_item.Underflow) begin
         `uvm_error("SCB", $sformatf("Underflow mismatch! Actual: %b, Expected: %b", 
                                     act_item.Underflow, exp_item.Underflow))
         mismatch_count++;
      end else begin
         `uvm_info("SCB", "Outputs match", UVM_MEDIUM)
         match_count++;
      end
   endfunction

   // Report phase: Display statistical summary
   function void report_phase(uvm_phase phase);
      total_checked = mismatch_count + match_count;
      if (total_checked > 0) begin
         Pass_rate = match_count / real'(total_checked) * 100.0;
      end

      `uvm_info("SCB", "----------------------------------------", UVM_NONE)
      `uvm_info("SCB", "SCOREBOARD SUMMARY", UVM_NONE)
      `uvm_info("SCB", $sformatf("Total checked:  %0d", total_checked), UVM_NONE)
      `uvm_info("SCB", $sformatf("Matches:        %0d", match_count), UVM_NONE)
      `uvm_info("SCB", $sformatf("Mismatches:     %0d", mismatch_count), UVM_NONE)
      `uvm_info("SCB", $sformatf("Pass_rate:     %.2f%%", Pass_rate), UVM_NONE)

      if (mismatch_count > 0) begin
         $write("%c[7;31m", 27);
         $display("TEST FAILED");
         $write("%c[0m", 27);
      end else begin
         $write("%c[7;32m", 27);
         $display("TEST PASSED");
         $write("%c[0m", 27);
      end
   endfunction

endclass: ALU_scoreboard
