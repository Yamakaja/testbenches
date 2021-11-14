global ad_hdl_dir
global ad_project_params

## DUT configuration

## Define passthrough
#
# adi_sim_add_define

################################################################################
# Create interface ports -- clocks and resets
################################################################################

# system clock/reset

ad_ip_instance clk_vip sys_clk_vip
adi_sim_add_define "SYS_CLK=sys_clk_vip"
ad_ip_parameter sys_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter sys_clk_vip CONFIG.FREQ_HZ {100000000}

ad_ip_instance rst_vip sys_rst_vip
adi_sim_add_define "SYS_RST=sys_rst_vip"
ad_ip_parameter sys_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter sys_rst_vip CONFIG.RST_POLARITY {ACTIVE_LOW}
ad_ip_parameter sys_rst_vip CONFIG.ASYNCHRONOUS {NO}

ad_connect sys_clk_vip/clk_out sys_rst_vip/sync_clk

ad_ip_instance clk_vip core_clk_vip
adi_sim_add_define "CORE_CLK=core_clk_vip"
ad_ip_parameter core_clk_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter core_clk_vip CONFIG.FREQ_HZ {500000000}

ad_ip_instance rst_vip core_rst_vip
adi_sim_add_define "CORE_RST=core_rst_vip"
ad_ip_parameter core_rst_vip CONFIG.INTERFACE_MODE {MASTER}
ad_ip_parameter core_rst_vip CONFIG.RST_POLARITY {ACTIVE_LOW}
ad_ip_parameter core_rst_vip CONFIG.ASYNCHRONOUS {NO}

ad_connect core_clk_vip/clk_out core_rst_vip/sync_clk

################################################################################
# mng_axi - AXI4 VIP for configuration
################################################################################

set DUT sdfec_0

ad_ip_instance sd_fec $DUT

