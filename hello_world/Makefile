UVM_HOME = ../uvm-UVM_1_2_RELEASE/distrib
UVM_VERBOSITY = UVM_MEDIUM
TEST = hello_world
TEST_TOOL = /usr/bin/test

VCS =	vcs -full64 -sverilog -timescale=1ns/1ns \
	-debug_all \
	+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
	+incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv \
	-cm line+cond+fsm+branch+tgl -cm_dir ./coverage.vdb \
	$(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS

SIMV = ./simv +UVM_VERBOSITY=$(UVM_VERBOSITY) \
	+UVM_TESTNAME=$(TEST) +UVM_TR_RECORD +UVM_LOG_RECORD \
	+verbose=1 +ntb_random_seed=244 -l vcs.log

CHECK = \
	@$(TEST_TOOL) \( `grep -c 'UVM_ERROR :    $(N_ERRS)' vcs.log` -eq 1 \) -a \
			 \( `grep -c 'UVM_FATAL :    $(N_FATALS)' vcs.log` -eq 1 \)

x:	comp run 

comp:
	$(VCS) +incdir+. hello_tb_top.sv

run:
	$(SIMV)
	$(CHECK)

clean:
	rm -rf coverage.vdb csrc DVEfiles inter.vpd simv simv.daidir ucli.key vc_hdrs.h vcs.log .inter.vpd.uvm
