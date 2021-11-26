`include "utils.svh"

`define SD_FEC_ADDR_AXI_WR_PROTECT          32'h00000
`define SD_FEC_ADDR_CODE_WR_PROTECT         32'h00004
`define SD_FEC_ADDR_ACTIVE                  32'h00008
`define SD_FEC_ADDR_AXIS_WIDTH              32'h0000c
`define SD_FEC_ADDR_AXIS_ENABLE             32'h00010
`define SD_FEC_ADDR_FEC_CODE                32'h00014
`define SD_FEC_ADDR_ORDER                   32'h00018
`define SD_FEC_ADDR_INTERRUPT_STATUS        32'h0001c
`define SD_FEC_ADDR_INTERRUPT_ENABLE        32'h00020
`define SD_FEC_ADDR_INTERRUPT_DISABLE       32'h00024
`define SD_FEC_ADDR_INTERRUPT_MASK          32'h00028
`define SD_FEC_ADDR_ECC_INTERRUPT_STATUS    32'h0002c
`define SD_FEC_ADDR_ECC_INTERRUPT_ENABLE    32'h00030
`define SD_FEC_ADDR_ECC_INTERRUPT_DISABLE   32'h00034
`define SD_FEC_ADDR_ECC_INETRRUPT_MASK      32'h00038
`define SD_FEC_ADDR_BYPASS                  32'h0003c

`define SD_FEC_ADDR_LDPC_BASE               32'h02000

