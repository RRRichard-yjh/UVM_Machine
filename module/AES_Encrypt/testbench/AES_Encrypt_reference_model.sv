`ifndef AES_Encrypt_REF_MODEL_SV
`define AES_Encrypt_REF_MODEL_SV

// Import DPI function - Make sure this matches your C function name
import "DPI-C" function void AES_encrypt(
    input byte plaintext[16],
    input byte cipherkey[16],
    output byte ciphertext[16]
);

class AES_Encrypt_ref_model extends uvm_component;
    `uvm_component_utils(AES_Encrypt_ref_model)
     
    // Analysis ports
    uvm_analysis_imp #(AES_Encrypt_seq_item, AES_Encrypt_ref_model) input_imp;
    uvm_analysis_port #(AES_Encrypt_seq_item) output_ap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        input_imp = new("input_imp", this);
        output_ap = new("output_ap", this);
    endfunction
    
    function void write(AES_Encrypt_seq_item seq_item);
        byte plain_text[16];
        byte cipher_key[16];
        byte expected_cipher_text_byte[16];
        bit [127:0] expected_cipher_text;
        AES_Encrypt_seq_item out_tr = new();


        // Convert to byte array (with optional byte swapping)
        for (int i = 0; i < 16; i++) begin
               plain_text[i] = seq_item.in[(15-i)*8 +: 8];
               cipher_key[i] = seq_item.key[(15-i)*8 +: 8];
        end
        
        // Call C model through DPI
        AES_encrypt(plain_text, cipher_key, expected_cipher_text_byte);

        // Convert back to 128-bit vector
        for (int i = 0; i < 16; i++) begin
            expected_cipher_text[(15-i)*8 +: 8] = expected_cipher_text_byte[i];
        end

        // Prepare output transaction
        out_tr.in = seq_item.in;  // Optional: forward input for reference
        out_tr.key = seq_item.key; // Optional: forward key for reference
        out_tr.out = expected_cipher_text;
        
        // Send output transaction
        output_ap.write(out_tr);
        
    endfunction
endclass

`endif // AES_Encrypt_REF_MODEL_SV
