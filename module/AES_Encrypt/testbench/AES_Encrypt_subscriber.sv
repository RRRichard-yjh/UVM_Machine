/*######################################################################*\
## Class Name: AES_Encrypt_subscriber   
## Author : Omnia Mohamed
## Date: jun 2024
## 
\*######################################################################*/
class AES_Encrypt_subscriber extends uvm_subscriber#(AES_Encrypt_seq_item);
`uvm_component_utils(AES_Encrypt_subscriber)
    AES_Encrypt_seq_item item;
    uvm_analysis_imp#(AES_Encrypt_seq_item,AES_Encrypt_subscriber) sub_imp;

    covergroup cg;
        in:coverpoint item.in{
            bins allzeros={128'h00000000000000000000000000000000};
            bins allones={128'hffffffffffffffffffffffffffffffff};
            bins b1={[0:32'hffffffff]};
            bins b2={[32'hffffffff:64'hffffffffffffffff]};
            bins b3={[64'hffffffffffffffff:96'hffffffffffffffffffffffff]};
            bins b4={[96'hffffffffffffffffffffffff:128'hffffffffffffffffffffffffffffffff]};
        }
        key:coverpoint item.key{
            bins allzeros={128'h00000000000000000000000000000000};
            bins allones={128'hffffffffffffffffffffffffffffffff};
            bins b1={[0:32'hffffffff]};
            bins b2={[32'hffffffff:64'hffffffffffffffff]};
            bins b3={[64'hffffffffffffffff:96'hffffffffffffffffffffffff]};
            bins b4={[96'hffffffffffffffffffffffff:128'hffffffffffffffffffffffffffffffff]};
        }
        
        out:coverpoint item.out;
        cross in,key;
    endgroup
    function new (string name="AES_Encrypt_subscriber", uvm_component parent =null);
        super.new(name,parent);
        cg=new();
    endfunction
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sub_imp=new("sub_imp",this);
    endfunction
    virtual function void write(AES_Encrypt_seq_item t);
        item=t;
        cg.sample();
    endfunction
    function void report_phase (uvm_phase phase);
        `uvm_info("AES_Encrypt_subscriber", $sformatf("coverage =%0d", cg.get_coverage), UVM_NONE);
    endfunction
endclass:AES_Encrypt_subscriber
