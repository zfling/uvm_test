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

`ifndef SIMPLE_SEQUENCER_SV
`define SIMPLE_SEQUENCER_SV


//------------------------------------------------------------------------------
//
// CLASS: simple_sequencer
//
// declaration
//------------------------------------------------------------------------------

class simple_sequencer extends uvm_sequencer #(simple_item);

  `uvm_component_utils(simple_sequencer)

  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

endclass : simple_sequencer


`endif // SIMPLE_SEQUENCER_SV
