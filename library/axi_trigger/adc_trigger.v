// ***************************************************************************
// ***************************************************************************
// Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module adc_trigger #(
  parameter  [ 9:0]  DW = 10'd32) (
  
  input              clk,
  input              rst,
  
  input  [DW-1 : 0]  probe,
  input  [DW-1 : 0]  limit,
  
  input              valid,
  
  // condition for the internal analog triggering;
  // comparison between the probe and the limit
  // 0 - lower than the limit 
  // 1 - higher than the limit
  // 2 - passing through high limit
  // 3 - passing through low limit 
  input   [ 1:0]    trigger_analog_rel,
  
  output            trigger_out
);
  
  reg               int_trigger_active;
  reg               lower;
  reg               higher; // ~lower
  reg               passing_high;
  reg               passing_low;
  
  // signals from above delayed with 1 clock cycle
  reg               lower_m;
  reg               higher_m; // ~lower_m
  reg               passing_high_m;
  reg               passing_low_m;
  // ---------------------------------------------------------------------------
	
  // signal name changes 
  assign trigger_out_analog = int_trigger_active;
  
  // compare data with limit 
  always @ (posedge clk) begin
    if (rst == 1'b1) begin
	  lower        <= 1'b0;
	  higher       <= 1'b0;
	  passing_high <= 1'b0;
	  passing_low  <= 1'b0;
	  
	  lower_m        <= 1'b0;
	  higher_m       <= 1'b0;
	  passing_high_m <= 1'b0;
	  passing_low_m  <= 1'b0;
	end else begin
	  lower        <= ((probe <= limit) ? 1'b1 : 1'b0);
	  higher       <= ~lower;
	  passing_high <= 1'b0;
	  passing_low  <= 1'b0;
    end
  end
  
  // add comparison
  
  
  // check relationship between internal and external trigger
  always @ (*) begin
    case (trigger_analog_rel[1 : 0])
      2'd0: int_trigger_active = lower;
      2'd1: int_trigger_active = higher;
      2'd2: int_trigger_active = passing_high;
      2'd3: int_trigger_active = passing_low;
      default: int_trigger_active = 1'b0;
    endcase
  end
  
endmodule

// ***************************************************************************
// ***************************************************************************
