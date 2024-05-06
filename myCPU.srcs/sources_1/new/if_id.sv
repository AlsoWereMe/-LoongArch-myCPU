`timescale 1ns / 1ps

/* 将从存储器中取出的指令暂存起来，下一个时钟周期到来时，将其传出，也就是说，"取指"这个操作,占用一个完整的时钟周期 */
module if_id(
    input logic         clk,
    input logic         rst,

    // 取指阶段取得的指令及其地址
    input logic[`InstAddrWidth]   if_pc,
    input logic[`InstDataWidth]   if_inst, // 将由指令存储器传入

    // 输出给译码阶段的指令及其地址
    output logic[`InstAddrWidth]  id_pc,
    output logic[`InstDataWidth]  id_inst
    );
    always_ff @(posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc   <= `ZeroWord;
            id_inst <= `ZeroWord;
        end else begin
            id_pc   <= if_pc;
            id_inst <= if_inst;
        end
        
    end
endmodule
