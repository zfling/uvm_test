//----------------------------------------------------------------------
//   Copyright 2013 Cadence Design Inc
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
`include "../4478_tracing_factory/uvm_delegate_factory_pkg.sv"

module test;
	import uvm_pkg::*;  
	import uvm_delegate_factory_pkg::*;
    `include "uvm_macros.svh"

	class a extends uvm_component;
		`uvm_component_utils(a)
		function new(string name,uvm_component parent );
			super.new(name,parent);
		endfunction
	endclass

	class b extends a;
		`uvm_component_utils(b)
		function new(string name,uvm_component parent );
			super.new(name,parent);
		endfunction
	endclass

	class c extends a;
		`uvm_component_utils(c)
		function new(string name,uvm_component parent );
			super.new(name,parent);
		endfunction
	endclass

	class uvm_locking_factory extends uvm_delegate_factory;
		bit is_locked;
		virtual function void set_inst_override_by_type (uvm_object_wrapper original_type,
				uvm_object_wrapper override_type,
				string full_inst_path);

			if(is_locked)
				`uvm_error("FACTORY","uvm factory is locked")
			else    
				delegate.set_inst_override_by_type(original_type,override_type,full_inst_path);
		endfunction 

		virtual function void set_inst_override_by_name (string original_type_name,
				string override_type_name,
				string full_inst_path);
			if(is_locked)
				`uvm_error("FACTORY","uvm factory is locked")
			else    
				delegate.set_inst_override_by_name(original_type_name,override_type_name,full_inst_path);
		endfunction

		virtual function void set_type_override_by_type (uvm_object_wrapper original_type,
				uvm_object_wrapper override_type,
				bit replace=1);
			if(is_locked)
				`uvm_error("FACTORY","uvm factory is locked")
			else    
				delegate.set_type_override_by_type(original_type, override_type, replace);
		endfunction


		virtual function void set_type_override_by_name (string original_type_name,
				string override_type_name,
				bit replace=1);
			if(is_locked)
				`uvm_error("FACTORY","uvm factory is locked")
			else    
				delegate.set_type_override_by_name(original_type_name, override_type_name, replace);
		endfunction 
	endclass    

	initial begin
		static uvm_coreservice_t cs_ = uvm_coreservice_t::get();

		uvm_locking_factory f;
		uvm_coreservice_t cs;
		uvm_factory factory;
		cs = uvm_coreservice_t::get();                                                     
		factory = cs.get_factory();
  
		// create new factory
		f = new();
		// set the delegate
		f.delegate=factory;
		// enable new factory
		cs_.set_factory(f);

		// do an override
		a::type_id::set_type_override(b::get_type());

		// lock the factory
		f.is_locked = 1;

		// this should now error
		a::type_id::set_type_override(c::get_type());

		begin
			uvm_report_server svr;
			svr = uvm_report_server::get_server();

			$display("UVM TEST EXPECT 1 UVM_ERROR");

			if (svr.get_id_count("FACTORY")==1 && svr.get_severity_count(UVM_ERROR)==1)
				$write("** UVM TEST PASSED **\n");
			else
				$write("!! UVM TEST FAILED !!\n");
				
			svr.report_summarize();

		end 
	end 

endmodule
