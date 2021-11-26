`include "utils.svh"

import axi_vip_pkg::*;
import logger_pkg::*;

import environment_pkg::*;
import sd_fec_pkg::*;
import ldpc_ber_tester_pkg::*;

module test_program ();

    environment env;
    sd_fec fec;
    ldpc_ber_tester ber;

    initial begin
        env = new (`TH.`MNG_AXI.inst.IF);
        fec = new (env.mng, `SDFEC_BA);
        ber = new (env.mng, `LDPC_BER_BA);

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


        setup_ldpc_ber_tester();
        
        // Process sapmles
        env.run();
        ber.set_en(1);
        
        #10
        fec.dump_core_params();

        #10000

        ber.set_en(0);
        #1000

        ber.dump_core_params();
        fec.dump_core_params();

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
    
    task setup_ldpc_ber_tester;
        ber.set_scratch(32'hCAFEBABE);
        ber.set_sdfec_control_word(
            0,   /* id */
            16,  /* max_iterations */
            1,   /* term_on_no_change */
            1,   /* term_on_pass */
            0,   /* include_parity_op */
            1,   /* hard_op */
            0    /* code_id */
        );
        
        ber.set_awgn_config(16'h020, -8'h10); // x*0.25-4
        ber.set_last_mask(~(128'h0));

        ber.dump_core_params();
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

