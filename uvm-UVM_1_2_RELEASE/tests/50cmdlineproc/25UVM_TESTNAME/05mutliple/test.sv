//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
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
//------------------------------------------------------------------------------

program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class test extends uvm_test;

   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   function void start_of_simulation();
     uvm_cmdline_processor clp;
     string testname_matches[$];
     string tool, version;
     bit add_em = 0;
     clp = uvm_cmdline_processor::get_inst();
     tool = clp.get_tool_name();
     version = clp.get_tool_version();
     $display("Tool: %s, Version : %s", tool, version);
     void'(clp.get_arg_matches("+UVM_TESTNAME=", testname_matches));
     $display("testname_matches size : %0d", testname_matches.size());
     for(int i = 0; i < testname_matches.size(); i++) begin
       $display("testname_matches[%0d]: %0s", i, testname_matches[i]);
     end
     $display("Doing +UVM_TESTNAME= match size check");
     if(testname_matches.size() != 4) begin
       $display("Only %0d UVM_TESTNAME plusargs found. Expected 4.",testname_matches.size());
       pass_the_test = pass_the_test & 0;
     end
     else
       $display("  Correct number of +UVM_TESTNAME= values found");
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase.drop_objection(this);
   endtask

   virtual function void report();
     uvm_report_server rs = uvm_report_server::get_server();
     if(rs.get_id_count("MULTTST") != 1)
       pass_the_test = pass_the_test & 0;
     if(pass_the_test)
       $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
