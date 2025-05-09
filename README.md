# UVM_Machine  

This repository provides a framework for generating UVM testbenches using Large Language Models (LLM). It streamlines the process of creating testbenches and enhancing test stimuli through templates and configuration - driven workflows.  

## Key Components  
1. **API for LLM Interaction**  
   - An API is required to communicate with the LLM.  
   - **Note**: The API key has been removed from this repository. Users must add their own API key before use.  

2. **Core Scripts**  
   - `main_control.sh`: Primary launch script (recommended to use the two - step workflow below).  
   - **Two - step workflow**:  
     1. run `initial_tb.sh` to build the initial UVM testbench.  
     2. run `increase_seq.sh` to augment test stimuli with additional sequences.  

3. **Directory Structure**  
   - `auto_xxx/`: Contains Python files for generating individual components and their corresponding LLM prompts.  
   - `fix_component_code/`: Scripts for error checking and code correction in generated components.  
   - `module/`: Open - source benchmark suite (will be continuously updated with new designs).  
   - `module_info.json`: Configuration file where users specify the RTL code to test and API details.  

## Getting Started  
1. **Confige API Key**
    - Add your LLM API key to the appropriate location in the scripts (details in the component generation files).

2. **Set Up RTL Configuration**
    - Edit `module_info. json` to include the path and details of the RTL code you want to test.

3. **Run the Framework**
   - Step 1: Generate the initial testbench
     ```bash
      ./initial_tb.sh

   - Step 2: Enhance test stimuli
      ```bash
      ./increase_seq.sh