set_property -dict [list \
    CONFIG.Standard {Custom} \
    CONFIG.Turbo_Decode {false} \
    CONFIG.LDPC_Decode {true} \
    CONFIG.LDPC_Decode_Code_Definition {../../../../../../../../test.txt} \
    CONFIG.Parameter_Interface {Initialized_retain_I/F} \
    CONFIG.TD_PERCENT_LOAD {0} \
    CONFIG.DRV_INITIALIZATION_PARAMS {{ 0x00000014,0x00000001,0x0000000C,0x00000000 }} \
    CONFIG.DRV_TURBO_PARAMS {undefined} \
    CONFIG.DRV_LDPC_PARAMS {test {dec_OK 1 enc_OK 1 n 5940 k 5040 p 180 nlayers 5 nqc 131 nmqc 132 nm 66 norm_type 1 no_packing 0 special_qc 0 no_final_parity 0 max_schedule 0 sc_table {52428 12} la_table {3353 4378 4377 5401 3865} qc_table {167424 171521 160002 162819 154628 142341 154886 148999 175112 131849 137482 142347 167180 172045 143886 142607 161296 152593 147475 147988 155925 131350 160535 133144 158745 398876 13824 44033 37122 7171 14084 4869 40710 5639 24584 3081 21770 32780 1293 40462 30735 13072 43793 147730 36115 10773 21270 1815 10009 162074 152603 288028 437021 16128 2817 28674 29187 15620 31493 18438 14087 29192 5129 13578 29195 10764 8461 1038 16911 41744 12817 11794 4371 44820 23576 10522 35355 270877 405278 7168 40961 26114 11267 2052 21509 32262 2311 43272 44553 37642 6155 37132 6670 17170 21011 1044 45333 38678 33559 35608 29977 9242 4635 268062 395295 13312 40705 19202 18947 11780 18181 10758 2823 27656 39177 18443 41741 2319 528 43025 40466 276 12565 22806 16151 45848 2585 19226 41243 307487 398112}}} \
    CONFIG.HDL_INITIALIZATION {{8192 330307380 {K, N}} {8196 135348 {NM, NO_PACKING, PSIZE}} {8200 1116165 {MAX_SCHEDULE, NO_FINAL_PARITY_CHECK, NORM_TYPE, NMQC, NLAYERS}} {8204 0 {QC_OFF, LA_OFF, SC_OFF}} {65536 52428 SC_TABLE} {65540 12 {}} {98304 3353 LA_TABLE} {98308 4378 {}} {98312 4377 {}} {98316 5401 {}} {98320 3865 {}} {131072 167424 QC_TABLE} {131076 171521 {}} {131080 160002 {}} {131084 162819 {}} {131088 154628 {}} {131092 142341 {}} {131096 154886 {}} {131100 148999 {}} {131104 175112 {}} {131108 131849 {}} {131112 137482 {}} {131116 142347 {}} {131120 167180 {}} {131124 172045 {}} {131128 143886 {}} {131132 142607 {}} {131136 161296 {}} {131140 152593 {}} {131144 147475 {}} {131148 147988 {}} {131152 155925 {}} {131156 131350 {}} {131160 160535 {}} {131164 133144 {}} {131168 158745 {}} {131172 398876 {}} {131176 13824 {}} {131180 44033 {}} {131184 37122 {}} {131188 7171 {}} {131192 14084 {}} {131196 4869 {}} {131200 40710 {}} {131204 5639 {}} {131208 24584 {}} {131212 3081 {}} {131216 21770 {}} {131220 32780 {}} {131224 1293 {}} {131228 40462 {}} {131232 30735 {}} {131236 13072 {}} {131240 43793 {}} {131244 147730 {}} {131248 36115 {}} {131252 10773 {}} {131256 21270 {}} {131260 1815 {}} {131264 10009 {}} {131268 162074 {}} {131272 152603 {}} {131276 288028 {}} {131280 437021 {}} {131284 16128 {}} {131288 2817 {}} {131292 28674 {}} {131296 29187 {}} {131300 15620 {}} {131304 31493 {}} {131308 18438 {}} {131312 14087 {}} {131316 29192 {}} {131320 5129 {}} {131324 13578 {}} {131328 29195 {}} {131332 10764 {}} {131336 8461 {}} {131340 1038 {}} {131344 16911 {}} {131348 41744 {}} {131352 12817 {}} {131356 11794 {}} {131360 4371 {}} {131364 44820 {}} {131368 23576 {}} {131372 10522 {}} {131376 35355 {}} {131380 270877 {}} {131384 405278 {}} {131388 7168 {}} {131392 40961 {}} {131396 26114 {}} {131400 11267 {}} {131404 2052 {}} {131408 21509 {}} {131412 32262 {}} {131416 2311 {}} {131420 43272 {}} {131424 44553 {}} {131428 37642 {}} {131432 6155 {}} {131436 37132 {}} {131440 6670 {}} {131444 17170 {}} {131448 21011 {}} {131452 1044 {}} {131456 45333 {}} {131460 38678 {}} {131464 33559 {}} {131468 35608 {}} {131472 29977 {}} {131476 9242 {}} {131480 4635 {}} {131484 268062 {}} {131488 395295 {}} {131492 13312 {}} {131496 40705 {}} {131500 19202 {}} {131504 18947 {}} {131508 11780 {}} {131512 18181 {}} {131516 10758 {}} {131520 2823 {}} {131524 27656 {}} {131528 39177 {}} {131532 18443 {}} {131536 41741 {}} {131540 2319 {}} {131544 528 {}} {131548 43025 {}} {131552 40466 {}} {131556 276 {}} {131560 12565 {}} {131564 22806 {}} {131568 16151 {}} {131572 45848 {}} {131576 2585 {}} {131580 19226 {}} {131584 41243 {}} {131588 307487 {}} {131592 398112 {}} {20 1 FEC_CODE} {12 0 AXIS_WIDTH}} \
    ] [get_bd_cells $DUT]

################################################################################
# mng_axi - AXI4 VIP for configuration
################################################################################

