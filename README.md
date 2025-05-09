# UVM_Machine
This repository provides a framework for generating UVM testbenches using Large Language Models (LLM). It streamlines the process of creating testbenches and enhancing test stimuli through templates and configuration-driven workflows.

Key Components
1、API for LLM Interaction
  An API is required to communicate with the LLM.
  Note: The API key has been removed from this repository. Users must add their own API key before use.
2、Core Scripts
  main_control.sh: Primary launch script (recommended to use the two-step workflow below).
3、Two-step workflow:
  Run initial_tb.sh to build the initial UVM testbench.
  Run increase_seq.sh to augment test stimuli with additional sequences.
4、Directory Structure
  auto_xxx/: Contains Python files for generating individual components and their corresponding LLM prompts.
  fix_component_code/: Scripts for error checking and code correction in generated components.
  module/: Open-source benchmark suite (will be continuously updated with new designs).
  module_info.json: Configuration file where users specify the RTL code to test and API details.

