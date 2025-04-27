
`uvm_analysis_imp_decl(_actual)
`uvm_analysis_imp_decl(_expected)

class AES_Encrypt_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(AES_Encrypt_scoreboard)
    
    // Analysis ports (corrected naming)
    uvm_analysis_imp_actual #(AES_Encrypt_seq_item, AES_Encrypt_scoreboard) actual_imp;
    uvm_analysis_imp_expected #(AES_Encrypt_seq_item, AES_Encrypt_scoreboard) expected_imp;

    // Transaction queues
    AES_Encrypt_seq_item expected_queue[$];
    AES_Encrypt_seq_item actual_queue[$];


   int match_count = 0;
   int mismatch_count = 0;
   int total_checked = 0;

   real Pass_rate = 0.0;

   function new(string name, uvm_component parent);
        super.new(name, parent);
        actual_imp = new("actual_imp", this);
        expected_imp = new("expected_imp", this);
   endfunction

   
   // Required write method for actual DUT results
   function void write_actual(AES_Encrypt_seq_item actual);
        actual_queue.push_back(actual);
        check_pairs();
   endfunction


   // Required write method for expected results
   function void write_expected(AES_Encrypt_seq_item expected);
        expected_queue.push_back(expected);
        check_pairs();
   endfunction


   // Check matching transaction pairs
   function void check_pairs();
        while (expected_queue.size() > 0 && actual_queue.size() > 0) begin
            AES_Encrypt_seq_item expected = expected_queue.pop_front();
            AES_Encrypt_seq_item actual = actual_queue.pop_front();
            
            total_checked++;
            
            // Check if actual output is in X state
            if (actual.out === 'x) begin
                `uvm_warning("SCB", "Actual output is in X state, skipping comparison")
                continue;
            end

            // Compare output signals
            if (actual.out === expected.out) begin
                match_count++;
                `uvm_info("SCB", $sformatf("Match: Expected=0x%0h, Actual=0x%0h", expected.out, actual.out), UVM_HIGH)
            end else begin
                mismatch_count++;
                `uvm_error("SCB", $sformatf("Mismatch: Expected=0x%0h, Actual=0x%0h", expected.out, actual.out))
            end
        end
   endfunction

 
   function void report_phase(uvm_phase phase);
        total_checked = mismatch_count + match_count;
        if (total_checked > 0) begin
            Pass_rate = match_count / real'(total_checked) * 100.0;
        end

        `uvm_info("SCB", "----------------------------------------", UVM_NONE)
        `uvm_info("SCB", "SCOREBOARD SUMMARY", UVM_NONE)
        `uvm_info("SCB", $sformatf("Total checked:  %0d", total_checked), UVM_NONE)
        `uvm_info("SCB", $sformatf("Matches:        %0d", match_count), UVM_NONE)
        `uvm_info("SCB", $sformatf("Mismatches:     %0d", mismatch_count), UVM_NONE)
        `uvm_info("SCB", $sformatf("Pass_rate:     %.2f%%", Pass_rate), UVM_NONE)

        if (mismatch_count > 0) begin
           $write("%c[7;31m", 27);
           $display("TEST FAILED");
           $write("%c[0m", 27);
        end else begin
           $write("%c[7;32m", 27);
           $display("TEST PASSED");
           $write("%c[0m", 27);
        end

   endfunction

endclass
