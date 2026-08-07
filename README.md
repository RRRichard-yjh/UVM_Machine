# UVM_Machine  

  This repository provides a framework for generating UVM testbenches using Large Language Models (LLM). It streamlines the process of creating testbenches and enhancing test stimuli through templates and configuration - driven workflows.  
  Due to confidentiality agreements associated with our RTL designs, only a subset of the benchmark cases is open-sourced in this repository. For more advanced features and full capabilities, please refer to **Integration**.

## Key Components  
1. **About Subscriber & Reference Model**
    - Subscriber and Reference Model (ref_model) generation are not included. Maybe I will present detailed generation methodology in other work. 

## Main Workflow  
1. Configure your LLM API key in the scripts.
2. Edit `module_info.json` to specify your RTL design.
3. Run `./initial_tb.sh` to generate the UVM testbench.
4. Run `./increase_seq.sh` to enhance test stimuli.

## Integration
  This repository is aligned with the content presented in our paper. We are continuously extending this work with additional features and capabilities, which are not fully open-sourced here.  
  Due to continuous model updates causing generation instability, we have temporarily withdrawn the original open-source content, while the complete version is now available through ChatDV as a stable tool:  
  https://www.nctieda.com/CHATDV.html  
  The full workflow can be tried there. Alternatively, you may contact the author to request access — please state your affiliation and purpose.

## Appendix
   - This work has been accepted by ICCAD 2025.
  **DOI**: 10.1109/ICCAD66269.2025.11240679
   If you find this project helpful, please consider citing our paper. We sincerely appreciate your support.
