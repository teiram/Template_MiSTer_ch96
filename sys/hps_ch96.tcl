#============================================================================
# HPS interface constraints + sys file list
#
# The MiSTer design instantiates raw Cyclone V HPS atoms. The HPS_LOCATION
# assignments place the uart and i2c peripheral interfaces at the same
# locations the Chameleon96 preloader handoff uses (verified against
# hps-ch96/hps.sopcinfo). The spi atom is not instantiated (MISTER_DISABLE_ALSA).
#============================================================================

set_instance_assignment -name HPS_LOCATION HPSINTERFACEPERIPHERALUART_X52_Y67_N111 -entity sys_top -to uart
set_instance_assignment -name HPS_LOCATION HPSINTERFACEPERIPHERALI2C_X52_Y60_N111 -entity sys_top -to hdmi_i2c

# Resolve sibling files from this script's own location, independent of
# where the framework submodule is mounted (template/sys, sys, ...).
set hps_ch96_dir [file dirname [info script]]

set_global_assignment -name PRE_FLOW_SCRIPT_FILE "quartus_sh:[file join $hps_ch96_dir build_id.tcl]"
set_global_assignment -name QIP_FILE [file join $hps_ch96_dir sys.qip]
set_global_assignment -name SYSTEMVERILOG_FILE [file join $hps_ch96_dir ch96_top.sv]
