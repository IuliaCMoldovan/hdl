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

module axi_trigger #(
  parameter   [ 2:0]   NB_SELECTED = 3'd4,
  parameter   [ 9:0]   DW0 = 10'd4,
  parameter   [ 9:0]   DW1 = 10'd4,
  parameter   [ 9:0]   DW2 = 10'd4,
  parameter   [ 9:0]   DW3 = 10'd4) (

  input                clk,
  input                rst,

  input                trigger_ext,

  input  [DW0-1 : 0]   probe0,
  input  [DW1-1 : 0]   probe1,
  input  [DW2-1 : 0]   probe2,
  input  [DW3-1 : 0]   probe3,
  
  output [DW0-1 : 0]   data_out0,
  output [DW1-1 : 0]   data_out1,
  output [DW2-1 : 0]   data_out2,
  output [DW3-1 : 0]   data_out3,

  output    [ 3:0]     out_valids,
  
  output               trigger_out,
  output               clk_out,

  // fifo
  output    [31:0]     fifo_depth,

  // axi interface
  input                s_axi_aclk,
  input                s_axi_aresetn,
  input                s_axi_awvalid,
  input     [ 6:0]     s_axi_awaddr,
  input     [ 2:0]     s_axi_awprot,
  input                s_axi_wvalid,
  input     [31:0]     s_axi_wdata,
  input     [ 3:0]     s_axi_wstrb,
  input                s_axi_bready,
  input                s_axi_arvalid,
  input     [ 6:0]     s_axi_araddr,
  input     [ 2:0]     s_axi_arprot,
  input                s_axi_rready,
  output               s_axi_awready,
  output               s_axi_wready,
  output               s_axi_bvalid,
  output    [ 1:0]     s_axi_bresp,
  output               s_axi_arready,
  output               s_axi_rvalid,
  output    [31:0]     s_axi_rdata,
  output    [ 1:0]     s_axi_rresp
);

  wire [NB_SELECTED-1 : 0] trigger_out_aux;
  
  reg                  trigger_out_reg; 
  reg                  trigger_int;
  
  wire      [ 3:0]     valid_probes;
  // condition for internal trigger
  // bit 3: OR(0) / AND(1): the internal trigger condition, 
  // bits [2:0] - relationship between internal and external trigger
  //     0 - internal trigger only
  //     1 - external trigger only
  //     2 - internal AND external trigger
  //     3 - internal OR external trigger
  //     4 - internal XOR external trigger
  wire      [ 3:0]     triggers_rel;

  // type of triggering to be applied on input 
  // 0 - continuous triggering
  // 1 - analog triggering 
  // 2 - digital triggering 
  wire      [ 1:0]     trigger_type;
  
  // condition for the internal analog triggering,
  // compare between the probe and the limit
  // 0 - lower than the limit 
  // 1 - higher than the limit
  // 2 - passing through high limit
  // 3 - passing through low limit 
  wire      [ 1:0]     trigger_adc_0;
  wire      [ 1:0]     trigger_adc_1;
  wire      [ 1:0]     trigger_adc_2;
  wire      [ 1:0]     trigger_adc_3;
				   
  // masks for data that comes from PROBE 0
  wire   [DW0-1 : 0]   edge_detect_enable_0;
  wire   [DW0-1 : 0]   rise_edge_enable_0;
  wire   [DW0-1 : 0]   fall_edge_enable_0;
  wire   [DW0-1 : 0]   low_level_enable_0;
  wire   [DW0-1 : 0]   high_level_enable_0;

  // masks for data that comes from PROBE 1
  wire   [DW1-1 : 0]   edge_detect_enable_1;
  wire   [DW1-1 : 0]   rise_edge_enable_1;
  wire   [DW1-1 : 0]   fall_edge_enable_1;
  wire   [DW1-1 : 0]   low_level_enable_1;
  wire   [DW1-1 : 0]   high_level_enable_1;

  // masks for data that comes from PROBE 2
  wire   [DW2-1 : 0]   edge_detect_enable_2;
  wire   [DW2-1 : 0]   rise_edge_enable_2;
  wire   [DW2-1 : 0]   fall_edge_enable_2;
  wire   [DW2-1 : 0]   low_level_enable_2;
  wire   [DW2-1 : 0]   high_level_enable_2;

  // masks for data that comes from PROBE 3
  wire   [DW3-1 : 0]   edge_detect_enable_3;
  wire   [DW3-1 : 0]   rise_edge_enable_3;
  wire   [DW3-1 : 0]   fall_edge_enable_3;
  wire   [DW3-1 : 0]   low_level_enable_3;
  wire   [DW3-1 : 0]   high_level_enable_3;

  // limits for analog data to compare with
  wire      [31:0]    limit_0;
  wire      [31:0]    limit_1;
  wire      [31:0]    limit_2;
  wire      [31:0]    limit_3;
  
  // hysteresis values to determine range
  wire      [31:0]    hysteresis_0;
  wire      [31:0]    hysteresis_1;
  wire      [31:0]    hysteresis_2;
  wire      [31:0]    hysteresis_3;


  // internal signals
  wire                up_clk;
  wire                up_rstn;
  wire      [ 4:0]    up_waddr;
  wire      [31:0]    up_wdata;
  wire                up_wack;
  wire                up_wreq;
  wire                up_rack;
  wire      [31:0]    up_rdata;
  wire                up_rreq;
  wire      [ 4:0]    up_raddr;
  
  // inputs delayed with 1 clock cycle
  reg    [DW0-1 : 0]   probe0_d1;
  reg    [DW1-1 : 0]   probe1_d1;
  reg    [DW2-1 : 0]   probe2_d1;
  reg    [DW3-1 : 0]   probe3_d1;
  reg       [15:0]     valid_probes_d1;
  
  // inputs delayed with 2 clock cycles
  reg    [DW0-1 : 0]   probe0_d2;
  reg    [DW1-1 : 0]   probe1_d2;
  reg    [DW2-1 : 0]   probe2_d2;
  reg    [DW3-1 : 0]   probe3_d2;
  reg       [15:0]     valid_probes_d2;
  // ---------------------------------------------------------------------------

  // assign outputs 
  assign out_valids = valid_probes_d2;
  
  
  // add buffer for clock
  ad_data_clk #(
    .SINGLE_ENDED(1)
  ) i_ad_data_clk (
    .clk_in_p (clk),
    .clk (clk_out)
  );

  
  // forward the input data and valid to outputs
  // with 2 clock cycles delay
  always @ (posedge clk) begin
    probe0_d1 <= probe0;
    probe1_d1 <= probe1;
    probe2_d1 <= probe2;
    probe3_d1 <= probe3;
    valid_probes_d1 <= valid_probes;
  end
  always @ (posedge clk) begin
    probe0_d2 <= probe0_d1;
    probe1_d2 <= probe1_d1;
    probe2_d2 <= probe2_d1;
    probe3_d2 <= probe3_d1;
    valid_probes_d2 <= valid_probes_d1;
  end
  
  assign data_out0 = probe0_d2;
  assign data_out1 = probe1_d2;
  assign data_out2 = probe2_d2;
  assign data_out3 = probe3_d2;
  
  // signal name changes
  assign trigger_out = trigger_out_reg;
 
 
  // determine if internal trigger occured
  // condition on each probe trigger
  always @ (*) begin
      // OR
    case (triggers_rel[3]) 
      // consider only probes that are selected for monitoring
      0: trigger_int = | (trigger_out_aux & valid_probes);
      // AND
      1: trigger_int = & (trigger_out_aux | ~valid_probes); 
      default: trigger_int = 1'b0;
    endcase
  end
  
  
  // check relationship between internal and external trigger
  always @ (posedge clk) begin
    case (triggers_rel[2:0])
      3'd0: trigger_out_reg = trigger_int;
      3'd1: trigger_out_reg = trigger_ext;
      3'd2: trigger_out_reg = trigger_int & trigger_ext;
      3'd3: trigger_out_reg = trigger_int | trigger_ext;
      3'd4: trigger_out_reg = trigger_int ^ trigger_ext;
      3'd7: trigger_out_reg = 1'b0; // trigger disable
      default: trigger_out_reg = 1'b0;
    endcase
  end
   
   
  // probe 0 
  probe_trigger #(
    .DW (DW0)
  ) trigger_probe0 (
    .clk (clk),
    .rst (rst),
    .valid (valid_probes[0]),
    .current_data (probe0),
    .limit (limit_0[DW0-1:0]),
    .hysteresis (hysteresis_0),
    .edge_detect_enable (edge_detect_enable_0),
    .rise_edge_enable (rise_edge_enable_0),
    .fall_edge_enable (fall_edge_enable_0),
    .low_level_enable (low_level_enable_0),
    .high_level_enable (high_level_enable_0),
    .trigger_int_cond (triggers_rel[3]),
    .trigger_adc_rel (trigger_adc_0),
    .trigger_type (trigger_type),
    .trigger_out (trigger_out_aux[0])
  );
 
  // probe 1 
  probe_trigger #(
    .DW (DW1)
  ) trigger_probe1 (
    .clk (clk),
    .rst (rst),
    .valid (valid_probes[1]),
    .current_data (probe1),
    .limit (limit_1[DW1-1:0]),
    .hysteresis (hysteresis_1),
    .edge_detect_enable (edge_detect_enable_1),
    .rise_edge_enable (rise_edge_enable_1),
    .fall_edge_enable (fall_edge_enable_1),
    .low_level_enable (low_level_enable_1),
    .high_level_enable (high_level_enable_1),
    .trigger_int_cond (triggers_rel[3]),
    .trigger_adc_rel (trigger_adc_1),
    .trigger_type (trigger_type),
    .trigger_out (trigger_out_aux[1])
  );

  // probe 2 
  probe_trigger #(
    .DW (DW2)
  ) trigger_probe2 (
    .clk (clk),
    .rst (rst),
    .valid (valid_probes[2]),
    .current_data (probe2),
    .limit (limit_2[DW2-1:0]),
    .hysteresis (hysteresis_2),
    .edge_detect_enable (edge_detect_enable_2),
    .rise_edge_enable (rise_edge_enable_2),
    .fall_edge_enable (fall_edge_enable_2),
    .low_level_enable (low_level_enable_2),
    .high_level_enable (high_level_enable_2),
    .trigger_int_cond (triggers_rel[3]),
    .trigger_adc_rel (trigger_adc_2),
    .trigger_type (trigger_type),
    .trigger_out (trigger_out_aux[2])
  );
 
  // probe 3 
  probe_trigger #(
    .DW (DW3)
  ) trigger_probe3 (
    .clk (clk),
    .rst (rst),
    .valid (valid_probes[3]),
    .current_data (probe3),
    .limit (limit_3[DW3-1:0]),
    .hysteresis (hysteresis_3),
    .edge_detect_enable (edge_detect_enable_3),
    .rise_edge_enable (rise_edge_enable_3),
    .fall_edge_enable (fall_edge_enable_3),
    .low_level_enable (low_level_enable_3),
    .high_level_enable (high_level_enable_3),
    .trigger_int_cond (triggers_rel[3]),
    .trigger_adc_rel (trigger_adc_3),
    .trigger_type (trigger_type),
    .trigger_out (trigger_out_aux[3])
  );
  
  
  // signal name changes 
  assign up_clk = s_axi_aclk;
  assign up_rstn = s_axi_aresetn;
  
  
  // regmap
  trigger_ip_regmap i_regmap (
    .clk (clk),
    
    .valid_probes (valid_probes),
    .triggers_rel (triggers_rel),

    .trigger_adc_0 (trigger_adc_0),
    .trigger_adc_1 (trigger_adc_1),
    .trigger_adc_2 (trigger_adc_2),
    .trigger_adc_3 (trigger_adc_3),

    .trigger_type (trigger_type),

    .fifo_depth (fifo_depth),
    
    .limit_0 (limit_0),
    .limit_1 (limit_1),
    .limit_2 (limit_2),
    .limit_3 (limit_3),
    
    .hysteresis_0 (hysteresis_0),
    .hysteresis_1 (hysteresis_1),
    .hysteresis_2 (hysteresis_2),
    .hysteresis_3 (hysteresis_3),
    
    .edge_detect_enable_0 (edge_detect_enable_0),
    .rise_edge_enable_0 (rise_edge_enable_0),
    .fall_edge_enable_0 (fall_edge_enable_0),
    .low_level_enable_0 (low_level_enable_0),
    .high_level_enable_0 (high_level_enable_0),
    
    .edge_detect_enable_1 (edge_detect_enable_1),
    .rise_edge_enable_1 (rise_edge_enable_1),
    .fall_edge_enable_1 (fall_edge_enable_1),
    .low_level_enable_1 (low_level_enable_1),
    .high_level_enable_1 (high_level_enable_1),
    
    .edge_detect_enable_2 (edge_detect_enable_2),
    .rise_edge_enable_2 (rise_edge_enable_2),
    .fall_edge_enable_2 (fall_edge_enable_2),
    .low_level_enable_2 (low_level_enable_2),
    .high_level_enable_2 (high_level_enable_2),
    
    .edge_detect_enable_3 (edge_detect_enable_3),
    .rise_edge_enable_3 (rise_edge_enable_3),
    .fall_edge_enable_3 (fall_edge_enable_3),
    .low_level_enable_3 (low_level_enable_3),
    .high_level_enable_3 (high_level_enable_3),
    
    // bus interface
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_wreq (up_wreq),
    .up_waddr (up_waddr),
    .up_wdata (up_wdata),
    .up_wack (up_wack),
    .up_rreq (up_rreq),
    .up_raddr (up_raddr),
    .up_rdata (up_rdata),
    .up_rack (up_rack)
  );


  // axi interface
  up_axi #(
    .AXI_ADDRESS_WIDTH(7)
  ) i_up_axi (
    .up_rstn (up_rstn),
    .up_clk (up_clk),
    .up_axi_awvalid (s_axi_awvalid),
    .up_axi_awaddr (s_axi_awaddr),
    .up_axi_awready (s_axi_awready),
    .up_axi_wvalid (s_axi_wvalid),
    .up_axi_wdata (s_axi_wdata),
    .up_axi_wstrb (s_axi_wstrb),
    .up_axi_wready (s_axi_wready),
    .up_axi_bvalid (s_axi_bvalid),
    .up_axi_bresp (s_axi_bresp),
    .up_axi_bready (s_axi_bready),
    .up_axi_arvalid (s_axi_arvalid),
    .up_axi_araddr (s_axi_araddr),
    .up_axi_arready (s_axi_arready),
    .up_axi_rvalid (s_axi_rvalid),
    .up_axi_rresp (s_axi_rresp),
    .up_axi_rdata (s_axi_rdata),
    .up_axi_rready (s_axi_rready),
    .up_wreq (up_wreq),
    .up_waddr (up_waddr),
    .up_wdata (up_wdata),
    .up_wack (up_wack),
    .up_rreq (up_rreq),
    .up_raddr (up_raddr),
    .up_rdata (up_rdata),
    .up_rack (up_rack)
  );
endmodule

// ***************************************************************************
// ***************************************************************************