#!/bin/bash
#
test_name="AES_Encrypt_test"    # uvm_test class
top_mod="AES_Encrypt_Top"          # top module name



seed=$RANDOM



vlogan -full64 -sverilog -f ../testbench/AES_Encrypt_list.f -ntb_opts uvm +incdir+$UVM_HOME/src -assert svaext -l compile.log 
if [ $? -ne 0 ]; then
    exit -1
fi


gcc -c -o c_model.o ../testbench/c_model.c -I$UVM_HOME/src/dpi
if [ $? -ne 0 ]; then
    exit -1
fi

# Elaborate the design

vcs -full64 -debug_acc+all+dmptf -debug_region+cell+encrypt -timescale=1ns/1ps $top_mod -o simv $UVM_HOME/src/dpi/uvm_dpi.cc c_model.o -CFLAGS -DVCS -P $VERDI_HOME/share/PLI/VCS/LINUX64/novas.tab $VERDI_HOME/share/PLI/VCS/LINUX64/pli.a -cm line+cond+fsm+tgl+branch -cm_dir coverage/cov.vdb -l elaborate.log
if [ $? -ne 0 ]; then
    exit -1
fi

# Run the simulation
./simv +UVM_TESTNAME=$test_name +UVM_VERBOSITY=UVM_HIGH +ntb_random_seed=$seed -l simv.log -cm line+cond+fsm+tgl+branch +fsdbfile+sim.fsdb
if [ $? -ne 0 ]; then
    exit -1
fi


