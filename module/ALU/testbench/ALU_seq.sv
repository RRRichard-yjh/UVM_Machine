
// ALU_base_sequence: Base sequence class for ALU testbench
class ALU_base_sequence extends uvm_sequence #(ALU_seq_item);

    // Register the sequence class with UVM
    `uvm_object_utils(ALU_base_sequence)

    // Constructor
    function new(string name = "ALU_base_sequence");
        super.new(name);
    endfunction

    // Body method to generate transactions
    virtual task body();
        ALU_seq_item seq_item;
        seq_item = ALU_seq_item::type_id::create("seq_item");

        // Generate a basic transaction
        start_item(seq_item);
        if (!seq_item.randomize()) begin
            `uvm_error("ALU_base_sequence", "Randomization failed")
        end
        finish_item(seq_item);
    endtask

endclass

// ALU_random_sequence: Random sequence class for ALU testbench
class ALU_random_sequence extends ALU_base_sequence;

    // Register the sequence class with UVM
    `uvm_object_utils(ALU_random_sequence)

    // Constructor
    function new(string name = "ALU_random_sequence");
        super.new(name);
    endfunction

    // Body method to generate random transactions
    virtual task body();
        ALU_seq_item seq_item;
        seq_item = ALU_seq_item::type_id::create("seq_item");

        // Generate 5000 random transactions
        repeat (5000) begin
            start_item(seq_item);
            if (!seq_item.randomize()) begin
                `uvm_error("ALU_random_sequence", "Randomization failed")
            end
            finish_item(seq_item);
        end
    endtask

endclass

// ALU_directed_sequence: Directed sequence class for ALU testbench
class ALU_directed_sequence extends ALU_base_sequence;

    // Register the sequence class with UVM
    `uvm_object_utils(ALU_directed_sequence)

    // Constructor
    function new(string name = "ALU_directed_sequence");
        super.new(name);
    endfunction

    // Body method to generate directed transactions
    virtual task body();
        ALU_seq_item seq_item;
        seq_item = ALU_seq_item::type_id::create("seq_item");

        // Directed test 1: Typical Input (1.0 + 2.0)
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h3F80_0000;
            b_operand == 32'h4000_0000;
            Operation == 4'd10;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 2: Infinity + Infinity
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h7F80_0000;
            b_operand == 32'h7F80_0000;
            Operation == 4'd10;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 3: Infinity / Zero
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h7F80_0000;
            b_operand == 32'h0000_0000;
            Operation == 4'd2;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 4: Typical Input (3.0 * 4.0)
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4040_0000;
            b_operand == 32'h4080_0000;
            Operation == 4'd1;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 5: Zero - Zero
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h0000_0000;
            b_operand == 32'h0000_0000;
            Operation == 4'd3;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 6: Infinity / Infinity
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h7F80_0000;
            b_operand == 32'h7F80_0000;
            Operation == 4'd2;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 7: Typical Input (1.0 OR 1.0)
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h3F80_0000;
            b_operand == 32'h3F80_0000;
            Operation == 4'd4;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 8: Infinity AND 1.0
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h7F80_0000;
            b_operand == 32'h3F80_0000;
            Operation == 4'd5;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 9: Infinity XOR Infinity
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h7F80_0000;
            b_operand == 32'h7F80_0000;
            Operation == 4'd6;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 10: Typical Input (1.0 Left Shift)
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h3F80_0000;
            b_operand == 32'h3F80_0000;
            Operation == 4'd7;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 11: Infinity Right Shift
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h7F80_0000;
            b_operand == 32'h3F80_0000;
            Operation == 4'd8;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 12: Infinity to Integer Conversion
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h7F80_0000;
            b_operand == 32'h7F80_0000;
            Operation == 4'd9;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 13: Typical Input (1.0 Complement)
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h3F80_0000;
            b_operand == 32'h3F80_0000;
            Operation == 4'd11;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 14: Zero Complement
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h0000_0000;
            b_operand == 32'h0000_0000;
            Operation == 4'd11;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);

        // Directed test 15: Infinity Complement
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h7F80_0000;
            b_operand == 32'h7F80_0000;
            Operation == 4'd11;
        }) begin
            `uvm_error("ALU_directed_sequence", "Randomization failed")
        end
        finish_item(seq_item);
    endtask

