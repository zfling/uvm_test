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

// This test needs lots of messaging and checks for correct actions.

class test extends uvm_test;

   bit pass_the_test = 1;

   `uvm_component_utils(test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("A", "A Info", UVM_NONE)
      `uvm_warning("B", "B Warning")
      `uvm_error("C", "C Error")
      `uvm_fatal("D", "D Fatal")
      #1000;
      phase.drop_objection(this);
   endtask

   virtual function void report();
     uvm_report_server rs = uvm_report_server::get_server();
     if((rs.get_id_count("A") == 0) && (rs.get_id_count("B") == 0) && 
       (rs.get_id_count("C") == 0) && (rs.get_id_count("D") == 0))
       $write("** UVM TEST PASSED **\n");
   endfunction

endclass


initial
  begin
     run_test();
  end

endprogram
