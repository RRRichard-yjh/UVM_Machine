

import json
import os
import re

# Define the template for the UVM test file
uvm_test_template = """
//------------------------------------------------------------------------------
// Title: {module_name}_test
// Description: UVM test for {test_description}
//------------------------------------------------------------------------------

`include "uvm_macros.svh"

class {module_name}_test extends uvm_test;
  `uvm_component_utils({module_name}_test)
  
  //Member variable declaration

  {module_name}_env env;
  {class1} base_seq;
  {class2} seq1;
  {class3} seq2;

  virtual {module_name}_if vif;


  function new(string name = "{module_name}_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Add build phase code here
	
	if(!uvm_config_db#(virtual {module_name}_if)::get(this,"","vif",vif))
        `uvm_error("{module_name}_test","Can't get vif from the config db")
    uvm_config_db#(virtual {module_name}_if)::set(this,"env","vif",vif);

 
	env = {module_name}_env::type_id::create("env", this);
    base_seq={class1}::type_id::create("base_seq");
    seq1={class2}::type_id::create("seq1");
    seq2={class3}::type_id::create("seq2");

  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    
	// Add run phase code here
	base_seq.start(env.agent.sqr);
    #200;
    seq1.start(env.agent.sqr);
    #200;
    seq2.start(env.agent.sqr);
    #200;

    phase.drop_objection(this);
  endtask

endclass
"""

def extract_class_names(module_name):
    seq_file_path = os.path.join("./auto_seq", f"{module_name}_seq.sv")
    with open(seq_file_path, 'r') as file:
        content = file.read()
    
    # Use regular expression to find all class names
    class_names = re.findall(r'class\s+(\w+)\s+extends', content)
    
    if len(class_names) < 3:
        raise ValueError(f"Expected at least 3 classes in {seq_file_path}, but found {len(class_names)}")
    
    return class_names[0], class_names[1], class_names[2]

def generate_uvm_test(module_name, test_description):
    class1, class2, class3 = extract_class_names(module_name)
    
    file_name = f"{module_name}_test.sv"
    file_path = os.path.join("./auto_test", file_name)  

    test_content = uvm_test_template.format(
        module_name=module_name,
        test_description=test_description,
        class1=class1,
        class2=class2,
        class3=class3
    )
    
    with open(file_path, 'w') as file:
        file.write(test_content)
    
    print(f"Generated UVM test: {file_path}")

def main():
    with open('./module_info.json', 'r') as file:
        data = json.load(file)
    
    module_name = data['modules'][0]['moduleName']
     
    generate_uvm_test(module_name, f"This is a description of {module_name}_test.")

# Run the main function
if __name__ == "__main__":
    main()
