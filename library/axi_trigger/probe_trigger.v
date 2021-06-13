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

module probe_trigger #(
  parameter  [ 9:0]  DW = 10'd32) (

  input              clk,
  input              rst,

  input              valid,

  input  [DW-1 : 0]  current_data,
  input  [DW-1 : 0]  limit,

  input    [31:0]    hysteresis,

  // masks 
  input  [DW-1 : 0]  edge_detect_enable,
  input  [DW-1 : 0]  rise_edge_enable,
  input  [DW-1 : 0]  fall_edge_enable,
  input  [DW-1 : 0]  low_level_enable,
  input  [DW-1 : 0]  high_level_enable,

  // condition for internal trigger
  // OR(0) / AND(1): the internal trigger condition
  input              trigger_int_cond,

  // condition for the internal analog triggering;
  // comparison between the probe and the limit
  // 0 - lower than the limit 
  // 1 - higher than the limit
  // 2 - passing through high limit
  // 3 - passing through low limit 
  input    [ 1:0]    trigger_adc_rel,

  // relationship between analog and digital trigger (on all probes)
  // 0 - continuous triggering
  // 1 - digital triggering 
  // 2 - analog triggering 
  // 3 - reserved
  // 4 - dac OR adc triggering 
  // 5 - dac AND adc triggering 
  // 6 - dac XOR adc triggering 
  // 7 - option 4 negated
  // 8 - option 5 negated
  // 9 - option 6 negated
  input    [ 3:0]    adc_dig_trigger_rel,

  output             trigger_out
);

  wire               trigger_out_adc;
  wire               trigger_out_dac;
  
  reg    [DW-1 : 0]  prev_data;
  
  reg                int_trigger_active;
  reg                trigger_out_int;
  // ---------------------------------------------------------------------------

  // signal name changes 
  assign trigger_out = trigger_out_int;


  // delay signals 
  always @ (posedge clk) begin
    if (rst == 1'b1) begin
      prev_data <= 'b0;
    end else begin
      if (valid == 1'b1) begin
        prev_data <= current_data;
      end
    end
  end
  
  
  // check relationship between analog and digital trigger
  always @ (*) begin
    case (adc_dig_trigger_rel[3:0])
      4'd0: trigger_out_int = 1'b1;
      4'd1: trigger_out_int = trigger_out_dac;
      4'd2: trigger_out_int = trigger_out_adc;
      4'd3: trigger_out_int = 1'b0; // reserved
      4'd4: trigger_out_int = trigger_out_dac | trigger_out_adc;
      4'd5: trigger_out_int = trigger_out_dac & trigger_out_adc;
      4'd6: trigger_out_int = trigger_out_dac ^ trigger_out_adc;
      4'd7: trigger_out_int = ~(trigger_out_dac | trigger_out_adc);
      4'd8: trigger_out_int = ~(trigger_out_dac & trigger_out_adc);
      4'd9: trigger_out_int = ~(trigger_out_dac ^ trigger_out_adc);
      default: trigger_out_int = 1'b0; // disable
    endcase
  end
  
  // digital trigger
  digital_trigger #(
    .DW (DW)
  ) digital_data_triggering (
    .clk (clk),
    .rst (rst),
    .current_data (current_data),
    .prev_data(prev_data),
    .valid (valid),
    .edge_detect_enable (edge_detect_enable),
    .rise_edge_enable (rise_edge_enable),
    .fall_edge_enable (fall_edge_enable),
    .low_level_enable (low_level_enable),
    .high_level_enable (high_level_enable),
    .trigger_int_cond (trigger_int_cond),
    .trigger_out (trigger_out_dac)
  );
  
  
  // adc trigger
  adc_trigger #(
    .DW (DW)
  ) analog_data_triggering (
    .clk (clk),
    .rst (rst),
    .data (current_data),
    .limit (limit),
    .hysteresis (hysteresis),
    .valid (valid),
    .trigger_adc_rel (trigger_adc_rel[1 : 0]),
    .trigger_out (trigger_out_adc)
  );
endmodule

// ***************************************************************************
// ***************************************************************************