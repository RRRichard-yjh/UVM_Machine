
import os
import json
import logging
import argparse
import re
import requests


os.environ["OPENAI_API_BASE"] = ""
os.environ["OPENAI_API_KEY"] = ""


model = "deepseek-v3-241226"



# ===================== generate scb example_1 =====================
def generate_uvm_scb_example_1(module_name, scoreboard_description):
    uvm_scoreboard_template = """
//------------------------------------------------------------------------------
// Title: {module_name}_scoreboard
// Description: {scoreboard_description}
//------------------------------------------------------------------------------

class {module_name}_scoreboard extends uvm_scoreboard;
   `uvm_component_utils({module_name}_scoreboard)
   uvm_tlm_analysis_fifo #({module_name}_seq_item) scb_act_fifo;
    
   int match_count = 0;
   int mismatch_count = 0;
   int total_checked = 0;

   real Pass_rate = 0.0;

   extern function new (string name="{module_name}_scoreboard", uvm_component parent =null);
   extern function void build_phase(uvm_phase phase);
   extern task run_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);

endclass:{module_name}_scoreboard

function {module_name}_scoreboard::new (string name="{module_name}_scoreboard", uvm_component parent =null);
    super.new(name,parent);
endfunction

function void uart_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb_act_fifo = new("scb_act_fifo", this);
endfunction

task run_phase(uvm_phase phase);
  {module_name}_seq_item act_item;
  {module_name}_seq_item exp_item;
  act_item=new();
  exp_item=new();
  ref_model = new();
  forever begin
      scb_act_fifo.get(act_item);
      //Need to supplement with a LLM
  end
endtask
 
 
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

"""
    file_name = f"{module_name}_scb_example.sv"
    file_path = os.path.join("./auto_scb", file_name)  
    scoreboard_content = uvm_scoreboard_template.format(
        module_name=module_name,
        scoreboard_description=scoreboard_description,
    )
    with open(file_path, 'w') as file:
        file.write(scoreboard_content)
    print(f"Generated UVM scoreboard example (type 1): {file_path}")

# ===================== generate scb example_2 =====================
def generate_uvm_scb_example_2(module_name, scoreboard_description):
    uvm_scoreboard_template = """
//------------------------------------------------------------------------------
// Title: {module_name}_scoreboard_example_2
// Description: {scoreboard_description}
//------------------------------------------------------------------------------

`uvm_analysis_imp_decl(_actual)
`uvm_analysis_imp_decl(_expected)

class {module_name}_scoreboard extends uvm_scoreboard;
   `uvm_component_utils({module_name}_scoreboard)
    
    // Analysis ports (corrected naming)
    uvm_analysis_imp_actual #({module_name}_seq_item, {module_name}_scoreboard) actual_imp;
    uvm_analysis_imp_expected #({module_name}_seq_item, {module_name}_scoreboard) expected_imp;

    // Transaction queues
    {module_name}_seq_item expected_queue[$];
    {module_name}_seq_item actual_queue[$];


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
   function void write_actual({module_name}_seq_item actual);
        actual_queue.push_back(actual);
        check_pairs();
   endfunction


   // Required write method for expected results
   function void write_expected({module_name}_seq_item expected);
        expected_queue.push_back(expected);
        check_pairs();
   endfunction


   // Check matching transaction pairs
   function void check_pairs();
        while (expected_queue.size() > 0 && actual_queue.size() > 0) begin
            {module_name}_seq_item expected = expected_queue.pop_front();
            {module_name}_seq_item actual = actual_queue.pop_front();
            
            total_checked++;
            
            //Need to supplement with a LLM
            
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

"""
    file_name = f"{module_name}_scb_example.sv"
    file_path = os.path.join("./auto_scb", file_name)  
    scoreboard_content = uvm_scoreboard_template.format(
        module_name=module_name,
        scoreboard_description=scoreboard_description,
    )
    with open(file_path, 'w') as file:
        file.write(scoreboard_content)
    print(f"Generated UVM scoreboard example (type 2): {file_path}")

# ===================== generate scb =====================
def get_request(prompt,temperature=0.2,max_new_tokens = 4096,model=model):
    url = 'http://10.10.12.92:12001/chat'
    query = {
        "model": model,
        "prompt":prompt,
        "max_new_tokens": max_new_tokens,
        "temperature": temperature
    }

    request = requests.post(url, json=query)
    if request.json()["code"] == 200:
        return request.json()['data']
    else:
        return request

def check_ref_file_has_analysis_port(ref_content):
    """Check if reference model file contains uvm_analysis_port"""
    patterns = [
        r'uvm_analysis_port\s*#',
        r'uvm_analysis_imp\s*#',
        r'uvm_analysis_export\s*#'
    ]
    
    for pattern in patterns:
        if re.search(pattern, ref_content):
            return True
    return False

def main():
    parser = argparse.ArgumentParser(description='Script to process JSON configuration and other related files')
    parser.add_argument('-config', default='./module_info.json', type=str, help='Path to JSON configuration file')
    parser.add_argument('-prompt1', default='./auto_scb/prompt_scb_1.txt', type=str, help='Path to prompt for type 1 scoreboard ')
    parser.add_argument('-prompt2', default='./auto_scb/prompt_scb_2.txt', type=str, help='Path to prompt for type 2 scoreboard')
    args = parser.parse_args()

    with open(args.config, 'r', encoding='utf-8') as config_file:
        config = json.load(config_file)
    module_info = config['modules'][0]  
    module_name = module_info['moduleName']
    print(f"Extracted module_name in auto_scb: {module_name}")

    paths = module_info['paths']
    uvm_testbench = paths['uvm_testbench'].format(moduleName=module_name)
    ref_file = f"{uvm_testbench}/{module_name}_reference_model.sv"
    mon_file = f"./auto_monitor/{module_name}_monitor.sv"
    
    # Read reference file to determine which template to use
    with open(ref_file, 'r', encoding='utf-8') as reff:
        ref_content = reff.read()
    
    # Choose template based on reference model content
    use_type2 = check_ref_file_has_analysis_port(ref_content)
    if use_type2:
        generate_uvm_scb_example_2(module_name, f"This is a description of {module_name}_scb_example.")
    else:
        generate_uvm_scb_example_1(module_name, f"This is a description of {module_name}_scb_example.")

    example_file = f"./auto_scb/{module_name}_scb_example.sv"

    with open(mon_file, 'r', encoding='utf-8') as monf:
        mon_content = monf.read()
    with open(example_file, 'r', encoding='utf-8') as examplef:
        example_content = examplef.read()
    
    # Choose the appropriate prompt file based on scoreboard type
    prompt_file = args.prompt2 if use_type2 else args.prompt1
    with open(prompt_file, 'r', encoding='utf-8') as promptf:
        p_content = promptf.read()

    prompt1 = f"{mon_content}{ref_content}{example_content}{p_content}"
    answer1 = get_request(prompt1)
    print(answer1)

    with open(r"./auto_scb/answer1.md", "w", encoding='utf-8') as wf:
        wf.write(answer1)

    content = re.findall(r'```systemverilog([\s\S]+?)```', answer1, re.IGNORECASE)
    if content:
        output_file_name = f"./auto_scb/{module_name}_scoreboard.sv"
        with open(output_file_name, 'w+', encoding='utf-8') as output_file:
            output_file.write(content[0])

if __name__ == '__main__':
    main()
