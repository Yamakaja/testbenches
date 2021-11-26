`include "utils.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;

import environment_pkg::*;
import sd_fec_pkg::*;

module test_program ();

    environment env;
    sd_fec fec;

    initial begin
        env = new(`TH.`MNG_AXI.inst.IF,
                  `TH.`DIN_AXIS.inst.IF,
                  `TH.`CTRL_AXIS.inst.IF,
                  `TH.`DOUT_AXIS.inst.IF,
                  `TH.`STATUS_AXIS.inst.IF);
        fec = new(env.mng, `SDFEC_BA);

        env.din_axis_seq.configure(1, 0);
        env.ctrl_axis_seq.configure(1, 0);

        // env.din_axis_seq.enable();
        // env.ctrl_axis_seq.enable();

        env.dout_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);
        env.status_axis_seq.set_mode(XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE);

        setLoggerVerbosity(9);

        start_clocks;
        sys_reset;

        env.start();

        // Do stuff
        fec.enable_interrupts(6'h3f);
        fec.dump_core_params();
        fec.dump_code(0);

        // Enable AXIS Interfaces
        fec.set_interface_widths(0, 0, 0, 0);
        fec.set_axis_enable(0, 1, 1, 0, 1, 1);
        
        // Process sapmles
        env.run(0, 5040, 5940);
        #10
        fec.dump_core_params();

        #10000
        fec.dump_core_params();
        #1000

        env.stop();
        stop_clocks;

        `INFO(("Testbench done!"));
        $finish();
    end

    task start_clocks;
        #1
        `TH.`SYS_CLK.inst.IF.start_clock;
        #1
        `TH.`CORE_CLK.inst.IF.start_clock;
    endtask

    task stop_clocks;
        `TH.`SYS_CLK.inst.IF.stop_clock;
        `TH.`CORE_CLK.inst.IF.stop_clock;
    endtask

    task sys_reset;
        `TH.`SYS_RST.inst.IF.assert_reset;
        `TH.`CORE_RST.inst.IF.assert_reset;

        #500

        `TH.`SYS_RST.inst.IF.deassert_reset;
        `TH.`CORE_RST.inst.IF.deassert_reset;
    endtask

endmodule