endclass


class ALU_line_coverage_seq extends uvm_sequence #(ALU_seq_item);

    // Register the sequence class with UVM
    `uvm_object_utils(ALU_line_coverage_seq)

    // Constructor
    function new(string name = "ALU_line_coverage_seq");
        super.new(name);
    endfunction

    // Body method to generate transactions targeting uncovered lines
    virtual task body();
        ALU_seq_item seq_item;
        seq_item = ALU_seq_item::type_id::create("seq_item");

        // Sequence 1: Targeting uncovered lines in Floating_Point_to_Integer module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h3F80_0000; // 1.0 in IEEE-754
            Operation == 4'd9;         // Floating-point to Integer Conversion
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 1")
        end
        finish_item(seq_item);

        // Sequence 2: Targeting uncovered lines in priority_encoder module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4000_0000; // 2.0 in IEEE-754
            b_operand == 32'h3F80_0000; // 1.0 in IEEE-754
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 2")
        end
        finish_item(seq_item);

        // Sequence 3: Targeting uncovered lines in priority_encoder module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4080_0000; // 4.0 in IEEE-754
            b_operand == 32'h4040_0000; // 3.0 in IEEE-754
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 3")
        end
        finish_item(seq_item);

        // Sequence 4: Targeting uncovered lines in priority_encoder module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4100_0000; // 8.0 in IEEE-754
            b_operand == 32'h4080_0000; // 4.0 in IEEE-754
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 4")
        end
        finish_item(seq_item);

        // Sequence 5: Targeting uncovered lines in priority_encoder module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4180_0000; // 16.0 in IEEE-754
            b_operand == 32'h4100_0000; // 8.0 in IEEE-754
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 5")
        end
        finish_item(seq_item);

        // Sequence 6: Targeting uncovered lines in priority_encoder module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4200_0000; // 32.0 in IEEE-754
            b_operand == 32'h4180_0000; // 16.0 in IEEE-754
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 6")
        end
        finish_item(seq_item);

        // Sequence 7: Targeting uncovered lines in priority_encoder module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4280_0000; // 64.0 in IEEE-754
            b_operand == 32'h4200_0000; // 32.0 in IEEE-754
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 7")
        end
        finish_item(seq_item);

        // Sequence 8: Targeting uncovered lines in priority_encoder module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4300_0000; // 128.0 in IEEE-754
            b_operand == 32'h4280_0000; // 64.0 in IEEE-754
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 8")
        end
        finish_item(seq_item);

        // Sequence 9: Targeting uncovered lines in priority_encoder module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4380_0000; // 256.0 in IEEE-754
            b_operand == 32'h4300_0000; // 128.0 in IEEE-754
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 9")
        end
        finish_item(seq_item);

        // Sequence 10: Targeting uncovered lines in priority_encoder module
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h4400_0000; // 512.0 in IEEE-754
            b_operand == 32'h4380_0000; // 256.0 in IEEE-754
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq", "Randomization failed for Sequence 10")
        end
        finish_item(seq_item);

    endtask

endclass


class ALU_add_branch_code_seq extends uvm_sequence #(ALU_seq_item);

    // Register the sequence class with UVM
    `uvm_object_utils(ALU_add_branch_code_seq)

    // Constructor
    function new(string name = "ALU_add_branch_code_seq");
        super.new(name);
    endfunction

    // Body method to generate transactions targeting untriggered branches
    virtual task body();
        ALU_seq_item seq_item;
        seq_item = ALU_seq_item::type_id::create("seq_item");

        // Generate transactions to cover untriggered branches in Addition_Subtraction module
        // Branch: significand_a assignment based on exponent value
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand[30:23] == 8'd0;  // Exponent zero to trigger hidden bit 0
            b_operand[30:23] == 8'd0;
            Operation == 4'd10;       // Addition operation
        }) begin
            `uvm_error("ALU_add_branch_code_seq", "Randomization failed")
        end
        finish_item(seq_item);

        // Generate transactions to cover untriggered branches in Multiplication module
        // Branch: product_mantissa == 23'd0
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h0000_0000;  // Zero input
            b_operand == 32'h0000_0000;
            Operation == 4'd1;          // Multiplication operation
        }) begin
            `uvm_error("ALU_add_branch_code_seq", "Randomization failed")
        end
        finish_item(seq_item);

        // Generate transactions to cover untriggered branches in Floating_Point_to_Integer module
        // Branch: exponent value 128
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand[30:23] == 8'd128;  // Exponent 128
            Operation == 4'd9;           // Floating-point to integer conversion
        }) begin
            `uvm_error("ALU_add_branch_code_seq", "Randomization failed")
        end
        finish_item(seq_item);

        // Generate transactions to cover untriggered branches in priority_encoder module
        // Branch: significand[24] == 1'b1
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand[22:0] == 23'h7F_FFFF;  // Maximum significand value
            b_operand[22:0] == 23'h7F_FFFF;
            Operation == 4'd3;              // Subtraction operation
        }) begin
            `uvm_error("ALU_add_branch_code_seq", "Randomization failed")
        end
        finish_item(seq_item);

        // Generate transactions to cover untriggered branches in Division module
        // Branch: exponent[8] & exponent[7] (Underflow condition)
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand[30:23] == 8'd1;    // Very small exponent
            b_operand[30:23] == 8'd254;  // Very large exponent
            Operation == 4'd2;           // Division operation
        }) begin
            `uvm_error("ALU_add_branch_code_seq", "Randomization failed")
        end
        finish_item(seq_item);

    endtask

endclass


class ALU_toggle_sequence extends uvm_sequence #(ALU_seq_item);

    // Register the sequence class with UVM
    `uvm_object_utils(ALU_toggle_sequence)

    // Constructor
    function new(string name = "ALU_toggle_sequence");
        super.new(name);
    endfunction

    // Body method to generate transactions
    virtual task body();
        ALU_seq_item seq_item;
        seq_item = ALU_seq_item::type_id::create("seq_item");

        // Generate transactions to improve toggle coverage
        repeat (10) begin
            start_item(seq_item);
            if (!seq_item.randomize() with {
                // Targeting untoggled signals
                a_operand[31] == 1'b0;
                b_operand[31] == 1'b1;
                Operation inside {[4'd1:4'd11]};
            }) begin
                `uvm_error("ALU_toggle_sequence", "Randomization failed")
            end
            finish_item(seq_item);
        end

        // Generate transactions to improve toggle coverage
        repeat (10) begin
            start_item(seq_item);
            if (!seq_item.randomize() with {
                // Targeting untoggled signals
                a_operand[31] == 1'b1;
                b_operand[31] == 1'b0;
                Operation inside {[4'd1:4'd11]};
            }) begin
                `uvm_error("ALU_toggle_sequence", "Randomization failed")
            end
            finish_item(seq_item);
        end

        // Generate transactions to improve toggle coverage
        repeat (10) begin
            start_item(seq_item);
            if (!seq_item.randomize() with {
                // Targeting untoggled signals
                a_operand[31] == 1'b1;
                b_operand[31] == 1'b1;
                Operation inside {[4'd1:4'd11]};
            }) begin
                `uvm_error("ALU_toggle_sequence", "Randomization failed")
            end
            finish_item(seq_item);
        end

        // Generate transactions to improve toggle coverage
        repeat (10) begin
            start_item(seq_item);
            if (!seq_item.randomize() with {
                // Targeting untoggled signals
                a_operand[31] == 1'b0;
                b_operand[31] == 1'b0;
                Operation inside {[4'd1:4'd11]};
            }) begin
                `uvm_error("ALU_toggle_sequence", "Randomization failed")
            end
            finish_item(seq_item);
        end
    endtask

