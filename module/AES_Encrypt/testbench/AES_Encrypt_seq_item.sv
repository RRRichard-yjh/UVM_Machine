
import uvm_pkg::*;
`include "uvm_macros.svh"

class AES_Encrypt_seq_item extends uvm_sequence_item;

    // Input signals
    rand logic [127:0] in;  // Plaintext input
    rand logic [127:0] key; // Encryption key

    // Output signals
    logic [127:0] out;      // Ciphertext output

    // Clock signal
    bit clk;                // Clock signal (not randomized)

    // Register the seq_item class with UVM
    `uvm_object_utils_begin(AES_Encrypt_seq_item)
        `uvm_field_int(in, UVM_ALL_ON)
        `uvm_field_int(key, UVM_ALL_ON)
        `uvm_field_int(out, UVM_ALL_ON)
        `uvm_field_int(clk, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "AES_Encrypt_seq_item");
        super.new(name);
    endfunction

    // Constraints to ensure valid inputs
    constraint valid_in {
        // Ensure plaintext is within valid range (no specific range for AES, but can be customized)
        in inside {[0:128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF]};
    }

    constraint valid_key {
        // Ensure key is within valid range (no specific range for AES, but can be customized)
        key inside {[0:128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF]};
    }

    // Additional constraints can be added here based on specific requirements

endclass
