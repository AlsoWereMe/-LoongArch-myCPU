`timescale 1ns / 1ps

module myCPU_min_sop(
    input logic clk,
    input logic rst
    );


    logic[`InstAddrWidth]   inst_addr;
    logic[`InstDataWidth]   inst;
    logic                   rom_ce;

    myCPU myCPU0(
        .clk(clk),
        .rst(rst),
        .rom_addr(inst_addr),
        .rom_data_i(inst),
        .rom_ce(rom_ce)
    );

    inst_rom inst_rom0(
        .ce(rom_ce),
        .addr(inst_addr),
        .inst(inst)
    );
endmodule
