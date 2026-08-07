
class AES_Encrypt_base_sequence extends uvm_sequence #(AES_Encrypt_seq_item);

    `uvm_object_utils(AES_Encrypt_base_sequence)

    function new(string name = "AES_Encrypt_base_sequence");
        super.new(name);
    endfunction

    virtual task body();
        AES_Encrypt_seq_item seq_item;
        seq_item = AES_Encrypt_seq_item::type_id::create("seq_item");

        start_item(seq_item);
        if (!seq_item.randomize()) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);
    endtask

endclass

class AES_Encrypt_random_sequence extends AES_Encrypt_base_sequence;

    `uvm_object_utils(AES_Encrypt_random_sequence)

    function new(string name = "AES_Encrypt_random_sequence");
        super.new(name);
    endfunction

    virtual task body();
        AES_Encrypt_seq_item seq_item;
        seq_item = AES_Encrypt_seq_item::type_id::create("seq_item");

        repeat (2500) begin
            start_item(seq_item);
            if (!seq_item.randomize()) begin
                `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
            end
            finish_item(seq_item);
        end
    endtask

endclass

class AES_Encrypt_directed_sequence extends AES_Encrypt_base_sequence;

    `uvm_object_utils(AES_Encrypt_directed_sequence)

    function new(string name = "AES_Encrypt_directed_sequence");
        super.new(name);
    endfunction

    virtual task body();
        AES_Encrypt_seq_item seq_item;
        seq_item = AES_Encrypt_seq_item::type_id::create("seq_item");

        // Directed test cases based on AES_Encrypt_testcase.txt
        // Test Case 1: All zeros plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h0000_0000_0000_0000_0000_0000_0000_0000;
            key == 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 2: All ones plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
            key == 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 3: Random plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'hDEAD_BEEF_DEAD_BEEF_DEAD_BEEF_DEAD_BEEF;
            key == 128'hBEEF_DEAD_BEEF_DEAD_BEEF_DEAD_BEEF_DEAD;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 4: Typical plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h1234_5678_9ABC_DEF0_1234_5678_9ABC_DEF0;
            key == 128'h0FED_CBA9_8765_4321_0FED_CBA9_8765_4321;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 5: Alternating pattern plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'hA5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5;
            key == 128'h5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 6: MSB set plaintext and LSB set key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h8000_0000_0000_0000_0000_0000_0000_0000;
            key == 128'h0000_0000_0000_0000_0000_0000_0000_0001;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 7: All ones plaintext and all zeros key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
            key == 128'h00000000_00000000_00000000_00000000;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 8: Repeating pattern plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h5555_5555_5555_5555_5555_5555_5555_5555;
            key == 128'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 9: Typical plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h12345678_9ABCDEF0_12345678_9ABCDEF0;
            key == 128'hFEDCBA98_76543210_FEDCBA98_76543210;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 10: LSB set plaintext and MSB set key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h0000_0000_0000_0000_0000_0000_0000_0001;
            key == 128'h8000_0000_0000_0000_0000_0000_0000_0000;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 11: All zeros plaintext and all ones key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h0000_0000_0000_0000_0000_0000_0000_0000;
            key == 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 12: Repeating pattern plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h9999_9999_9999_9999_9999_9999_9999_9999;
            key == 128'h6666_6666_6666_6666_6666_6666_6666_6666;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 13: Repeating pattern plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h1111_1111_1111_1111_1111_1111_1111_1111;
            key == 128'h2222_2222_2222_2222_2222_2222_2222_2222;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 14: Max positive plaintext and all zeros key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
            key == 128'h0000_0000_0000_0000_0000_0000_0000_0000;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 15: Alternating pattern plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'hAAAAAAAA_AAAAAAAA_AAAAAAAA_AAAAAAAA;
            key == 128'h55555555_55555555_55555555_55555555;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 16: Repeating pattern plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'hCCCC_CCCC_CCCC_CCCC_CCCC_CCCC_CCCC_CCCC;
            key == 128'h3333_3333_3333_3333_3333_3333_3333_3333;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 17: Typical plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h0123_4567_89AB_CDEF_0123_4567_89AB_CDEF;
            key == 128'hFEDC_BA98_7654_3210_FEDC_BA98_7654_3210;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 18: All zeros plaintext and max positive key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h0000_0000_0000_0000_0000_0000_0000_0000;
            key == 128'h7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 19: All ones plaintext and max positive key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
            key == 128'h7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);

        // Test Case 20: Repeating pattern plaintext and key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in == 128'h8888_8888_8888_8888_8888_8888_8888_8888;
            key == 128'h7777_7777_7777_7777_7777_7777_7777_7777;
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item")
        end
        finish_item(seq_item);
    endtask

endclass

class AES_Encrypt_add_func_seq extends uvm_sequence #(AES_Encrypt_seq_item);

    `uvm_object_utils(AES_Encrypt_add_func_seq)

    function new(string name = "AES_Encrypt_add_func_seq");
        super.new(name);
    endfunction

    virtual task body();
        AES_Encrypt_seq_item seq_item;
        seq_item = AES_Encrypt_seq_item::type_id::create("seq_item");

        // Covering uncovered bins for in and key
        // Bin b3 for in
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in inside {[64'hffffffffffffffff:96'hffffffffffffffffffffffff]};
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item for in bin b3")
        end
        finish_item(seq_item);

        // Bin b2 for in
        start_item(seq_item);
        if (!seq_item.randomize() with {
            in inside {[32'hffffffff:64'hffffffffffffffff]};
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item for in bin b2")
        end
        finish_item(seq_item);

        // Bin b3 for key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            key inside {[64'hffffffffffffffff:96'hffffffffffffffffffffffff]};
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item for key bin b3")
        end
        finish_item(seq_item);

        // Bin b2 for key
        start_item(seq_item);
        if (!seq_item.randomize() with {
            key inside {[32'hffffffff:64'hffffffffffffffff]};
        }) begin
            `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item for key bin b2")
        end
        finish_item(seq_item);

        // Covering cross coverage for in and key
        // Cross coverage for [b3, b2] in in and key
        repeat (10) begin
            start_item(seq_item);
            if (!seq_item.randomize() with {
                in inside {[64'hffffffffffffffff:96'hffffffffffffffffffffffff]};
                key inside {[32'hffffffff:64'hffffffffffffffff]};
            }) begin
                `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item for cross coverage [b3, b2]")
            end
            finish_item(seq_item);
        end

        // Cross coverage for [b4] in in and [b3, b2] in key
        repeat (10) begin
            start_item(seq_item);
            if (!seq_item.randomize() with {
                in inside {[96'hffffffffffffffffffffffff:128'hffffffffffffffffffffffffffffffff]};
                key inside {[32'hffffffff:64'hffffffffffffffff]};
            }) begin
                `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item for cross coverage [b4, b3, b2]")
            end
            finish_item(seq_item);
        end

        // Cross coverage for [b1, allones, allzeros] in in and [b3, b2] in key
        repeat (50) begin
            start_item(seq_item);
            if (!seq_item.randomize() with {
                in inside {[0:32'hffffffff], 128'hffffffffffffffffffffffffffffffff, 128'h00000000000000000000000000000000};
                key inside {[32'hffffffff:64'hffffffffffffffff]};
            }) begin
                `uvm_error("RANDOMIZATION_FAILED", "Failed to randomize seq_item for cross coverage [b1, allones, allzeros, b3, b2]")
            end
            finish_item(seq_item);
        end

    endtask

endclass
