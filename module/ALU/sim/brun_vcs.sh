#!/bin/bash
#

test_name="ALU_test"    # uvm_test class
top_mod="ALU_Top"          # top module name



seed=$RANDOM


vlogan -full64 -sverilog -f ../testbench/ALU_list.f -ntb_opts uvm +incdir+$UVM_HOME/src -assert svaext -l compile.log
if [ $? -ne 0 ]; then
    exit -1
fi



# Elaborate the design


vcs -full64 -debug_acc+all+dmptf -debug_region+cell+encrypt -cm line+cond+tgl+fsm+assert+branch -cm_line contassign -cm_dir coverage/cov.vdb -timescale=1ns/1ps  $top_mod -o simv $UVM_HOME/src/dpi/uvm_dpi.cc -CFLAGS -DVCS -P $VERDI_HOME/share/PLI/VCS/LINUX64/novas.tab $VERDI_HOME/share/PLI/VCS/LINUX64/pli.a -l elaborate.log

if [ $? -ne 0 ]; then
    exit -1
fi

# Run the simulation
./simv +UVM_TESTNAME=$test_name +UVM_VERBOSITY=UVM_HIGH +ntb_random_seed=$seed -l simv.log -cm line+cond+fsm+tgl+branch +fsdbfile+sim.fsdb
if [ $? -ne 0 ]; then
    exit -1
fi



