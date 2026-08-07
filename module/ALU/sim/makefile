
# Variables
SCRIPT=brun_vcs.sh

# Default target
all: run

# Run the script
run:
	bash $(SCRIPT)

dve:
	dve -full64 -cov -covdir simv.vdb &

verdi:
	verdi \
	-f ../testbench/ALU_list.f \
	-ssf sim.fsdb

# Clean up
clean:
	rm -rf AN.DB c_model.o csrc simv simv.daidir test.vcd simv.log ucli.key vc_hdrs.h DVEfiles novas.conf simv.vdb vcs_output_files vdCovLog verdiLog cm.log novas.rc 
.PHONY: all run clean
