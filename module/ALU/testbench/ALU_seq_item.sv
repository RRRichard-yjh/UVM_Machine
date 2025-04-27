
import uvm_pkg::*;
`include "uvm_macros.svh"

class ALU_seq_item extends uvm_sequence_item;

    // Input signals (rand)
    rand logic [31:0] a_operand;
    rand logic [31:0] b_operand;
    rand logic [3:0]  Operation;

    // Output signals (non-rand)
    logic [31:0] ALU_Output;
    logic        Exception;
    logic        Overflow;
    logic        Underflow;

    // Clock signal (non-rand)
    bit clk;

    // Register the seq_item class with UVM
    `uvm_object_utils_begin(ALU_seq_item)
        `uvm_field_int(a_operand, UVM_ALL_ON)
        `uvm_field_int(b_operand, UVM_ALL_ON)
        `uvm_field_int(Operation, UVM_ALL_ON)
        `uvm_field_int(ALU_Output, UVM_ALL_ON)
        `uvm_field_int(Exception, UVM_ALL_ON)
        `uvm_field_int(Overflow, UVM_ALL_ON)
        `uvm_field_int(Underflow, UVM_ALL_ON)
        `uvm_field_int(clk, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "ALU_seq_item");
        super.new(name);
    endfunction

     
  // Ensure Operation is within the valid range
    constraint valid_Operation {
        Operation inside {[4'd1:4'd11]};
    }


	constraint add_sub {
        (Operation == 4'd10  || Operation == 4'd3) -> a_operand[31] == 0;
    }



endclass
