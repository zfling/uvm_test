//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
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

`ifndef XBUS_DEMO_TB_SV
`define XBUS_DEMO_TB_SV

`include "xbus_demo_scoreboard.sv"
`include "xbus_master_seq_lib.sv"
`include "xbus_obj_seq_lib.sv"
`include "xbus_slave_seq_lib.sv"

//------------------------------------------------------------------------------
//
// CLASS: xbus_demo_tb
//
//------------------------------------------------------------------------------

class xbus_demo_tb extends uvm_env;

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils(xbus_demo_tb)

  // xbus environment
  xbus_env xbus0;

  // Scoreboard to check the memory operation of the slave.
  xbus_demo_scoreboard scoreboard0;

  // new
  function new (string name, uvm_component parent=null);
    super.new(name, parent);
    uvm_default_printer = uvm_default_tree_printer;
  endfunction : new

  // build
  virtual function void build(); 
    super.build();
    uvm_config_int::set(this, "xbus0", "num_masters", 1);
    uvm_config_int::set(this, "xbus0", "num_slaves", 1);
    xbus0 = xbus_env::type_id::create("xbus0", this);
    scoreboard0 = xbus_demo_scoreboard::type_id::create("scoreboard0", this);
  endfunction : build

  function void connect();
    // Connect slave0 monitor to scoreboard
    xbus0.slaves[0].monitor.item_collected_port.connect(
      scoreboard0.item_collected_export);
    // Assign interface for xbus0
    xbus0.assign_vi(xbus_tb_top.xi0);
    set_report_id_action_hier("xbus_bus_monitor",UVM_NO_ACTION);
  endfunction : connect

  function void end_of_elaboration();
    // Set up slave address map for xbus0 (basic default)
    xbus0.set_slave_address_map("slaves[0]", 0, 16'hffff);
  endfunction : end_of_elaboration

  function void start_of_simulation();
    uvm_test_done.set_drain_time(this, 200);
  endfunction

endclass : xbus_demo_tb

`endif // XBUS_DEMO_TB_SV