endclass


class ALU_add_cond_code_seq extends uvm_sequence #(ALU_seq_item);

    // Register the sequence class with UVM
    `uvm_object_utils(ALU_add_cond_code_seq)

    // Constructor
    function new(string name = "ALU_add_cond_code_seq");
        super.new(name);
    endfunction

    // Body method to generate transactions
    virtual task body();
        ALU_seq_item seq_item;
        seq_item = ALU_seq_item::type_id::create("seq_item");

        // Generate transactions to cover uncovered conditions
        // Condition 1: Addition with negative operands
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand[31] == 0;
            b_operand[31] == 0;
            Operation == 4'd10;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for negative addition")
        end
        finish_item(seq_item);

        // Condition 2: Subtraction with positive and negative operands
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand[31] == 0;
            b_operand[31] == 1;
            Operation == 4'd3;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for mixed subtraction")
        end
        finish_item(seq_item);

        // Condition 3: Multiplication with overflow
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand[30:23] == 8'h7F;
            b_operand[30:23] == 8'h7F;
            Operation == 4'd1;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for multiplication overflow")
        end
        finish_item(seq_item);

        // Condition 4: Division with underflow
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand[30:23] == 8'h01;
            b_operand[30:23] == 8'h7F;
            Operation == 4'd2;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for division underflow")
        end
        finish_item(seq_item);

        // Condition 5: Logical operations with all bits set
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'hFFFF_FFFF;
            b_operand == 32'hFFFF_FFFF;
            Operation == 4'd4;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for logical OR")
        end
        finish_item(seq_item);

        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'hFFFF_FFFF;
            b_operand == 32'hFFFF_FFFF;
            Operation == 4'd5;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for logical AND")
        end
        finish_item(seq_item);

        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'hFFFF_FFFF;
            b_operand == 32'hFFFF_FFFF;
            Operation == 4'd6;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for logical XOR")
        end
        finish_item(seq_item);

        // Condition 6: Shift operations with maximum shift value
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'hFFFF_FFFF;
            Operation == 4'd7;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for left shift")
        end
        finish_item(seq_item);

        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'hFFFF_FFFF;
            Operation == 4'd8;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for right shift")
        end
        finish_item(seq_item);

        // Condition 7: Complement operation with zero
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h0000_0000;
            Operation == 4'd11;
        }) begin
            `uvm_error("ALU_add_cond_code_seq", "Randomization failed for complement zero")
        end
        finish_item(seq_item);

    endtask

