
class ALU_sequencer extends uvm_sequencer #(ALU_seq_item);
    `uvm_component_utils(ALU_sequencer)

    function new(string name = "ALU_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass
