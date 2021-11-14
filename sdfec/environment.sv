`include "utils.svh"

package environment_pkg;

  import m_axi_sequencer_pkg::*;
  import m_axis_sequencer_pkg::*;
  import s_axis_sequencer_pkg::*;

  import logger_pkg::*;

  import axi_vip_pkg::*;
  import axi4stream_vip_pkg::*;
  import `PKGIFY(test_harness, mng_axi)::*;
  import `PKGIFY(test_harness, din_axis)::*;
  import `PKGIFY(test_harness, dout_axis)::*;
  import `PKGIFY(test_harness, ctrl_axis)::*;
  import `PKGIFY(test_harness, status_axis)::*;

  class environment;

    // agents and sequencers
    `AGENT(test_harness, mng_axi, mst_t) mng_agent;
    `AGENT(test_harness, din_axis, mst_t) din_axis_agent;
    `AGENT(test_harness, dout_axis, slv_t) dout_axis_agent;
    `AGENT(test_harness, ctrl_axis, mst_t) ctrl_axis_agent;
    `AGENT(test_harness, status_axis, slv_t) status_axis_agent;

    m_axi_sequencer  #(`AGENT(test_harness, mng_axi, mst_t)) mng;
    m_axis_sequencer #(`AGENT(test_harness, din_axis, mst_t),
                       `AXIS_VIP_PARAMS(test_harness, din_axis)
                      ) din_axis_seq;
    m_axis_sequencer #(`AGENT(test_harness, ctrl_axis, mst_t),
                       `AXIS_VIP_PARAMS(test_harness, ctrl_axis)
                      ) ctrl_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, dout_axis, slv_t)) dout_axis_seq;
    s_axis_sequencer #(`AGENT(test_harness, status_axis, slv_t)) status_axis_seq;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, mng_axi)) mng_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, din_axis)) din_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, ctrl_axis)) ctrl_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, dout_axis)) dout_axis_vip_if,
      virtual interface axi4stream_vip_if #(`AXIS_VIP_IF_PARAMS(test_harness, status_axis)) status_axis_vip_if
    );

      // creating the agents
      mng_agent = new("AXI Manager Agent", mng_vip_if);
      din_axis_agent = new("DIN AXI Stream Agent", din_axis_vip_if);
      ctrl_axis_agent = new("Control AXI Stream Agent", ctrl_axis_vip_if);
      dout_axis_agent = new("DOUT AXI Stream Agent", dout_axis_vip_if);
      status_axis_agent = new("Status AXI Stream Agent", status_axis_vip_if);

      // create sequencers
      mng = new(mng_agent);
      din_axis_seq = new(din_axis_agent);
      ctrl_axis_seq = new(ctrl_axis_agent);
      dout_axis_seq = new(dout_axis_agent);
      status_axis_seq = new(status_axis_agent);

    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();

      // start agents, one by one
      mng_agent.start_master();
      din_axis_agent.start_master();
      ctrl_axis_agent.start_master();
      dout_axis_agent.start_slave();
      status_axis_agent.start_slave();

    endtask

    //============================================================================
    // Start the test
    //   - start the RX scoreboard and sequencer
    //   - start the TX scoreboard and sequencer
    //   - setup the RX DMA
    //   - setup the TX DMA
    //============================================================================
    task test();
      fork

        din_axis_seq.run();
        ctrl_axis_seq.run();
        dout_axis_seq.run();
        status_axis_seq.run();

      join_none
    endtask


    //============================================================================
    // Generate a data stream as an ADC
    //
    //   - clock to data rate ratio is 1
    //
    //============================================================================

    //============================================================================
    // Post test subroutine
    //============================================================================
    task post_test();
      // Evaluate the scoreboard's results
      fork
        // scoreboard.post_test();
      join
    endtask

    //============================================================================
    // Run subroutine
    //============================================================================
    task run;
      //pre_test();
      test();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;
      din_axis_seq.stop();
      ctrl_axis_seq.stop();

      din_axis_agent.stop_master();
      ctrl_axis_agent.stop_master();

      dout_axis_agent.stop_slave();
      status_axis_agent.stop_slave();

      mng_agent.stop_master();

      post_test();
    endtask

  endclass

endpackage