endclass


class ALU_add_func_seq extends uvm_sequence #(ALU_seq_item);

    `uvm_object_utils(ALU_add_func_seq)

    // Constructor
    function new(string name = "ALU_add_func_seq");
        super.new(name);
    endfunction

    // Body method to generate transactions
    virtual task body();
        ALU_seq_item seq_item;
        seq_item = ALU_seq_item::type_id::create("seq_item");

        // Cover uncovered bins for Operation coverpoint
        // Bin: CMD_ADD
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd10;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_ADD")
        end
        finish_item(seq_item);

        // Bin: CMD_SUB
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd3;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_SUB")
        end
        finish_item(seq_item);

        // Bin: CMD_MUL
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd1;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_MUL")
        end
        finish_item(seq_item);

        // Bin: CMD_DIV
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd2;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_DIV")
        end
        finish_item(seq_item);

        // Bin: CMD_OR
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd4;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_OR")
        end
        finish_item(seq_item);

        // Bin: CMD_AND
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd5;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_AND")
        end
        finish_item(seq_item);

        // Bin: CMD_XOR
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd6;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_XOR")
        end
        finish_item(seq_item);

        // Bin: CMD_LS
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd7;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_LS")
        end
        finish_item(seq_item);

        // Bin: CMD_RS
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd8;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_RS")
        end
        finish_item(seq_item);

        // Bin: CMD_FLOAT_TO_INT
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd9;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_FLOAT_TO_INT")
        end
        finish_item(seq_item);

        // Bin: CMD_COMPLEMENT
        start_item(seq_item);
        if (!seq_item.randomize() with {
            Operation == 4'd11;
        }) begin
            `uvm_error("ALU_add_func_seq", "Randomization failed for CMD_COMPLEMENT")
        end
        finish_item(seq_item);

    endtask

endclass


