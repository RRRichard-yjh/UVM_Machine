
module AES_Encrypt_Top();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Interface instantiation
    AES_Encrypt_if ifc();
    
    // DUT instantiation
    AES_Encrypt #(128,10,4) dut (
        .in(ifc.in),
        .key(ifc.key),
        .out(ifc.out)
    );

    // Clock and reset generation
    
    initial begin
        ifc.clk = 0;
        forever #5 ifc.clk = ~ifc.clk; // 100MHz clock
    end
    
    // No reset signal detected

    // UVM configuration
    initial begin
        uvm_config_db#(virtual AES_Encrypt_if)::set(null, "uvm_test_top", "vif", ifc);
        run_test("AES_Encrypt_test");
    end

    // Waveform recording
    initial begin
        $fsdbDumpfile("sim.fsdb");
        $fsdbDumpvars();
    end

endmodule
    
