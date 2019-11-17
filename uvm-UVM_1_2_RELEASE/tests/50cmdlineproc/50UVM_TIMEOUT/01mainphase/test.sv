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

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   task reset_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10;
      phase.drop_objection(this);
   endtask

   task configure_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10;
      phase.drop_objection(this);
   endtask

   task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #30; // we expect a fail during this due to command line setting of timeout to 20
      phase.drop_objection(this);
   endtask

   task shutdown_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10;
      phase.drop_objection(this);
   endtask

endclass


initial
  begin
     run_test();
  end

final
  begin
    if ($time == 20) begin // expect the test to complete at the timeout value of 20
      $write("UVM TEST EXPECT 1 UVM_FATAL\n");
      $write("** UVM TEST PASSED **\n");
    end
  end

endprogram
