
class AES_Encrypt_sequencer extends uvm_sequencer #(AES_Encrypt_seq_item);
    `uvm_component_utils(AES_Encrypt_sequencer)

    function new(string name = "AES_Encrypt_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass
