
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project fmcomms2_zed
adi_project_files fmcomms2_zed [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zed/zed_system_constr.xdc" \
  "$ad_hdl_dir/library/axi_trigger/axi_trigger.v" \
  "$ad_hdl_dir/library/axi_trigger/probe_trigger.v" \
  "$ad_hdl_dir/library/axi_trigger/adc_trigger.v" \
  "$ad_hdl_dir/library/axi_trigger/digital_trigger.v" \
  "$ad_hdl_dir/library/axi_trigger/trigger_ip_regmap.v" \
  "$ad_hdl_dir/library/common/ad_iobuf.v"]

adi_project_run fmcomms2_zed
source $ad_hdl_dir/library/axi_ad9361/axi_ad9361_delay.tcl

