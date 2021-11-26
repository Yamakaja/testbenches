source ../scripts/adi_sim.tcl
source ../../library/scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

if {$argc < 1} {
    set cfg_file cfg0.tcl
} else {
    set cfg_file [lindex $argv 0]
}

global ad_project_params

# Disable default harness
set ad_project_params(CUSTOM_HARNESS) 1

# Read common configuration file
source "cfgs/common_cfg.tcl"
# Read configuration file with topology information
source "cfgs/${cfg_file}"

# Set the project name
set project_name [file rootname $cfg_file]

# Create the project
set bd_design_name "test_harness"
set part "xczu28dr-ffvg1517-2-e"

adi_sim_project_xilinx $project_name $part

if {[info exists ::env(TST)]} {
    set TST $::env(TST)
} else {
    set TST test_program
}

# Add test files to the project
adi_sim_project_files [list \
 "../common/sv/utils.svh" \
 "../common/sv/logger_pkg.sv" \
 "../common/sv/reg_accessor.sv" \
 "../common/sv/m_axi_sequencer.sv" \
 "../common/sv/sd_fec_pkg.sv" \
 "ldpc_ber_tester_pkg.sv" \
 "environment.sv" \
 "tests/$TST.sv" \
 "system_tb.sv" \
]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=$TST"

adi_sim_generate $project_name
