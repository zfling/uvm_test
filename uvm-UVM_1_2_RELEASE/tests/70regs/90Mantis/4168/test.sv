// 
// -------------------------------------------------------------
//    Copyright 2012 Synopsys, Inc.
//    All Rights Reserved Worldwide
// 
//    Licensed under the Apache License, Version 2.0 (the
//    "License"); you may not use this file except in
//    compliance with the License.  You may obtain a copy of
//    the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in
//    writing, software distributed under the License is
//    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//    CONDITIONS OF ANY KIND, either express or implied.  See
//    the License for the specific language governing
//    permissions and limitations under the License.
// -------------------------------------------------------------
// 

`include "uvm_macros.svh"


module dut();

bit [31:0] r1;

function void reset();
   r1 = 0;
endfunction

initial reset();

endmodule


program test;

import uvm_pkg::*;


class reg1 extends uvm_reg;
   `uvm_object_utils(reg1)

   uvm_reg_field data;

   function new(string name = "reg1");
      super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   virtual function void build();
      data = uvm_reg_field::type_id::create("data",,get_full_name());
      data.configure(this, 32,  0, "RW", 0,   'h0, 1, 0, 1);
   endfunction
endclass


class my_dut extends uvm_reg_block;
   `uvm_object_utils(my_dut)

   reg1 r1;
   
   function new(string name = "my_dut");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   function void build();
      default_map = create_map("", 'h0, 1, UVM_LITTLE_ENDIAN);
      
      r1 = reg1::type_id::create("r1",,get_full_name());
      r1.configure(this, null, "");
      r1.build();

      default_map.add_reg(r1, 0, "RO");
   endfunction
endclass


`include "reg_agent.sv"

class dut_rw;
   static task rw(reg_rw rw);
      casez (rw.addr)
       'h0000:
          if (rw.read) rw.data = dut.r1[7:0];
       'h0001:
          if (rw.read) rw.data = dut.r1[15:8];
       'h0002:
          if (rw.read) rw.data = dut.r1[23:16];
       'h0003:
          if (rw.read) rw.data = dut.r1[31:24];
      endcase
      #10;
      $write("DUT: %0s 'h%h @ 'h%h...\n", (rw.read) ? "read" : "wrote", rw.addr[7:0], rw.data[7:0]);
   endtask
endclass


class tb_env extends uvm_env;

   `uvm_component_utils(tb_env)

   my_dut             regmodel;
   reg_agent#(dut_rw) bus;
   uvm_reg_predictor#(reg_rw) bus2reg_predictor;

   function new(string name = "tb_env", uvm_component parent=null);
      super.new(name, parent);
   endfunction: new

   virtual function void build();
      regmodel = my_dut::type_id::create("regmodel");
      regmodel.build();
      regmodel.lock_model();

      bus = reg_agent#(dut_rw)::type_id::create("bus", this);
      bus2reg_predictor = new("bus2reg_predictor", this);

      regmodel.set_hdl_path_root("dut");
  endfunction: build

   virtual function void connect();
      reg2rw_adapter reg2rw  = new("reg2rw");
      regmodel.default_map.set_sequencer(bus.sqr, reg2rw);
      bus2reg_predictor.map = regmodel.default_map;
      bus2reg_predictor.adapter = reg2rw;
      regmodel.default_map.set_auto_predict(0);
      bus.mon.ap.connect(bus2reg_predictor.bus_in);
   endfunction

endclass


class test extends uvm_test;
   uvm_reg_sequence seq;
   tb_env env;

   `uvm_component_utils(test)

   function new(string name = "tb_test", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = new("env",this);
      seq = uvm_reg_bit_bash_seq::type_id::create("seq", this);
   endfunction

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      seq.model = env.regmodel;
   endfunction
  
   virtual task run_phase(uvm_phase phase);
     phase.raise_objection(this, "Waiting for sequence to finish");
     seq.set_starting_phase(phase);
     seq.start(env.bus.sqr);
     `uvm_info(get_type_name(), "End of main phase", UVM_HIGH)
     phase.drop_objection(this);
   endtask

   function void final_phase(uvm_phase phase);
      uvm_coreservice_t cs_;
      uvm_report_server svr;
      cs_ = uvm_coreservice_t::get();
      svr = cs_.get_report_server();

      if (svr.get_severity_count(UVM_FATAL) +
          svr.get_severity_count(UVM_ERROR) == 0)
         $write("** UVM TEST PASSED **\n");
      else
         $write("!! UVM TEST FAILED !!\n");
   endfunction
   
endclass

initial run_test();

endprogram
