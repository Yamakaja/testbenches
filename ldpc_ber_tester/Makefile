####################################################################################
####################################################################################
## Copyright 2021(c) David Winter
####################################################################################
####################################################################################

SV_DEPS += ../common/sv/utils.svh
SV_DEPS += ../common/sv/logger_pkg.sv
SV_DEPS += ../common/sv/reg_accessor.sv
SV_DEPS += ../common/sv/sd_fec_pkg.sv
SV_DEPS += ../common/sv/m_axi_sequencer.sv
SV_DEPS += environment.sv
SV_DEPS += system_tb.sv
SV_DEPS += ldpc_ber_tester_pkg.sv

ENV_DEPS += cfgs/common_cfg.tcl
ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS += ../scripts/adi_sim.tcl
ENV_DEPS += ../scripts/run_sim.tcl

# LIB_DEPS += util_fifo2axi_bridge

#util_fifo2axi_bridge test program
TP := test_program

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))
$(warning $(CFG_FILES))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(cfg):$(TP))

include ../scripts/project-sim.mk
