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

//////////////distrib/src/base/uvm_object_globals.svh////////////////////////////
//////// uvm_severity   
////////
///////typedef enum uvm_severity
///////{
///////  UVM_INFO,
///////  UVM_WARNING,
///////  UVM_ERROR,
///////  UVM_FATAL
/////////} uvm_severity;
//////////////////////////


///////uvm_misc.svh////////////
/////////
////// typedef enum {UVM_APPEND, UVM_PREPEND} uvm_apprepend;
///////////////////////////////
///////////////////////////////



program top;

import uvm_pkg::*;
`include "uvm_macros.svh"

class my_catcher_info extends uvm_report_catcher;
  function new(string name); super.new(name); endfunction 
  virtual function action_e catch();
      if(get_name() != get_id()) return THROW;
      if(get_severity() != UVM_INFO) return THROW;
  $write("Info Catcher Caught a message...\n");
  //uvm_report_info(string id, string message, int verbosity, string fname = "", int line = 0 );
  uvm_report_info("INFO CATCHER", "From my_catcher_info catch()", UVM_MEDIUM,`uvm_file, `uvm_line);
  return THROW;
  endfunction
endclass

  class my_catcher_warning extends uvm_report_catcher;
   
  function new(string name); super.new(name); endfunction 
  virtual function action_e catch();
      if(get_name() != get_id()) return THROW;
      if(get_severity() != UVM_WARNING) return THROW;
  $write("Warning Catcher Caught a message...\n");
  //uvm_report_warning(string id, string message, int verbosity, string fname = "", int line = 0 );
  uvm_report_warning("WARNING CATCHER","From my_catcher_warning catch()" , UVM_MEDIUM , `uvm_file, `uvm_line); 
  return THROW;
  endfunction
  endclass
  
  class my_catcher_error extends uvm_report_catcher;
  
  function new(string name); super.new(name); endfunction 
  virtual function action_e catch();
      if(get_name() != get_id()) return THROW;
      if(get_severity() != UVM_ERROR) return THROW;
  $write("Error Catcher Caught a message...\n");
  //uvm_report_error(string id, string message, int verbosity, string fname = "", int line = 0 );
  uvm_report_error("ERROR CATCHER ","From my_catcher_error catch()", UVM_MEDIUM , `uvm_file, `uvm_line);
  return THROW;
  endfunction
  endclass
  
  class my_catcher_fatal extends uvm_report_catcher;
  function new(string name); super.new(name); endfunction 
  virtual function action_e catch();
      if(get_name() != get_id()) return THROW;
      if(get_severity() != UVM_FATAL) return THROW;
      $write("Fatal Catcher Caught a Fatal message...\n");
  //uvm_report_fatal(string id, string message, int verbosity, string fname = "", int line = 0 );
  uvm_report_fatal("FATAL CATCHER", "From my_catcher_fatal catch()", UVM_MEDIUM , `uvm_file, `uvm_line );
  return THROW;
   endfunction
  endclass

  
  

class test extends uvm_test;


   `uvm_component_utils(test)

   function new(string name, uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);

      phase.raise_objection(this);

      $write("UVM TEST - Same catcher type - different IDs\n");
  
        begin
          my_catcher_info ctchr1 = new("Catcher1");
          my_catcher_warning ctchr2 = new("Catcher2");
          my_catcher_error ctchr3 = new("Catcher3");
          my_catcher_fatal ctchr4 = new("Catcher4");
          

          $write("adding a catcher of type my_catcher_info with id of Catcher1\n");
          uvm_report_cb::add(null,ctchr1);
          
          $write("adding a catcher of type my_catcher_warning with id of Catcher2\n");
          uvm_report_cb::add(null,ctchr2);

          $write("adding a catcher of type my_catcher_error with id of Catcher3\n");
          uvm_report_cb::add(null,ctchr3);
          
          $write("adding a catcher of type my_catcher_fatal with id of Catcher4\n");
          uvm_report_cb::add(null,ctchr4);
          
          `uvm_info("Catcher1", "This message is for Catcher1", UVM_MEDIUM);
          `uvm_info("Catcher2", "This message is for Catcher2", UVM_MEDIUM);
          `uvm_info("Catcher3", "This message is for Catcher3", UVM_MEDIUM);
          //`uvm_info("Catcher4", "This message is for Catcher4", UVM_MEDIUM);

          
          `uvm_info("XYZ", "This second message is for No One", UVM_MEDIUM);

          
        end // begin
  

  
      //$write("UVM TEST EXPECT 1 UVM_ERROR\n");
  
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
