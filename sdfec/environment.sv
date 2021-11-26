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
  import `PKGIFY(test_harness, ctrl_axis)::*;
  import `PKGIFY(test_harness, dout_axis)::*;
  import `PKGIFY(test_harness, status_axis)::*;

  class environment;

    // agents and sequencers
    `AGENT(test_harness, mng_axi, mst_t) mng_agent;
    `AGENT(test_harness, din_axis, mst_t) din_axis_agent;
    `AGENT(test_harness, ctrl_axis, mst_t) ctrl_axis_agent;
    `AGENT(test_harness, dout_axis, slv_t) dout_axis_agent;
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
    // Generate data stream
    //============================================================================
    
    function generate_code_data(int K, int N, int width,
                                output xil_axi4stream_data_byte data[]);

        int total_bytes = N + width - N % width;
        data = new [total_bytes];

        for (int i = 0; i < N; i++)
            data[i] = -5;

        for (int i = N; i < total_bytes; i++)
            data[i] = 0;
    endfunction

    task write_data(xil_axi4stream_data_byte data[]);
        axi4stream_transaction transaction;
        xil_axi4stream_data_byte buffer[];
        for (int i = 0; i < data.size(); i += 16) begin
            transaction = din_axis_agent.driver.create_transaction();

            buffer = new [16];

            for (int j = 0; j < 16; j++)
                buffer[j] = data[i+j];

            transaction.set_data(buffer);
            // transaction.set_last(i + 16 >= data.size());
            transaction.set_last(0);
            transaction.set_delay(0);
            din_axis_agent.driver.send(transaction);
            `INFO(("Wrote up to byte %d", i + 16));
        end
    endtask

    function get_ctrl_word(bit [7:0] id,
                           bit [5:0] max_iterations,
                           bit       term_on_no_change,
                           bit       term_on_pass,
                           bit       include_parity_op,
                           bit       hard_op,
                           bit [6:0] code,
                           output xil_axi4stream_data_byte ret []);

        bit [31:0] ctrl_word;
        ret = new [4];
        
        ctrl_word = {
            id,
            max_iterations,
            term_on_no_change,
            term_on_pass,
            include_parity_op,
            hard_op,
            7'h0,
            code
        };
        ret[3] = ctrl_word[31:24];
        ret[2] = ctrl_word[23:16];
        ret[1] = ctrl_word[15:8];
        ret[0] = ctrl_word[7:0]; 
    endfunction


    task process_code_block(int code, int K, int N);
        xil_axi4stream_data_byte ctrl_word [];
        xil_axi4stream_data_byte code_data [];
        axi4stream_transaction transaction;

        get_ctrl_word(0, 8, 1, 1, 0, 1, code, ctrl_word);
        transaction = ctrl_axis_agent.driver.create_transaction();
        transaction.set_data(ctrl_word);
        transaction.set_delay(0);
        ctrl_axis_agent.driver.send(transaction);

        generate_code_data(K, N, 16, code_data);
        write_data(code_data);
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
    task run(int code, int K, int N);
        fork
            process_code_block(code, K, N);
        join_none
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
