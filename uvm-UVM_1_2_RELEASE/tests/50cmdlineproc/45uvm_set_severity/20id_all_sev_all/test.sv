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
      `uvm_warning("A", "A Warning but downgrading to an Info!!!")
      `uvm_error("B", "B Error but downgrading to an Info!!!")
      `uvm_fatal("C", "C Fatal but downgrading to an Info!!!")
      #1000;
      phase.drop_objection(this);
   endtask

   virtual function void report();
     uvm_report_server rs = uvm_report_server::get_server();
     $write("ID A count = %0d\n", rs.get_id_count("A"));
     $write("ID B count = %0d\n", rs.get_id_count("B"));
     $write("ID C count = %0d\n", rs.get_id_count("C"));
     $write("UVM_INFO count = %0d\n", rs.get_severity_count(UVM_INFO));
     $write("UVM_WARNING count = %0d\n", rs.get_severity_count(UVM_WARNING));
     $write("UVM_ERROR count = %0d\n", rs.get_severity_count(UVM_ERROR));
     $write("UVM_FATAL count = %0d\n", rs.get_severity_count(UVM_FATAL));
     if((rs.get_id_count("A") == 1) &&
        (rs.get_id_count("B") == 1) &&
        (rs.get_id_count("C") == 1) &&
        //(rs.get_severity_count(UVM_INFO) == 5) &&
        (rs.get_severity_count(UVM_WARNING) == 0) &&
        (rs.get_severity_count(UVM_ERROR) == 0) &&
        (rs.get_severity_count(UVM_FATAL) == 0))
       $write("** UVM TEST PASSED **\n");
   endfunction

endclass


initial
  begin
     run_test();
  end

endprogram
