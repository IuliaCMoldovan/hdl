
source $ad_hdl_dir/projects/common/zed/zed_system_bd.tcl
source ../common/fmcomms2_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

create_bd_port -dir O -from 1 -to 0 trigger_o
create_bd_port -dir O -from 1 -to 0 trigger_t

create_bd_port -dir I -from 0 -to 0 debug_btn_trig_ext
create_bd_port -dir O -from 7 -to 0 debug_led


# instances
ad_ip_instance axi_dmac trigger_dmac
ad_ip_parameter trigger_dmac CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter trigger_dmac CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter trigger_dmac CONFIG.CYCLIC 0
ad_ip_parameter trigger_dmac CONFIG.SYNC_TRANSFER_START 1
ad_ip_parameter trigger_dmac CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter trigger_dmac CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter trigger_dmac CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter trigger_dmac CONFIG.DMA_DATA_WIDTH_SRC 64

ad_ip_instance util_cpack2 util_cpack_trigger { \
  NUM_OF_CHANNELS 4 \
  SAMPLE_DATA_WIDTH 4 \
}

ad_ip_instance axi_trigger axi_trigger
ad_ip_parameter axi_trigger CONFIG.NB_SELECTED 4
ad_ip_parameter axi_trigger CONFIG.DW0 4
ad_ip_parameter axi_trigger CONFIG.DW1 4
ad_ip_parameter axi_trigger CONFIG.DW2 4
ad_ip_parameter axi_trigger CONFIG.DW3 4

ad_ip_instance util_var_fifo trigger_fifo
ad_ip_parameter trigger_fifo CONFIG.DATA_WIDTH 4
ad_ip_parameter trigger_fifo CONFIG.ADDRESS_WIDTH 13

ad_ip_instance proc_sys_reset trigger_rstgen

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
ad_ip_parameter bram_dd CONFIG.Write_Width_A {4}
ad_ip_parameter bram_dd CONFIG.Write_Width_B {4}
ad_ip_parameter bram_dd CONFIG.Read_Width_B {4}
ad_ip_parameter bram_dd CONFIG.Write_Depth_A {8192}


# connections
ad_connect util_ad9361_adc_fifo/dout_clk                  axi_trigger/clk    
ad_connect util_ad9361_adc_fifo/dout_rstn                 axi_trigger/rst

ad_connect util_ad9361_adc_fifo/dout_data_0               axi_trigger/probe0
ad_connect util_ad9361_adc_fifo/dout_data_1               axi_trigger/probe1
ad_connect util_ad9361_adc_fifo/dout_data_2               axi_trigger/probe2
ad_connect util_ad9361_adc_fifo/dout_data_3               axi_trigger/probe3
ad_connect util_ad9361_adc_fifo/dout_valid_0              axi_trigger/valid0
ad_connect util_ad9361_adc_fifo/dout_valid_1              axi_trigger/valid1
ad_connect util_ad9361_adc_fifo/dout_valid_2              axi_trigger/valid2
ad_connect util_ad9361_adc_fifo/dout_valid_3              axi_trigger/valid3
ad_connect axi_trigger/adc_data0                          util_cpack_trigger/fifo_wr_data_0
ad_connect axi_trigger/adc_data1                          util_cpack_trigger/fifo_wr_data_1
ad_connect axi_trigger/out_valid0                         util_cpack_trigger/enable_0
ad_connect axi_trigger/out_valid1                         util_cpack_trigger/enable_1
ad_connect axi_trigger/trigger_out                        util_cpack_trigger/fifo_wr_en

ad_connect sys_rstgen/peripheral_aresetn                  axi_trigger/s_axi_aresetn

ad_connect axi_trigger/adc_data0                          trigger_fifo/data_in
ad_connect axi_trigger/data_valids                        trigger_fifo/data_in_valid
ad_connect debug_btn_trig_ext                             axi_trigger/trigger_ext
ad_connect trigger_fifo/depth                             axi_trigger/fifo_depth 

ad_connect trigger_clk                                    axi_trigger/clk_out
ad_connect trigger_clk                                    trigger_fifo/clk
ad_connect util_ad9361_divclk/clk_out                     trigger_fifo/clk
ad_connect trigger_clk                                    bram_dd/clkb
ad_connect trigger_clk                                    bram_dd/clka

ad_connect sys_cpu_clk                                    trigger_rstgen/slowest_sync_clk

ad_connect trigger_rstgen/ext_reset_in                    sys_rstgen/peripheral_aresetn
ad_connect trigger_rstgen/bus_struct_reset                trigger_fifo/rst

ad_connect trigger_fifo/addr_w                            bram_dd/addra
ad_connect trigger_fifo/din_w                             bram_dd/dina
ad_connect trigger_fifo/en_w                              bram_dd/ena
ad_connect trigger_fifo/wea_w                             bram_dd/wea
ad_connect trigger_fifo/addr_r                            bram_dd/addrb
ad_connect trigger_fifo/dout_r                            bram_dd/doutb
ad_connect trigger_fifo/en_r                              bram_dd/enb


# util_cpack_trigger
ad_connect util_ad9361_adc_fifo/dout_clk                  util_cpack_trigger/clk    
ad_connect util_ad9361_divclk_reset/peripheral_reset      util_cpack_trigger/reset


# trigger_dmac
ad_connect axi_trigger/trigger_out                        trigger_dmac/fifo_wr_sync
ad_connect trigger_fifo/data_out                          trigger_dmac/fifo_wr_din  
ad_connect trigger_fifo/data_out_valid                    trigger_dmac/fifo_wr_en 
ad_connect util_cpack_trigger/packed_fifo_wr              trigger_dmac/fifo_wr
ad_connect util_ad9361_divclk/clk_out                     trigger_dmac/fifo_wr_clk
ad_connect $sys_cpu_resetn                                trigger_dmac/m_dest_axi_aresetn


# interconnects
ad_cpu_interconnect 0x43C00000 axi_trigger
ad_cpu_interconnect 0x43C10000 trigger_dmac
ad_mem_hp1_interconnect $sys_cpu_clk trigger_dmac/m_dest_axi


# system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

sysid_gen_sys_init_file

ad_ip_parameter axi_ad9361 CONFIG.ADC_INIT_DELAY 23

ad_ip_parameter axi_ad9361 CONFIG.TDD_DISABLE 1


# interrupts
ad_cpu_interrupt ps-10 mb-11 trigger_dmac/irq