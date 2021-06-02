source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project debug_design_zed
adi_project_files debug_design_zed [list \
  "system_top.v" \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc" \
  "$ad_hdl_dir/library/axi_trigger/axi_trigger.v" \
  "$ad_hdl_dir/library/axi_trigger/probe_trigger.v" \
  "$ad_hdl_dir/library/axi_trigger/adc_trigger.v" \
  "$ad_hdl_dir/library/axi_trigger/dac_trigger.v" \
  "$ad_hdl_dir/library/axi_trigger/trigger_ip_regmap.v" \
  "$ad_hdl_dir/library/common/ad_iobuf.v"]

adi_project_run debug_design_zed


