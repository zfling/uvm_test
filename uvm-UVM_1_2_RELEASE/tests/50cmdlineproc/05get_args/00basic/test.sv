//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
//   Copyright 2011 Cadence Design Systems, Inc.
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

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void start_of_simulation();
     uvm_cmdline_processor clp;
     string raw_args[$];
     string tool, version;
     bit add_em = 0;
     clp = uvm_cmdline_processor::get_inst();
     tool = clp.get_tool_name();
     version = clp.get_tool_version();
     $display("Tool: %s, Version : %s", tool, version);
     clp.get_args(raw_args);
     $display("raw_args size : %0d", raw_args.size());
     for(int i = 0; i < raw_args.size(); i++) begin
       $display("raw_args[%0d]: %0s", i, raw_args[i]);
     end
     case (tool)
       "Chronologic Simulation VCS Release " : begin
         $display("Doing VCS checks");
         if(raw_args.size() != 12)
           pass_the_test = pass_the_test & 0;
         else
           $display("  Correct number of arguments found");
       end
       "ncsim","ncsim(64)" : begin
         $display("Doing IUS checks");
         if(!(raw_args.size() inside {16,17}) ) begin
           $display("  Incorrect number of arguments %0d found (expected 16|17)", raw_args.size());
           pass_the_test = pass_the_test & 0;
         end
         else
           $display("  Correct number of arguments found");
       end
       "ModelSim for Questa ",
       "ModelSim for Questa",
       "ModelSim for Questa-64",
       "ModelSim SE",
       "ModelSim SE-64": begin
         $display("Doing Questa checks");
         if(raw_args.size() != 16) begin
           $display("  Incorrect number of arguments %0d found (expected 16)", raw_args.size());
           pass_the_test = pass_the_test & 0;
         end
         else
           $display("  Correct number of arguments found");
       end
       default : begin
         $display("unknown tool: '%s'",tool);
         pass_the_test = pass_the_test & 0;
       end
     endcase
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase.drop_objection(this);
   endtask

   virtual function void report();
     if(pass_the_test)
       $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
