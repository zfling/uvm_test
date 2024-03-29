//---------------------------------------------------------------------- 
//   Copyright 2010 Synopsys, Inc. 
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


program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_catcher extends uvm_report_catcher;
   static int seen = 0;
   virtual function action_e catch();
      $write("Caught a message...\n");
      seen++;
      return CAUGHT;
   endfunction
endclass

class test extends uvm_test;

   bit pass = 1;
  my_catcher ctchr = new();
  my_catcher ctchr1 = new();
  my_catcher ctchr2 = new() ;
  my_catcher ctchr3= new() ;
  
   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
 
     phase.raise_objection(this);
      
     $write("UVM TEST - WARNING expected since re_registering a default catcher\n");
         
     //add_report_default_catcher(uvm_report_catcher catcher, uvm_apprepend ordering = UVM_APPEND);
     uvm_report_cb::add(null,ctchr);
     uvm_report_cb::add(null,ctchr);
  
     uvm_report_cb::delete(null,ctchr);
  
     phase.drop_objection(this);
  
   endtask

   virtual function void report();
      
      $write("** UVM TEST PASSED **\n");
   endfunction
endclass


initial
  begin
     run_test();
  end

endprogram