ad_ip_instance axi_vip mng_axi
adi_sim_add_define "MNG_AXI=mng_axi"
set_property -dict [list CONFIG.ADDR_WIDTH {32} \
                         CONFIG.ARUSER_WIDTH {0} \
                         CONFIG.AWUSER_WIDTH {0} \
                         CONFIG.BUSER_WIDTH {0} \
                         CONFIG.DATA_WIDTH {32} \
                         CONFIG.HAS_BRESP {1} \
                         CONFIG.HAS_BURST {0} \
                         CONFIG.HAS_CACHE {0} \
                         CONFIG.HAS_LOCK {0} \
                         CONFIG.HAS_PROT {1} \
                         CONFIG.HAS_QOS {0} \
                         CONFIG.HAS_REGION {0} \
                         CONFIG.HAS_RRESP {1} \
                         CONFIG.HAS_WSTRB {1} \
                         CONFIG.ID_WIDTH {0} \
                         CONFIG.INTERFACE_MODE {MASTER} \
                         CONFIG.PROTOCOL {AXI4LITE} \
                         CONFIG.READ_WRITE_MODE {READ_WRITE} \
                         CONFIG.RUSER_BITS_PER_BYTE {0} \
                         CONFIG.RUSER_WIDTH {0} \
                         CONFIG.SUPPORTS_NARROW {0} \
                         CONFIG.WUSER_BITS_PER_BYTE {0} \
                         CONFIG.WUSER_WIDTH {0}] [get_bd_cells mng_axi]


# Connect AXI VIP to DUT
ad_connect mng_axi/M_AXI $DUT/S_AXI

create_bd_addr_seg -range 0x00040000 -offset 0x44000000 \
    [get_bd_addr_spaces mng_axi/Master_AXI] \
    [get_bd_addr_segs $DUT/S_AXI/PARAMS] \
    [format "SEG_%s_axi_lite" $DUT]
adi_sim_add_define "SDFEC_BA=[format "%d" 0x44000000]"

# Connect clocks

ad_connect sys_clk_vip/clk_out $DUT/s_axi_aclk
ad_connect sys_clk_vip/clk_out mng_axi/aclk

ad_connect sys_rst_vip/rst_out $DUT/reset_n
ad_connect sys_rst_vip/rst_out mng_axi/aresetn

ad_connect core_clk_vip/clk_out $DUT/core_clk


################################################################################
# Data in and out AXI stream verification IP
################################################################################

proc configure_axis_vip {name type tready tlast bytes} {
    ad_ip_instance axi4stream_vip $name
    adi_sim_add_define [format "%s=%s" [string toupper $name] $name]

    ad_ip_parameter $name CONFIG.INTERFACE_MODE $type
    ad_ip_parameter $name CONFIG.HAS_TREADY $tready
    ad_ip_parameter $name CONFIG.HAS_TLAST $tlast
    ad_ip_parameter $name CONFIG.TDATA_NUM_BYTES $bytes

    ad_connect core_clk_vip/clk_out $name/aclk
    ad_connect core_rst_vip/rst_out $name/aresetn
}

configure_axis_vip din_axis MASTER 1 1 16
configure_axis_vip ctrl_axis MASTER 1 0 4
configure_axis_vip dout_axis SLAVE 1 1 16
configure_axis_vip status_axis SLAVE 1 0 4

ad_connect din_axis/M_AXIS $DUT/S_AXIS_DIN
ad_connect ctrl_axis/M_AXIS $DUT/S_AXIS_CTRL
ad_connect $DUT/M_AXIS_DOUT dout_axis/S_AXIS
ad_connect $DUT/M_AXIS_STATUS status_axis/S_AXIS

ad_connect core_clk_vip/clk_out $DUT/s_axis_ctrl_aclk
ad_connect core_clk_vip/clk_out $DUT/s_axis_din_aclk
ad_connect core_clk_vip/clk_out $DUT/m_axis_status_aclk
ad_connect core_clk_vip/clk_out $DUT/m_axis_dout_aclk

