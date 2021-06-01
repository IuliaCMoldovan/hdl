# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create axi_trigger
adi_ip_files axi_trigger [list \
  "$ad_hdl_dir/library/common/up_xfer_cntrl.v" \
  "$ad_hdl_dir/library/common/ad_rst.v" \
  "$ad_hdl_dir/library/common/up_axi.v" \
  "$ad_hdl_dir/library/xilinx/common/up_xfer_cntrl_constr.xdc" \
  "$ad_hdl_dir/library/xilinx/common/ad_rst_constr.xdc" \
  "axi_trigger.v" \
  "probe_trigger.v" \
  "adc_trigger.v" \
  "dac_trigger.v" \
  "trigger_ip_regmap.v" ]

adi_ip_properties axi_trigger

ipx::infer_bus_interface clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface rst xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

ipx::save_core [ipx::current_core]