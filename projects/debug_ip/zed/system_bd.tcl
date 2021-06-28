
if {[info exists DEBUG_BUILD] == 0} {
  set DEBUG_BUILD 1
}

set DISABLE_DMAC_DEBUG [expr !$DEBUG_BUILD]

source $ad_hdl_dir/projects/common/zed/zed_system_bd.tcl

create_bd_port -dir I -from  0 -to 0 debug_btn_trig
create_bd_port -dir I -from 11 -to 0 debug_probe
create_bd_port -dir O -from  7 -to 0 debug_led

# Create cells
create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0
set_property -dict [list CONFIG.DIN_TO {4} CONFIG.DIN_FROM {11} CONFIG.DIN_WIDTH {12} CONFIG.DIN_FROM {11} CONFIG.DOUT_WIDTH {8}] [get_bd_cells xlslice_0]
connect_bd_net [get_bd_ports debug_probe] [get_bd_pins xlslice_0/Din]
connect_bd_net [get_bd_ports debug_led] [get_bd_pins xlslice_0/Dout]

create_bd_cell -type ip -vlnv xilinx.com:ip:ila:6.2 ila_0
set_property -dict [list CONFIG.C_PROBE0_WIDTH {8} CONFIG.C_DATA_DEPTH {4096} CONFIG.C_NUM_OF_PROBES {1} CONFIG.C_ENABLE_ILA_AXI_MON {false} CONFIG.C_MONITOR_TYPE {Native}] [get_bd_cells ila_0]
connect_bd_net [get_bd_pins ila_0/probe0] [get_bd_pins xlslice_0/Dout]
connect_bd_net [get_bd_pins ila_0/clk] [get_bd_pins sys_ps7/FCLK_CLK0]



# Instances, parameters
ad_ip_instance axi_trigger axi_trigger
ad_ip_parameter axi_trigger CONFIG.NB_SELECTED 4
ad_ip_parameter axi_trigger CONFIG.DW0 4
ad_ip_parameter axi_trigger CONFIG.DW1 4
ad_ip_parameter axi_trigger CONFIG.DW2 4
ad_ip_parameter axi_trigger CONFIG.DW3 4

ad_ip_instance util_var_fifo trigger_fifo
ad_ip_parameter trigger_fifo CONFIG.DATA_WIDTH 16
ad_ip_parameter trigger_fifo CONFIG.ADDRESS_WIDTH 13

ad_ip_instance axi_dmac trigger_dmac
ad_ip_parameter trigger_dmac CONFIG.DMA_DATA_WIDTH_SRC 16
ad_ip_parameter trigger_dmac CONFIG.DMA_AXI_PROTOCOL_DEST 1
ad_ip_parameter trigger_dmac CONFIG.SYNC_TRANSFER_START true
ad_ip_parameter trigger_dmac CONFIG.DISABLE_DEBUG_REGISTERS $DISABLE_DMAC_DEBUG

ad_ip_instance proc_sys_reset trigger_reset

ad_ip_instance blk_mem_gen bram_dd
ad_ip_parameter bram_dd CONFIG.use_bram_block {Stand_Alone}
ad_ip_parameter bram_dd CONFIG.Memory_Type {Simple_Dual_Port_RAM}
ad_ip_parameter bram_dd CONFIG.Assume_Synchronous_Clk {true}
ad_ip_parameter bram_dd CONFIG.Algorithm {Low_Power}
ad_ip_parameter bram_dd CONFIG.Use_Byte_Write_Enable {false}
ad_ip_parameter bram_dd CONFIG.Operating_Mode_A {NO_CHANGE}
ad_ip_parameter bram_dd CONFIG.Register_PortB_Output_of_Memory_Primitives {true}
ad_ip_parameter bram_dd CONFIG.Use_RSTA_Pin {false}
ad_ip_parameter bram_dd CONFIG.Port_B_Clock {100}
ad_ip_parameter bram_dd CONFIG.Port_B_Enable_Rate {100}
ad_ip_parameter bram_dd CONFIG.Write_Width_A {16}
ad_ip_parameter bram_dd CONFIG.Write_Width_B {16}
ad_ip_parameter bram_dd CONFIG.Read_Width_B {16}
ad_ip_parameter bram_dd CONFIG.Write_Depth_A {8192}


