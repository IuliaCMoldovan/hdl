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

module trigger_ip_regmap (
  input						clk,
  
  output		[31:0]  	fifo_depth,
  output		[31:0]		edge_detect_enable_0,
  output		[31:0]		rise_edge_enable_0,
  output		[31:0]		fall_edge_enable_0,
  output		[31:0]		low_level_enable_0,
  output		[31:0]		high_level_enable_0,
  
  output		[31:0]		edge_detect_enable_1,
  output		[31:0]		rise_edge_enable_1,
  output		[31:0]		fall_edge_enable_1,
  output		[31:0]		low_level_enable_1,
  output		[31:0]		high_level_enable_1,
  				          		
  output		[31:0]		edge_detect_enable_2,
  output		[31:0]		rise_edge_enable_2,
  output		[31:0]		fall_edge_enable_2,
  output		[31:0]		low_level_enable_2,
  output		[31:0]		high_level_enable_2,
  
  output		[31:0]		edge_detect_enable_3,
  output		[31:0]		rise_edge_enable_3,
  output		[31:0]		fall_edge_enable_3,
  output		[31:0]		low_level_enable_3,
  output		[31:0]		high_level_enable_3,
	
	
  // bit 3 is used for setting the internal trigger condition,
  // between the bits that were selected to be monitored 
  // bits [2:0] are used for defining the relationship 
  // between the internal and external trigger 
  output		[ 3:0]		trigger_logic,
  output					rst,
  
  // bus interface
  input						up_rstn,
  input						up_clk,
  input						up_wreq,
  input			[ 4:0]		up_waddr,
  input			[31:0]		up_wdata,
  output reg				up_wack,
  input						up_rreq,
  input			[ 4:0]		up_raddr,
  output reg	[31:0]		up_rdata,
  output reg				up_rack
);
  
  // internal registers
  reg			[31:0]		up_version = 32'h00020100;
  reg			[31:0]		up_scratch = 0;
  reg			[ 3:0]		up_trigger_logic = 0;
  
  reg   		[31:0]  	up_fifo_depth = 0;
  reg			[31:0]		up_edge_detect_enable_0 = 0;
  reg			[31:0]		up_rise_edge_enable_0 = 0;
  reg			[31:0]		up_fall_edge_enable_0 = 0;
  reg			[31:0]		up_low_level_enable_0 = 0;
  reg			[31:0]		up_high_level_enable_0 = 0;
  											
  reg			[31:0]		up_edge_detect_enable_1 = 0;
  reg			[31:0]		up_rise_edge_enable_1 = 0;
  reg			[31:0]		up_fall_edge_enable_1 = 0;
  reg			[31:0]		up_low_level_enable_1 = 0;
  reg			[31:0]		up_high_level_enable_1 = 0;
  									    
  reg			[31:0]		up_edge_detect_enable_2 = 0;
  reg			[31:0]		up_rise_edge_enable_2 = 0;
  reg			[31:0]		up_fall_edge_enable_2 = 0;
  reg			[31:0]		up_low_level_enable_2 = 0;
  reg			[31:0]		up_high_level_enable_2 = 0;
  										
  reg			[31:0]		up_edge_detect_enable_3 = 0;
  reg			[31:0]		up_rise_edge_enable_3 = 0;
  reg			[31:0]		up_fall_edge_enable_3 = 0;
  reg			[31:0]		up_low_level_enable_3 = 0;
  reg			[31:0]		up_high_level_enable_3 = 0;
  
  always @(negedge up_rstn or posedge up_clk) begin
  	if (up_rstn == 0) begin	
  	  up_wack <= 'h0;
  	  up_scratch <= 'h0;
  	  up_trigger_logic <= 'h0;
  	  
  	  up_fifo_depth <= 'd0;
  	  
  	  up_edge_detect_enable_0   <= 'h0;
  	  up_rise_edge_enable_0  <= 'h0;
  	  up_fall_edge_enable_0  <= 'h0;
  	  up_low_level_enable_0  <= 'h0;
  	  up_high_level_enable_0 <= 'h0;
  	   
  	  up_edge_detect_enable_1   <= 'h0;
  	  up_rise_edge_enable_1  <= 'h0;
  	  up_fall_edge_enable_1  <= 'h0;
  	  up_low_level_enable_1  <= 'h0;
  	  up_high_level_enable_1 <= 'h0;
  	   
  	  up_edge_detect_enable_2 <= 'h0;
  	  up_rise_edge_enable_2 <= 'h0;
  	  up_fall_edge_enable_2 <= 'h0;
  	  up_low_level_enable_2 <= 'h0;
  	  up_high_level_enable_2 <= 'h0;
  	   
  	  up_edge_detect_enable_3 <= 'h0;
  	  up_rise_edge_enable_3 <= 'h0;
  	  up_fall_edge_enable_3 <= 'h0;
  	  up_low_level_enable_3 <= 'h0;
  	  up_high_level_enable_3 <= 'h0;
    end else begin
		
      up_wack <= up_wreq;
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h1)) begin
      	up_scratch <= up_wdata;
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h2)) begin
      	up_trigger_logic <= up_wdata[3:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h3)) begin
      	up_fifo_depth <= up_wdata;
      end
      
      // for PROBE 0
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h10)) begin
      	up_edge_detect_enable_0 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h11)) begin
      	up_rise_edge_enable_0 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h12)) begin
      	up_fall_edge_enable_0 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h13)) begin
      	up_low_level_enable_0 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h14)) begin
      	up_high_level_enable_0 <= up_wdata[31:0];
      end
      
      
      // for PROBE 1
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h18)) begin
      	up_edge_detect_enable_1 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h19)) begin
      	up_rise_edge_enable_1 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h1A)) begin
      	up_fall_edge_enable_1 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h1B)) begin
      	up_low_level_enable_1 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h1C)) begin
      	up_high_level_enable_1 <= up_wdata[31:0];
      end
      
      
      // for PROBE 2
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h20)) begin
      	up_edge_detect_enable_2 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h21)) begin
      	up_rise_edge_enable_2 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h22)) begin
      	up_fall_edge_enable_2 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h23)) begin
      	up_low_level_enable_2 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h24)) begin
      	up_high_level_enable_2 <= up_wdata[31:0];
      end
      
      
      // for PROBE 3
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h28)) begin
      	up_edge_detect_enable_3 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h29)) begin
      	up_rise_edge_enable_3 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h2A)) begin
      	up_fall_edge_enable_3 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h2B)) begin
      	up_low_level_enable_3 <= up_wdata[31:0];
      end
      if ((up_wreq == 1'b1) && (up_waddr[4:0] == 5'h2C)) begin
      	up_high_level_enable_3 <= up_wdata[31:0];
      end		
    end
  end

  // processor read interface
  always @(negedge up_rstn or posedge up_clk) begin
  	if (up_rstn == 0) begin
  		up_rack <= 'h0;
  		up_rdata <= 'h0;
  	end else begin
  	  up_rack <= up_rreq;
  	  if (up_rreq == 1'b1) begin
  	  	case (up_raddr[4:0])
  	  	  5'h0:up_rdata <= up_version;
  	  	  5'h1:up_rdata <= up_scratch;
  	  	  5'h2:up_rdata <= {25'h0,up_trigger_logic};
  	  	  5'h3:up_rdata <= up_fifo_depth;
  	  	  
  	  	  
  	  	  5'h10:up_rdata <= up_edge_detect_enable_0;
  	  	  5'h11:up_rdata <= up_rise_edge_enable_0;
  	  	  5'h12:up_rdata <= up_fall_edge_enable_0;
  	  	  5'h13:up_rdata <= up_low_level_enable_0;
  	  	  5'h14:up_rdata <= up_high_level_enable_0;
  	  	  	  	  
  	  	  5'h18:up_rdata <= up_edge_detect_enable_1;
  	  	  5'h19:up_rdata <= up_rise_edge_enable_1;
  	  	  5'h1A:up_rdata <= up_fall_edge_enable_1;
  	  	  5'h1B:up_rdata <= up_low_level_enable_1;
  	  	  5'h1C:up_rdata <= up_high_level_enable_1;	
  	  	  					
  	  	  5'h20:up_rdata <= up_edge_detect_enable_2;
  	  	  5'h21:up_rdata <= up_rise_edge_enable_2;
  	  	  5'h22:up_rdata <= up_fall_edge_enable_2;
  	  	  5'h23:up_rdata <= up_low_level_enable_2;
  	  	  5'h24:up_rdata <= up_high_level_enable_2;
  	  	  
  	  	  5'h28:up_rdata <= up_edge_detect_enable_3;
  	  	  5'h29:up_rdata <= up_rise_edge_enable_3;
  	  	  5'h2A:up_rdata <= up_fall_edge_enable_3;
  	  	  5'h2B:up_rdata <= up_low_level_enable_3;
  	  	  5'h2C:up_rdata <= up_high_level_enable_3;
		  default:up_rdata <= 0;
					
	    endcase
	  end else begin
	    up_rdata <= 32'h0;
	  end
    end
  end

  ad_rst i_core_rst_reg (
      .rst_async(~up_rstn), 
      .clk(clk), 
      .rstn(), 
      .rst(rst));
  
  
  // clock domain crossing
  up_xfer_cntrl #(.DATA_WIDTH(676)) i_xfer_cntrl (
  	.up_rstn (up_rstn),
  	.up_clk (up_clk),
  	.up_data_cntrl ({ up_trigger_logic,				//  4 
					  up_fifo_depth,				// 32
					  
					  up_high_level_enable_0,		// 32 
					  up_low_level_enable_0,		// 32 
					  up_fall_edge_enable_0,		// 32 
					  up_rise_edge_enable_0,		// 32 
					  up_edge_detect_enable_0,		// 32 
					 							 
					  up_high_level_enable_1,		// 32 
					  up_low_level_enable_1,		// 32 
					  up_fall_edge_enable_1,		// 32 
					  up_rise_edge_enable_1,		// 32 
					  up_edge_detect_enable_1,		// 32 		 
					  
					  up_high_level_enable_2,		// 32 
					  up_low_level_enable_2,		// 32 
					  up_fall_edge_enable_2,		// 32 
					  up_rise_edge_enable_2,		// 32 
					  up_edge_detect_enable_2,		// 32 
					  
					  up_high_level_enable_3,		// 32 
					  up_low_level_enable_3,		// 32 
					  up_fall_edge_enable_3,		// 32 
					  up_rise_edge_enable_3,		// 32 
					  up_edge_detect_enable_3  		// 32 
	}),	

    .up_xfer_done (),
    .d_rst (1'b0),
    .d_clk (up_clk),
    .d_data_cntrl ({  trigger_logic,				//  4
					  fifo_depth,					// 32
					  
					  high_level_enable_0,			// 32
					  low_level_enable_0,			// 32 
					  fall_edge_enable_0,			// 32 
					  rise_edge_enable_0,			// 32 
					  edge_detect_enable_0,	        // 32
					 							 
					  high_level_enable_1,			// 32
					  low_level_enable_1,			// 32 
					  fall_edge_enable_1,			// 32 
					  rise_edge_enable_1,			// 32 
					  edge_detect_enable_1,	        // 32
					 							 
					  high_level_enable_2,			
					  low_level_enable_2,			// 32 
					  fall_edge_enable_2,			// 32 
					  rise_edge_enable_2,			// 32 
					  edge_detect_enable_2,		    // 32
					 								// 32
					  high_level_enable_3,			
					  low_level_enable_3,			// 32 
					  fall_edge_enable_3,			// 32 
					  rise_edge_enable_3,			// 32 
					  edge_detect_enable_3          // 32
	}));	                            				
endmodule

// ***************************************************************************
// ***************************************************************************