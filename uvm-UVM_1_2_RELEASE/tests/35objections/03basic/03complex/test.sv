//----------------------------------------------------------------------
//   Copyright 2007-2009 Cadence Design Systems, Inc.
//   Copyright 2010 Mentor Graphics Corporation
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

module test;

  // Make simple example for uvm_test_done.

  // This is an example of some of the usages of the objection mechanism.  In
  // this scenario we will have:
  //   1.  A sequence, silly_sequence, that:
  //         a.  when it starts up, raises a test done objection
  //         b.  when it finishes, drops a test done objection
  //         c.  sends 10 packets that are p_sequencer.ipg apart temporally
  //         d.  after 5 packets are sent, it raises 5 item_sent objections
  //   2.  A sequencer that:
  //         a.  is set to start the silly_sequence as the default_sequence
  //         b.  contains a properly called ipg that is initially 100
  //   3.  A driver that just takes the packets and does nothing but keeps
  //       traffic coming (burns #10).
  //   4.  An agent that:
  //         a.  contains the driver and the sequencer
  //         b.  delays the propagation of the drop of test done from
  //             the sequence by #93 (odd on purpose!).
  //   5.  A test that:
  //         a.  contains the agent
  //         b.  changes the agent.sequencer.ipg to 50 after the 5th item_sent
  //             objection is seen from the sequencer.

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Defining an user objection (uvm_test_done is already defined for users)
  uvm_objection item_sent = new("item_sent");

  class simple_item extends uvm_sequence_item;
    `uvm_object_utils(simple_item)
    function new (string name="simple_item");
      super.new(name);
    endfunction : new
  endclass : simple_item

  class simple_sequencer extends uvm_sequencer #(simple_item);
    int ipg = 100;
    `uvm_component_utils(simple_sequencer)
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
  endclass : simple_sequencer

  class simple_seq extends uvm_sequence #(simple_item);
    function new(string name="simple_seq");
      super.new(name);
    endfunction
    `uvm_object_utils(simple_seq)    
    `uvm_declare_p_sequencer(simple_sequencer)    
    virtual task body();
      uvm_domain l_common_domain = uvm_domain::get_common_domain();
      uvm_phase l_run_phase = l_common_domain.find_by_name("run");
      l_run_phase.raise_objection(this);
      p_sequencer.uvm_report_info("SEQ_BODY", "simple_seq body() is starting...", UVM_LOW);
      #50;
      // Raising one uvm_test_done objection
      for (int i = 0; i < 10; i++) begin
        `uvm_do(req)
        if (i == 4) begin
          // Raising five item_sent objections
          item_sent.raise_objection(this, "multi-obj", 5);
        end
        #p_sequencer.ipg;
      end
      l_run_phase.drop_objection(this);
      p_sequencer.uvm_report_info("SEQ_BODY", "simple_seq body() is ending...", UVM_LOW);
    endtask
  endclass : simple_seq

  class simple_driver extends uvm_driver #(simple_item);
    int i = 0;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(simple_driver)
    task run();
      while(1) begin
        seq_item_port.get_next_item(req);
        uvm_report_info("DRV_RUN", $sformatf("driver item %0d...", i), UVM_LOW);
        i++;
        #10;
        seq_item_port.item_done();
      end
    endtask: run
  endclass : simple_driver

  class simple_agent extends uvm_agent;
    simple_sequencer sequencer;
    simple_driver driver;
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(simple_agent)
    function void build();
      super.build();
      sequencer = simple_sequencer::type_id::create("sequencer", this);
      driver = simple_driver::type_id::create("driver", this);
    endfunction
    function void connect();
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction 
    virtual task all_dropped (uvm_objection objection, 
      uvm_object source_obj, string description, int count);
      uvm_domain l_common_domain = uvm_domain::get_common_domain();
      uvm_phase l_run_phase = l_common_domain.find_by_name("run");
      uvm_objection l_run_phase_objection = l_run_phase.get_objection();
      if (objection == l_run_phase_objection) begin
        #93;
      end
    endtask
  endclass : simple_agent

  class test extends uvm_test;
    simple_agent agent;
    bit ipg_set = 0;

    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new
    `uvm_component_utils(test)
    function void build();
      super.build();
      agent = simple_agent::type_id::create("agent", this);
    endfunction
    function void start_of_simulation();
      this.print();
    endfunction
    task run_phase(uvm_phase phase);
      simple_seq l_ss = simple_seq::type_id::create("l_ss", this);
      fork
        l_ss.start(agent.sequencer);
      join_none
    endtask
    function void raised (uvm_objection objection, 
      uvm_object source_obj, string description, int count);
      if (objection == item_sent && item_sent.get_objection_total(this) >= 5) begin
        uvm_report_info("TST_OBJR", "5 item_sents seen, changing ipg", UVM_LOW);
        ipg_set = 1;
        agent.sequencer.ipg = 50;
      end
    endfunction
    function void report();
      if(ipg_set == 0) begin
        $display("** UVM TEST FAILED **"); 
        return;
      end
      if($time != 943)  begin
        $display("** UVM TEST FAILED **"); 
        return;
      end
      
      $display("** UVM TEST PASSED **");
    endfunction
  endclass : test

  initial
    run_test("test");

endmodule
