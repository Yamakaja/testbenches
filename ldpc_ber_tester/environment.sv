`include "utils.svh"

package environment_pkg;

  import m_axi_sequencer_pkg::*;

  import logger_pkg::*;

  import axi_vip_pkg::*;
  import `PKGIFY(test_harness, mng_axi)::*;

  class environment;

    // agents and sequencers
    `AGENT(test_harness, mng_axi, mst_t) mng_agent;

    m_axi_sequencer  #(`AGENT(test_harness, mng_axi, mst_t)) mng;

    //============================================================================
    // Constructor
    //============================================================================
    function new (
      virtual interface axi_vip_if #(`AXI_VIP_IF_PARAMS(test_harness, mng_axi)) mng_vip_if
    );

      // creating the agents
      mng_agent = new("AXI Manager Agent", mng_vip_if);

      // create sequencers
      mng = new(mng_agent);

    endfunction

    //============================================================================
    // Start environment
    //   - Connect all the agents to the scoreboard
    //   - Start the agents
    //============================================================================
    task start();

      // start agents, one by one
      mng_agent.start_master();

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


      join_none
    endtask

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
    task run();
    endtask

    //============================================================================
    // Stop subroutine
    //============================================================================
    task stop;

      mng_agent.stop_master();

      post_test();
    endtask

  endclass

endpackage
