`include "utils.svh"

`define LDPC_BER_ADDR_VERSION               32'h000000
`define LDPC_BER_ADDR_CORE_ID               32'h000004
`define LDPC_BER_ADDR_SCRATCH               32'h000008
`define LDPC_BER_ADDR_CORE_MAGIC            32'h00000c

`define LDPC_BER_ADDR_CONTROL               32'h000040
`define LDPC_BER_BIT_CONTROL_ENABLE         32'h000001
`define LDPC_BER_BIT_CONTROL_SW_RESETN      32'h000002
`define LDPC_BER_ADDR_AWGN_CONFIG           32'h000044
`define LDPC_BER_BIT_AWGN_CONFIG_FACTOR     32'h00ffff
`define LDPC_BER_BIT_AWGN_CONFIG_OFFSET     32'hff0000
`define LDPC_BER_ADDR_SDFEC_CONTROL_WORD    32'h00004c

`define LDPC_BER_ADDR_LAST_MASK_LSB         32'h000050

`define LDPC_BER_ADDR_FINISHED_BLOCKS_LSB   32'h000080
`define LDPC_BER_ADDR_FINISHED_BLOCKS_MSB   32'h000084

`define LDPC_BER_ADDR_BIT_ERRORS            32'h000088

package ldpc_ber_tester_pkg;

    import axi_vip_pkg::*;
    import reg_accessor_pkg::*;
    import logger_pkg::*;

    class ldpc_ber_tester;
        reg_accessor    bus;
        xil_axi_ulong   base_address;

        function new (reg_accessor bus, xil_axi_ulong base_address);
            this.bus = bus;
            this.base_address = base_address;
        endfunction

        task read(xil_axi_ulong addr, output bit [31:0] bits);
            this.bus.RegRead32(this.base_address + addr, bits);
        endtask

        task write(xil_axi_ulong addr, input bit [31:0] bits);
            this.bus.RegWrite32(this.base_address + addr, bits);
        endtask

        task get_version(output bit [31:0] bits);
            this.read(`LDPC_BER_ADDR_VERSION, bits);
        endtask

        task get_core_id(output bit [31:0] bits);
            this.read(`LDPC_BER_ADDR_CORE_ID, bits);
        endtask

        task get_scratch(output bit [31:0] bits);
            this.read(`LDPC_BER_ADDR_SCRATCH, bits);
        endtask

        task set_scratch(input bit [31:0] bits);
            this.write(`LDPC_BER_ADDR_SCRATCH, bits);
        endtask

        task get_magic(output bit [31:0] bits);
            this.read(`LDPC_BER_ADDR_CORE_MAGIC, bits);
        endtask

        task get_en(output bit en);
            bit [31:0] data;

            this.read(`LDPC_BER_ADDR_CONTROL, data);

            en = !(!(data & `LDPC_BER_BIT_CONTROL_ENABLE));
        endtask

        task set_en(input bit en);
            this.write(`LDPC_BER_ADDR_CONTROL, {31'h1, en});
        endtask

        task reset();
            bit [31:0] data;

            this.read(`LDPC_BER_ADDR_CONTROL, data);

            data = data & ~(`LDPC_BER_BIT_CONTROL_SW_RESETN);

            this.write(`LDPC_BER_ADDR_CONTROL, data);
        endtask

        task get_awgn_config(output bit [15:0] factor, output bit [7:0] offset);
            bit [31:0] data;

            this.read(`LDPC_BER_ADDR_AWGN_CONFIG, data);

            factor = data[15:0];
            offset = data[23:16];
        endtask

        task set_awgn_config(bit [15:0] factor, bit [7:0] offset);
            this.write(`LDPC_BER_ADDR_AWGN_CONFIG, {8'h0, offset, factor});
        endtask

        task get_sdfec_control_word(output bit [31:0] bits);
            this.read(`LDPC_BER_ADDR_SDFEC_CONTROL_WORD, bits);
        endtask

        task set_sdfec_control_word(input bit [7:0] id,
                                    input bit [5:0] max_iterations,
                                    input bit       term_on_no_change,
                                    input bit       term_on_pass,
                                    input bit       include_parity_op,
                                    input bit       hard_op,
                                    input bit [6:0] code);
            bit [31:0] ctrl_word = {
                id,
                max_iterations,
                term_on_no_change,
                term_on_pass,
                include_parity_op,
                hard_op,
                7'h0,
                code};

            this.write(`LDPC_BER_ADDR_SDFEC_CONTROL_WORD, ctrl_word);
        endtask

        task get_last_mask(output bit [127:0] bits);
            for (int i = 0; i < 4; i++)
                this.read(`LDPC_BER_ADDR_LAST_MASK_LSB + i*4, bits[32*i +: 32]);
        endtask

        task set_last_mask(input bit [127:0] bits);
            for (int i = 0; i < 4; i++)
                this.write(`LDPC_BER_ADDR_LAST_MASK_LSB + i*4, bits[32*i +: 32]);
        endtask

        task get_finished_blocks(output bit [63:0] bits);
            this.read(`LDPC_BER_ADDR_FINISHED_BLOCKS_LSB, bits[31:0]);
            this.read(`LDPC_BER_ADDR_FINISHED_BLOCKS_MSB, bits[63:32]);
        endtask

        task get_bit_errors(output bit [31:0] bits);
            this.read(`LDPC_BER_ADDR_BIT_ERRORS, bits);
        endtask

        task dump_core_params();
            reg [31:0] data;
            reg [127:0] mask;
            reg [63:0] finished_blocks;

            `INFO(("ldpc_ber_tester Core Parameters:"));

            this.read(`LDPC_BER_ADDR_VERSION, data);
            `INFO(("    LDPC_BER_ADDR_VERSION               = 0x%08x", data));
    
            this.read(`LDPC_BER_ADDR_CORE_ID, data);
            `INFO(("    LDPC_BER_ADDR_CORE_ID               = 0x%08x", data));
    
            this.read(`LDPC_BER_ADDR_SCRATCH, data);
            `INFO(("    LDPC_BER_ADDR_SCRATCH               = 0x%08x", data));
    
            this.read(`LDPC_BER_ADDR_CORE_MAGIC, data);
            `INFO(("    LDPC_BER_ADDR_CORE_MAGIC            = 0x%08x", data));
    
            this.read(`LDPC_BER_ADDR_CONTROL, data);
            `INFO(("    LDPC_BER_ADDR_CONTROL               = 0x%08x", data));
    
            this.read(`LDPC_BER_ADDR_AWGN_CONFIG, data);
            `INFO(("    LDPC_BER_ADDR_AWGN_CONFIG           = 0x%08x", data));
    
            this.read(`LDPC_BER_ADDR_SDFEC_CONTROL_WORD, data);
            `INFO(("    LDPC_BER_ADDR_SDFEC_CONTROL_WORD    = 0x%08x", data));
    
            for (int i = 0; i < 4; i++)
                this.read(`LDPC_BER_ADDR_LAST_MASK_LSB + i*4, mask[i * 32 +: 32]);
            `INFO(("    LDPC_BER_ADDR_LAST_MASK             = 0x%032x", mask));
    
            this.read(`LDPC_BER_ADDR_FINISHED_BLOCKS_LSB, finished_blocks[31:0]);
            this.read(`LDPC_BER_ADDR_FINISHED_BLOCKS_MSB, finished_blocks[63:32]);
            `INFO(("    LDPC_BER_ADDR_FINISHED_BLOCKS       = 0x%016x", finished_blocks));
    
            this.read(`LDPC_BER_ADDR_BIT_ERRORS, data);
            `INFO(("    LDPC_BER_ADDR_BIT_ERRORS            = 0x%08x", data));

        endtask

    endclass

endpackage
