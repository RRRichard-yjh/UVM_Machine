

interface AES_Encrypt_if();

//input/output signals
    logic [127:0] in;
    logic [127:0] key;
    logic [127:0] out;
    logic  clk;


    modport DUT (
    input in, key, clk,
    output out
    );//design modport
    
endinterface //AES_Encrypt design interface
