//---------------------------------------------------------------------- 
//   Copyright 2010-2011 Cadence Design Systems, Inc.
//   Copyright 2010-2011 Mentor Graphics Corporation
//   All Rights Reserved Worldwide 
// 
//   Licensed under the Apache License, Version 2.0 (the 
//   "License"); you may not use this file except in 
//   compliance with the License.  You may obtain a copy of 
//   the License at 
// 
//       http://www.apache.org/licenses/LICENSE-2.0 
// 
//   Unless required by applicable law or agreed to in 
//   writing, software distributed under the License is 
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
//   CONDITIONS OF ANY KIND, either express or implied.  See 
//   the License for the specific language governing 
//   permissions and limitations under the License. 
//----------------------------------------------------------------------

// This test creates a simple hierarchy where two leaf cells belong
// to two different domains. It verifies that the domains run
// independently in the runtime phases but togehter in the common
// phases.

`define TASK(NAME,DELAY,STARTTIME) \
    task NAME``_phase(uvm_phase phase); \
      phase.raise_objection(this,`"start NAME`"); \
      phase_run[uvm_``NAME``_phase::get()] = 1; \
      `uvm_info(`"NAME`", `"Starting NAME activity`", UVM_NONE) \
      if($time != STARTTIME)  begin \
        failed = 1; \
        `uvm_error(`"NAME`", $sformatf(`"Expected NAME start time of %0t`",STARTTIME)) \
      end \
      #DELAY; \
      `uvm_info(`"NAME`", `"Ending NAME activity`", UVM_NONE) \
      phase.drop_objection(this,`"end NAME`"); \
    endtask

module test;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  bit failed = 0;
  bit phase_run[uvm_phase];

  class leaf extends uvm_component;

    time delay;
    time maxdelay;
    time main_start_time ;
    time shutdown_start_time ;
    time r2e_delay;
    time ended[uvm_phase] ;
    uvm_phase prev_phase ;

    function new(string name, uvm_component parent);
      super.new(name,parent);
    endfunction

    function void phase_started(uvm_phase phase) ;
       `uvm_info("STARTED", {"-------------- Starting phase ",phase.get_name()," --------------"},UVM_NONE)
       if (prev_phase != null && $time != ended[prev_phase]) begin
          failed = 1 ;
          `uvm_error("DEAD_TIME","Phase not starting concurrent with previous phase ending");
       end
    endfunction
    function void phase_ready_to_end(uvm_phase phase) ;
       `uvm_info("READY2END", {"-------------- Ready to end phase ",phase.get_name()," --------------"},UVM_NONE)
       if (phase.get_name() == "main" && phase.get_ready_to_end_count() == 1 && r2e_delay != 0) begin
          fork 
             begin
                phase.raise_objection(this);
                #r2e_delay;
                ended[phase] = $time ;
                phase.drop_objection(this);
             end
          join_none
       end
       else begin
          ended[phase] = $time ;
       end
       prev_phase = phase ;
    endfunction
    function void phase_ended(uvm_phase phase) ;
       `uvm_info("ENDED", {"-------------- Ending phase ",phase.get_name()," --------------"},UVM_NONE)
       if (phase.get_name() == "main") begin 
          //reset the ended time because we have an extra delay in main ready_to_end
          ended[phase] = $time;
       end
    endfunction

    `TASK(reset,delay,0)
    `TASK(main,delay,main_start_time)
    `TASK(shutdown,delay,shutdown_start_time)
    `TASK(run,maxdelay,0)

    function void extract_phase(uvm_phase phase);
      if (get_name() == "l1") return;
      phase_run[uvm_extract_phase::get()] = 1;
      `uvm_info("EXTRACT", "Starting Extract", UVM_NONE)
      if($time != maxdelay)  begin
        failed = 1;
        `uvm_error("extract", $sformatf("Expected extract start time of %0t",maxdelay))
      end
      `uvm_info("EXTRACT", "Ending Extract", UVM_NONE)
    endfunction

  endclass

  class test extends uvm_component;
    leaf l1, l2; 
    `uvm_component_utils(test)
    function new(string name, uvm_component parent);
      super.new(name,parent);
      l1 = new("l1", this);
      l2 = new("l2", this);
      l1.delay = 150;
      l2.delay = 300; 
      l1.main_start_time = 300;
      l2.main_start_time = 300 ;
      l1.shutdown_start_time = 700 ; // 300 (reset) + 300 (main) + 100 (main r2e)
      l2.shutdown_start_time = 700 ; // 300 (reset) + 300 (main) + 100 (main r2e)
      l1.r2e_delay = 0;
      l2.r2e_delay = 100 ;
      // maxdelay = max(5*l1.delay,5*l2.delay)
      // l1 won't check maxdelay in extract phase;
      // make it different so 'run' ends at different times
      l1.maxdelay = 1000;
      l2.maxdelay = 1500;
    endfunction
    function void connect_phase(uvm_phase phase);
      uvm_domain domain1 = new("domain1");
      uvm_domain domain2 = new("domain2");
      l1.set_domain(domain1);
      l2.set_domain(domain2);
      domain1.sync(domain2);
    endfunction
    function void report_phase(uvm_phase phase);
      phase_run[uvm_report_phase::get()] = 1;
      if(phase_run.num() != 6) begin
        failed = 1;
        `uvm_error("NUMPHASES", $sformatf("Expected 6 phases, got %0d", phase_run.num()))
      end
      if(failed) $display("*** UVM TEST FAILED ***");
      else $display("*** UVM TEST PASSED ***");
    endfunction
  endclass

  initial run_test();

endmodule
