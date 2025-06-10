
class ALU_subscriber extends uvm_subscriber #(ALU_seq_item);
    `uvm_component_utils(ALU_subscriber)

    ALU_seq_item item;
    uvm_analysis_imp #(ALU_seq_item, ALU_subscriber) sub_imp;

    typedef enum bit [3:0] {
        CMD_ADD = 4'd10,
        CMD_SUB = 4'd3,
        CMD_MUL = 4'd1,
        CMD_DIV = 4'd2,
        CMD_OR = 4'd4,
        CMD_AND = 4'd5,
        CMD_XOR = 4'd6,
        CMD_LS = 4'd7,
        CMD_RS = 4'd8,
        CMD_FLOAT_TO_INT = 4'd9,
        CMD_COMPLEMENT = 4'd11
    } cmd_type_e;

    covergroup cg;
        command : coverpoint item.Operation {
            bins add = {CMD_ADD};
            bins sub = {CMD_SUB};
            bins mul = {CMD_MUL};
            bins div = {CMD_DIV};
            bins or_bin = {CMD_OR};
            bins and_bin = {CMD_AND};
            bins xor_bin = {CMD_XOR};
            bins ls = {CMD_LS};
            bins rs = {CMD_RS};
            bins float_to_int = {CMD_FLOAT_TO_INT};
            bins complement = {CMD_COMPLEMENT};
        }

		a_cg: coverpoint item.a_operand {
            bins allzeros = {32'h00000000};
            bins allones = {32'hFFFFFFFF};
            bins b1 = {[0:32'hFFFFFFFF]};
        }
        b_cg: coverpoint item.b_operand {
            bins allzeros = {32'h00000000};
            bins allones = {32'hFFFFFFFF};
            bins b1 = {[0:32'hFFFFFFFF]};
        }
    endgroup

    function new(string name = "ALU_subscriber", uvm_component parent = null);
        super.new(name, parent);
        cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sub_imp = new("sub_imp", this);
    endfunction

    virtual function void write(ALU_seq_item t);
        item = t;
        cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("ALU_subscriber", $sformatf("Coverage = %0d%%", cg.get_coverage()), UVM_NONE);
    endfunction
endclass : ALU_subscriber
