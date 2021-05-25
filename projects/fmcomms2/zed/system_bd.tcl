
source $ad_hdl_dir/projects/common/zed/zed_system_bd.tcl
source ../common/fmcomms2_bd.tcl


create_bd_port -dir O -from 1 -to 0 trigger_o
create_bd_port -dir O -from 1 -to 0 trigger_t


# instances
ad_ip_instance axi_adc_trigger adc_trigger
ad_ip_instance axi_dmac axi_dmac_trigger
ad_ip_parameter axi_dmac_trigger CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter axi_dmac_trigger CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_dmac_trigger CONFIG.CYCLIC 0
ad_ip_parameter axi_dmac_trigger CONFIG.SYNC_TRANSFER_START 1
ad_ip_parameter axi_dmac_trigger CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_dmac_trigger CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_dmac_trigger CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_dmac_trigger CONFIG.DMA_DATA_WIDTH_SRC 64

ad_ip_instance util_cpack2 util_cpack_trigger { \
  NUM_OF_CHANNELS 2 \
  SAMPLE_DATA_WIDTH 16 \
}

# connections
ad_connect util_ad9361_adc_fifo/dout_clk 				adc_trigger/clk	
ad_connect util_ad9361_adc_fifo/dout_rstn 				adc_trigger/reset

ad_connect util_ad9361_adc_fifo/dout_data_0 				adc_trigger/data_a
ad_connect util_ad9361_adc_fifo/dout_data_1 				adc_trigger/data_b
ad_connect util_ad9361_adc_fifo/dout_valid_0 				adc_trigger/data_valid_a
ad_connect util_ad9361_adc_fifo/dout_valid_1 				adc_trigger/data_valid_b

ad_connect sys_rstgen/peripheral_aresetn 				adc_trigger/s_axi_aresetn

ad_connect trigger_o 							adc_trigger/trigger_o
ad_connect trigger_t 							adc_trigger/trigger_t

ad_connect util_ad9361_adc_fifo/dout_clk 				util_cpack_trigger/clk	
ad_connect util_ad9361_divclk_reset/peripheral_reset 			util_cpack_trigger/reset
ad_connect adc_trigger/data_a_trig        				util_cpack_trigger/fifo_wr_data_0
ad_connect adc_trigger/data_b_trig        				util_cpack_trigger/fifo_wr_data_1
ad_connect adc_trigger/data_valid_a_trig  				util_cpack_trigger/enable_0
ad_connect adc_trigger/data_valid_b_trig  				util_cpack_trigger/enable_1

ad_connect adc_trigger/data_valid_a_trig         			util_cpack_trigger/fifo_wr_en

ad_connect util_cpack_trigger/packed_fifo_wr 				axi_dmac_trigger/fifo_wr
ad_connect util_ad9361_divclk/clk_out 					axi_dmac_trigger/fifo_wr_clk
ad_connect adc_trigger/trigger_out					axi_dmac_trigger/fifo_wr_sync
ad_connect $sys_cpu_resetn 						axi_dmac_trigger/m_dest_axi_aresetn

# interconnects
ad_cpu_interconnect 0x43C00000 adc_trigger
ad_cpu_interconnect 0x43C10000 axi_dmac_trigger
ad_mem_hp1_interconnect $sys_cpu_clk axi_dmac_trigger/m_dest_axi

# system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

sysid_gen_sys_init_file

ad_ip_parameter axi_ad9361 CONFIG.ADC_INIT_DELAY 23

ad_ip_parameter axi_ad9361 CONFIG.TDD_DISABLE 1


# interrupts
ad_cpu_interrupt ps-10 mb-11 axi_dmac_trigger/irq
