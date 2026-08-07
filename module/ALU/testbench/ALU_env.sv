
`include "uvm_macros.svh"
import uvm_pkg::*;

class ALU_env extends uvm_env;

    // Register the environment with the UVM factory
    `uvm_component_utils(ALU_env)

    // Declare the components
    ALU_agent agent;
    ALU_scoreboard scb;
    ALU_subscriber cov;

    // Declare the virtual interface
    virtual ALU_if vif;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: Create sub-components and configure the interface
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve the virtual interface from the configuration database
        if (!uvm_config_db#(virtual ALU_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not found for ALU_env")
        end

        // Pass the virtual interface to the agent
        uvm_config_db#(virtual ALU_if)::set(this, "agent", "vif", vif);

        // Instantiate the agent, scoreboard, and subscriber
        agent = ALU_agent::type_id::create("agent", this);
        scb = ALU_scoreboard::type_id::create("scb", this);
        cov = ALU_subscriber::type_id::create("cov", this);

        // If reg_model is provided, instantiate it here
        // Example:
        // if (reg_model_exists) begin
        //     regmodel = ALU_reg_model::type_id::create("regmodel", this);
        // end
    endfunction

    // Connect phase: Connect the component interfaces
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect the agent's analysis port to the scoreboard's analysis FIFO
        agent.agent_ap.connect(scb.scb_act_fifo.analysis_export);

        // Connect the agent's analysis port to the subscriber's analysis imp
        agent.agent_ap.connect(cov.sub_imp);

        // If reg_model is provided, connect it here
        // Example:
        // if (reg_model_exists) begin
        //     agent.reg_ap.connect(regmodel.bus_ap);
        // end
    endfunction

endclass