class ALU_line_coverage_seq_1 extends uvm_sequence #(ALU_seq_item);

    // Register the sequence class with UVM
    `uvm_object_utils(ALU_line_coverage_seq_1)

    // Constructor
    function new(string name = "ALU_line_coverage_seq_1");
        super.new(name);
    endfunction

    // Body method to generate transactions targeting uncovered lines
    virtual task body();
        ALU_seq_item seq_item;
        seq_item = ALU_seq_item::type_id::create("seq_item");

        // Sequence 1: 
        start_item(seq_item);
        if (!seq_item.randomize() with {
			a_operand == 32'h3FC00000; // 1.5
            b_operand == 32'h3F800000; // 1.0
            Operation == 4'd3;         
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 1")
        end
        finish_item(seq_item);

        // Sequence 2:         
		start_item(seq_item);
        if (!seq_item.randomize() with {
			a_operand == 32'h3F800000; // 1.0
            b_operand == 32'h3F7FFFFF; // 1.0 - 2^-23
            Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 2")
        end
        finish_item(seq_item);

        // Sequence 3: 
        start_item(seq_item);
        if (!seq_item.randomize() with {
		   a_operand == 32'h3F800001; // 1.0 + 2^-23
           b_operand == 32'h3F800000; // 1.0
           Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 3")
        end
        finish_item(seq_item);

        // Sequence 4: 
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h40000000; // 2.0
            b_operand == 32'h3F800000; // 1.0           
			Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 4")
        end
        finish_item(seq_item);

        // Sequence 5:         
		start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h00800001; // 2^-126 + 2^-149
            b_operand == 32'h00800000; // 2^-126
			Operation == 4'd3;           // Subtraction
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 5")
        end
        finish_item(seq_item);

        // Sequence 6: 
        for (int i = 1; i <= 23; i++) begin
           start_item(seq_item);
           if (!seq_item.randomize() with {
             a_operand == 32'h3F800000;         // 1.0
             b_operand == 32'h3F800000 - (1 << (23-i));
             Operation == 4'd3;                 // Subtraction
           }) begin
           `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 6 iteration")
           end
           finish_item(seq_item);
        end

        // Sequence 7: 
        start_item(seq_item);
        if (!seq_item.randomize() with {
			a_operand == 32'h3F860A92; // ~1.047
            b_operand == 32'h3F8CCCCD; // ~1.1
            Operation == 4'd2;           
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 7")
        end
        finish_item(seq_item);

        // Sequence 8: 
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h3F700000; // ~0.9375
            b_operand == 32'h3F900000; // ~1.125          
			Operation == 4'd2;           
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 8")
        end
        finish_item(seq_item);

        // Sequence 9: 
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h3F800100; 
            b_operand == 32'h3F800000; // 1.0         
			Operation == 4'd2;           
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 9")
        end
        finish_item(seq_item);

        // Sequence 10: 
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h40000000;  
            b_operand == 32'h3F800000; // 1.0         
			Operation == 4'd2;           
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 9")
        end
        finish_item(seq_item);
        
		// Sequence 11:
		start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h7F7FFFFF; 
            b_operand == 32'h00800000; // 1.0         
			Operation == 4'd2;           
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 9")
        end
        finish_item(seq_item);

        // Sequence 12:
		start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h00000001; 
            b_operand == 32'h3F800000; // 1.0         
			Operation == 4'd2;         
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 9")
        end
        finish_item(seq_item);

		// Sequence 12:
		start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h3F866666; 
            b_operand == 32'h3F8CCCCD; // 1.0         
			Operation == 4'd2;         
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 9")
        end
        finish_item(seq_item);
        
		// Sequence 13: 
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h00800001;  
            b_operand == 32'h7F7FFFFF; 
			Operation == 4'd2;         
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 10")
        end
        finish_item(seq_item);

        // Sequence 14: 
        start_item(seq_item);
        if (!seq_item.randomize() with {
            a_operand == 32'h00000001;  
            b_operand == 32'h3F800000; 
			Operation == 4'd2;         
        }) begin
            `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 10")
        end
        finish_item(seq_item);

		// Sequence 15: 
        for (int n = 1; n <= 23; n++) begin
           start_item(seq_item);
           if (!seq_item.randomize() with {
             a_operand == 32'h3F800000 | (1 << (23 - (n-1)));
             b_operand == 32'h3F800000;
             Operation == 4'd2;                 
           }) begin
           `uvm_error("ALU_line_coverage_seq_1", "Randomization failed for Sequence 6 iteration")
           end
           finish_item(seq_item);
        end

    endtask

endclass

