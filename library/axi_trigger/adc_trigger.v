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
  parameter  [ 9:0]  DW = 10'd16) (

  input              clk,
  input              rst,

  input              selected,

  input  [DW-1 : 0]  data,
  input  [DW-1 : 0]  limit,
  input    [31:0]    hysteresis,


  // condition for the internal analog triggering;
  // comparison between the data (probe) and the limit
  // 0 - lower than the limit 
  // 1 - higher than the limit
  // 2 - passing through high limit
  // 3 - passing through low limit 
  input   [ 1:0]    trigger_adc_rel,

  output            trigger_out
);
  // internal signals in 2's complement
  wire signed [DW-1 : 0] data_comp;
  wire signed [DW-1 : 0] limit_comp;

  reg               int_trigger_active;

  reg               comp_high;
  reg               old_comp_high;   // t + 1 version of comp_high

  reg               hyst_high_limit_pass; // valid hysteresis range on passthrough high trigger limit
  reg               hyst_low_limit_pass; // valid hysteresis range on passthrough low trigger limit

  wire              comp_low;

  reg signed [DW-1:0] hyst_high_limit;
  reg signed [DW-1:0] hyst_low_limit;
  reg               passthrough_high; // trigger when rising through the limit
  reg               passthrough_low;  // trigger when falling thorugh the limit
  // ---------------------------------------------------------------------------

  assign data_comp = data[DW-1:0];
  assign limit_comp = limit[DW-1:0];
  
  assign comp_low = !comp_high;
  
  // signal name changes 
  assign trigger_out = int_trigger_active;
  
  
  // check if internal trigger is active
  always @(*) begin
    case(trigger_adc_rel[1:0])
      2'h0: int_trigger_active = comp_low;
      2'h1: int_trigger_active = comp_high;
      2'h2: int_trigger_active = passthrough_high;
      2'h3: int_trigger_active = passthrough_low;
      default: int_trigger_active = comp_low;
    endcase
  end
  
  
  // compare data 
  always @ (posedge clk) begin
    if (rst == 1'b1) begin
      comp_high <= 1'b0;
      old_comp_high <= 1'b0;
      passthrough_high <= 1'b0;
      passthrough_low <= 1'b0;
      hyst_low_limit  <= {DW{1'b0}};
      hyst_high_limit <= {DW{1'b0}};
      hyst_low_limit_pass <= 1'b0;
      hyst_high_limit_pass <= 1'b0;
    end else begin
      if (selected == 1'b1) begin
        hyst_high_limit <= limit_comp + hysteresis[DW-1:0];
        hyst_low_limit  <= limit_comp - hysteresis[DW-1:0];

        // with limit
        //comp_high <= (data_comp >= limit_comp) ? 1'b1 : 1'b0;
		if (data_comp >= limit_comp) begin
          comp_high <= 1'b1;
        end else begin
          comp_high <= 1'b0;
        end

        // with hysteresis range
        if (data_comp > hyst_high_limit) begin
          hyst_low_limit_pass <= 1'b1;
        end else begin
          hyst_low_limit_pass <= (passthrough_low) ? 1'b0 : hyst_low_limit_pass;
        end
        if (data_comp < hyst_low_limit) begin
          hyst_high_limit_pass <= 1'b1;
        end else begin
          hyst_high_limit_pass <= passthrough_high ? 1'b0 : hyst_high_limit_pass;
        end

        old_comp_high <= comp_high;
        passthrough_high <= !old_comp_high & comp_high & hyst_high_limit_pass;
        passthrough_low <= old_comp_high & !comp_high & hyst_low_limit_pass;
      end
    end
  end
endmodule

// ***************************************************************************
// ***************************************************************************
