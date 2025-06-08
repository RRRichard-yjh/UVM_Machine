
module ALU_Top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Interface instantiation
    ALU_if ifc();
    
    // DUT instantiation
    ALU  dut (
        .a_operand(ifc.a_operand),
        .b_operand(ifc.b_operand),
        .Operation(ifc.Operation),
        .ALU_Output(ifc.ALU_Output),
        .Exception(ifc.Exception),
        .Overflow(ifc.Overflow),
        .Underflow(ifc.Underflow)
    );

    // Clock and reset generation
    
    initial begin
        ifc.clk = 0;
        forever #5 ifc.clk = ~ifc.clk; // 100MHz clock
    end
    
    // No reset signal detected

    // UVM configuration
    initial begin
        uvm_config_db#(virtual ALU_if)::set(null, "uvm_test_top", "vif", ifc);
        run_test("ALU_test");  
    end

    // Waveform recording
    initial begin
        $fsdbDumpfile("sim.fsdb");
        $fsdbDumpvars();
    end

endmodule
    