# Connections
ad_connect trigger_clk axi_trigger/clk
ad_connect trigger_clk trigger_fifo/clk
ad_connect trigger_clk bram_dd/clkb
ad_connect trigger_clk bram_dd/clka
ad_connect trigger_clk trigger_dmac/fifo_wr_clk
ad_connect trigger_clk trigger_reset/slowest_sync_clk
ad_connect trigger_reset/ext_reset_in sys_rstgen/peripheral_aresetn
ad_connect trigger_reset/bus_struct_reset trigger_fifo/rst

#ad_connect axi_trigger/adc_data 	trigger_fifo/data_in        
ad_connect axi_trigger/data_valids 	trigger_fifo/data_in_valid  

ad_connect trigger_fifo/addr_w 		bram_dd/addra                    
ad_connect trigger_fifo/din_w  		bram_dd/dina                     
ad_connect trigger_fifo/en_w   		bram_dd/ena                      
ad_connect trigger_fifo/wea_w  		bram_dd/wea                      
ad_connect trigger_fifo/addr_r 		bram_dd/addrb                    
ad_connect trigger_fifo/dout_r 		bram_dd/doutb                    
ad_connect trigger_fifo/en_r   		bram_dd/enb                      

ad_connect trigger_fifo/data_out 			trigger_dmac/fifo_wr_din  
ad_connect trigger_fifo/data_out_valid 		trigger_dmac/fifo_wr_en   

ad_connect trigger_fifo/depth 				axi_trigger/fifo_depth 


# Logic analyzer DMA
ad_connect sys_cpu_clk trigger_dmac/m_dest_axi_aclk


#ad_connect trigger_dmac/m_dest_axi axi_rd_wr_combiner_logic/s_wr_axi

#ad_ip_parameter sys_ps7 CONFIG.PCW_USE_S_AXI_HP1 {1}
#ad_connect sys_cpu_clk sys_ps7/S_AXI_HP1_ACLK
#ad_connect trigger_dmac/m_dest_axi sys_ps7/S_AXI_HP1

ad_connect axi_trigger/clk sys_ps7/FCLK_CLK0

# Alternative for when using multi-bit valid_probes
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
set_property -dict [list CONFIG.CONST_WIDTH {2} CONFIG.CONST_VAL {3}] [get_bd_cells xlconstant_0]
ad_connect xlconstant_0/dout axi_trigger/valid_probes
# # #
#create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
#connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins axi_trigger/data_valid_0]
#create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1
#connect_bd_net [get_bd_pins xlconstant_1/dout] [get_bd_pins axi_trigger/data_valid_1]

#set_property -dict [list CONFIG.C_DW1 {12} CONFIG.C_NUM_OF_PROBES {3}] [get_bd_cells ila_0]

# Connect nets
# ##############ad_connect axi_trigger/trigger_out ila_0/probe2
#ad_connect debug_probe ila_0/probe1
ad_connect debug_probe axi_trigger/probe0
ad_connect debug_probe axi_trigger/probe1
ad_connect debug_probe axi_trigger/probe2
ad_connect debug_probe axi_trigger/probe3
ad_connect debug_btn_trig axi_trigger/trigger_ext
ad_connect trigger_dmac/fifo_wr_sync axi_trigger/trigger_out


# Map
ad_cpu_interconnect 0x44000000 axi_trigger
ad_cpu_interconnect 0x7C400000 trigger_dmac

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_cpu_clk trigger_dmac/m_dest_axi

ad_connect  sys_cpu_resetn trigger_dmac/m_dest_axi_aresetn

# Interrupts
ad_cpu_interrupt ps-10 mb-11 trigger_dmac/irq
