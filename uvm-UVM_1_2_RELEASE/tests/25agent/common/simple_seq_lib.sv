//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
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

`ifndef SIMPLE_SEQ_LIB_SV
`define SIMPLE_SEQ_LIB_SV

//------------------------------------------------------------------------------
//
// SEQUENCE: simple_seq_do
//
//------------------------------------------------------------------------------

class simple_seq_do extends uvm_sequence #(simple_item);

  function new(string name="simple_seq_do");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction
  
  `uvm_object_utils(simple_seq_do)

  virtual task body();
    `uvm_info(get_name(), $sformatf("In body() of %s", get_name()),UVM_MEDIUM)
    `uvm_do(req)
  endtask
  
endclass : simple_seq_do


//------------------------------------------------------------------------------
//
// SEQUENCE: simple_seq_do_with
//
//------------------------------------------------------------------------------

class simple_seq_do_with extends uvm_sequence #(simple_item);

  function new(string name="simple_seq_do_with");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction
  
  `uvm_object_utils(simple_seq_do_with)

  virtual task body();
    `uvm_info(get_name(), $sformatf("In body() of %s", get_name()),UVM_MEDIUM)
    `uvm_do_with(req, { req.addr == 16'h0123; req.data == 16'h0456; } )
  endtask
  
endclass : simple_seq_do_with


//------------------------------------------------------------------------------
//
// SEQUENCE: simple_seq_do_with_vars
//
//------------------------------------------------------------------------------

class simple_seq_do_with_vars extends uvm_sequence #(simple_item);

  function new(string name="simple_seq_do_with_vars");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction
  
  `uvm_object_utils(simple_seq_do_with_vars)    

  rand int unsigned start_addr;
    constraint c1 { start_addr < 16'h0200; }
  rand int unsigned start_data;
    constraint c2 { start_data < 16'h0100; }

  virtual task body();
    `uvm_info(get_name(), $sformatf("In body() of %s", get_name()),UVM_MEDIUM)
    `uvm_do_with(req, { req.addr == start_addr; req.data == start_data; } )
  endtask
  
endclass : simple_seq_do_with_vars


//------------------------------------------------------------------------------
//
// SEQUENCE: simple_seq_sub_seqs
//
//------------------------------------------------------------------------------

class simple_seq_sub_seqs extends uvm_sequence #(simple_item);

  function new(string name="simple_seq_sub_seqs");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction
  
  `uvm_object_utils(simple_seq_sub_seqs)    

  simple_seq_do seq_do;
  simple_seq_do_with seq_do_with;
  simple_seq_do_with_vars seq_do_with_vars;

  virtual task body();
    `uvm_info(get_name(), $sformatf("In body() of %s", get_name()),UVM_MEDIUM)
    #100;
    `uvm_do(seq_do)
    #100;
    `uvm_do(seq_do_with)
    #100;
    `uvm_do_with(seq_do_with_vars, { seq_do_with_vars.start_addr == 16'h0003; seq_do_with_vars.start_data == 16'h0009; } )
  endtask
  
endclass : simple_seq_sub_seqs


//------------------------------------------------------------------------------
//
// SEQUENCE: simple_triple_do
//
//------------------------------------------------------------------------------

class simple_triple_do extends uvm_sequence #(simple_item);

  function new(string name="simple_triple_do");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction
  
  `uvm_object_utils(simple_triple_do)

  virtual task body();
    `uvm_info(get_name(), $sformatf("In body() of %s", get_name()),UVM_MEDIUM)
    repeat (3) begin
      `uvm_do(req)
    end
  endtask
  
endclass : simple_triple_do


`endif // SIMPLE_SEQ_LIB_SV