package sd_fec_pkg;

    import axi_vip_pkg::*;
    import reg_accessor_pkg::*;
    import logger_pkg::*;

    class sd_fec;
        reg_accessor    bus;
        xil_axi_ulong   base_address;

        function new (reg_accessor bus, xil_axi_ulong base_address);
            this.bus = bus;
            this.base_address = base_address;
        endfunction

        task read(xil_axi_ulong addr, output bit [31:0] bits);
            this.bus.RegRead32(this.base_address + addr, bits);
        endtask

        task set_axi_write_protection(input bit protect);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_AXI_WR_PROTECT, {31'h0, protect});
        endtask

        task set_code_write_protection(input bit protect);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_CODE_WR_PROTECT, {31'h0, protect});
        endtask

        task is_active(output bit active);
            this.bus.RegRead32(this.base_address + `SD_FEC_ADDR_ACTIVE, active);
        endtask

        task set_interface_widths(input bit dout_words,
                                  input bit [1:0] dout_lanes,
                                  input bit din_words,
                                  input bit [1:0] din_lanes);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_AXIS_WIDTH, {
                26'h0,
                dout_words,
                dout_lanes,
                din_words,
                din_lanes});
        endtask

        task set_axis_enable(input bit dout_words,
                             input bit dout,
                             input bit status,
                             input bit din_words,
                             input bit din,
                             input bit ctrl);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_AXIS_ENABLE, {
                26'h0,
                dout_words,
                dout,
                status,
                din_words,
                din,
                ctrl});
        endtask

        task set_fec_code(input bit fec_code);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_FEC_CODE, {31'h0, fec_code});
        endtask

        task set_out_of_order(input bit ooo);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_ORDER, {31'h0, ooo});
        endtask

        task clear_interrupt_status(input bit [5:0] bits);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_INTERRUPT_STATUS, {26'h0, bits});
        endtask

        task get_interrupt_status(output bit [5:0] bits);
            this.bus.RegRead32(this.base_address + `SD_FEC_ADDR_INTERRUPT_STATUS, bits);
        endtask

        task enable_interrupts(input bit [5:0] bits);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_INTERRUPT_ENABLE, {26'h0, bits});
        endtask

        task disable_interrupts(input bit [5:0] bits);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_INTERRUPT_DISABLE, {26'h0, bits});
        endtask

        task get_interrupt_mask(output bit [5:0] bits);
            this.bus.RegRead32(this.base_address + `SD_FEC_ADDR_INTERRUPT_MASK, bits);
        endtask

        task set_bypass(input bit bypass);
            this.bus.RegWrite32(this.base_address + `SD_FEC_ADDR_BYPASS, {31'h0, bypass});
        endtask

        task dump_core_params();
            reg [31:0] data;

            this.read(`SD_FEC_ADDR_AXI_WR_PROTECT, data);
            `INFO(("SD_FEC_ADDR_AXI_WR_PROTECT          = 0x%08x", data));

            this.read(`SD_FEC_ADDR_CODE_WR_PROTECT, data);
            `INFO(("SD_FEC_ADDR_CODE_WR_PROTECT         = 0x%08x", data));

            this.read(`SD_FEC_ADDR_ACTIVE, data);
            `INFO(("SD_FEC_ADDR_ACTIVE                  = 0x%08x", data));

            this.read(`SD_FEC_ADDR_AXIS_WIDTH, data);
            `INFO(("SD_FEC_ADDR_AXIS_WIDTH              = 0x%08x", data));

            this.read(`SD_FEC_ADDR_AXIS_ENABLE, data);
            `INFO(("SD_FEC_ADDR_AXIS_ENABLE             = 0x%08x", data));

            this.read(`SD_FEC_ADDR_FEC_CODE, data);
            `INFO(("SD_FEC_ADDR_FEC_CODE                = 0x%08x", data));

            this.read(`SD_FEC_ADDR_ORDER, data);
            `INFO(("SD_FEC_ADDR_ORDER                   = 0x%08x", data));

            this.read(`SD_FEC_ADDR_INTERRUPT_STATUS, data);
            `INFO(("SD_FEC_ADDR_INTERRUPT_STATUS        = 0x%08x", data));

            this.read(`SD_FEC_ADDR_INTERRUPT_ENABLE, data);
            `INFO(("SD_FEC_ADDR_INTERRUPT_ENABLE        = 0x%08x", data));

            this.read(`SD_FEC_ADDR_INTERRUPT_DISABLE, data);
            `INFO(("SD_FEC_ADDR_INTERRUPT_DISABLE       = 0x%08x", data));

            this.read(`SD_FEC_ADDR_INTERRUPT_MASK, data);
            `INFO(("SD_FEC_ADDR_INTERRUPT_MASK          = 0x%08x", data));

            this.read(`SD_FEC_ADDR_ECC_INTERRUPT_STATUS, data);
            `INFO(("SD_FEC_ADDR_ECC_INTERRUPT_STATUS    = 0x%08x", data));

            this.read(`SD_FEC_ADDR_ECC_INTERRUPT_ENABLE, data);
            `INFO(("SD_FEC_ADDR_ECC_INTERRUPT_ENABLE    = 0x%08x", data));

            this.read(`SD_FEC_ADDR_ECC_INTERRUPT_DISABLE, data);
            `INFO(("SD_FEC_ADDR_ECC_INTERRUPT_DISABLE   = 0x%08x", data));

            this.read(`SD_FEC_ADDR_ECC_INETRRUPT_MASK, data);
            `INFO(("SD_FEC_ADDR_ECC_INETRRUPT_MASK      = 0x%08x", data));

            this.read(`SD_FEC_ADDR_BYPASS, data);
            `INFO(("SD_FEC_ADDR_BYPASS                  = 0x%08x", data));

        endtask

        task dump_code(int id);
            reg [31:0] data;

            `INFO(("Dumping code: %d", id));

            this.bus.RegRead32(this.base_address + `SD_FEC_ADDR_LDPC_BASE + 32'h10 * id, data);
            `INFO((" REG0:"));
            `INFO(("  K                             = %d", data[30:16]));
            `INFO(("  N                             = %d", data[15:0]));

            this.bus.RegRead32(this.base_address + `SD_FEC_ADDR_LDPC_BASE + 32'h10 * id + 4, data);
            `INFO((" REG1:"));
            `INFO(("  SD data memory requirements   = 0x%x", data[19:11]));
            `INFO(("  NO_PACKING                    = %d", data[10]));
            `INFO(("  P                             = %d", data[9:0]));

            this.bus.RegRead32(this.base_address + `SD_FEC_ADDR_LDPC_BASE + 32'h10 * id + 8, data);
            `INFO((" REG2:"));
            `INFO(("  MAX_SCHEDULE                  = %d", data[24:23]));
            `INFO(("  NO_FINAL_PARITY_CHECK         = %d", data[22]));
            `INFO(("  SPECIAL_QC                    = %d", data[21]));
            `INFO(("  NORM_TYPE                     = %d", data[20]));
            `INFO(("  NMQC                          = %d", data[19:9]));
            `INFO(("  NLAYERS                       = %d", data[8:0]));

            this.bus.RegRead32(this.base_address + `SD_FEC_ADDR_LDPC_BASE + 32'h10 * id + 32'hc, data);
            `INFO((" REG3:"));
            `INFO(("  QC_OFF                        = 0x%x", data[26:16]));
            `INFO(("  LA_OFF                        = 0x%x", data[15:8]));
            `INFO(("  SC_OFF                        = 0x%x", data[7:0]));
        endtask

    endclass

endpackage
