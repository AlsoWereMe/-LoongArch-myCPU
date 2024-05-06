`timescale 1ns / 1ps

/* id_ex模块是译码到执行阶段的中继模块 */
/* 存储id模块向执行模块传递的信息，在下一个时钟周期到来时传给执行阶段 */
module id_ex(
    input   logic   clk,
    input   logic   rst,

    /* 译码阶段信息 */
    input   logic[`AluOpBus]        id_aluop,
    input   logic[`AluSelBus]       id_alusel,
    input   logic[`RegDataWidth]    id_reg1,
    input   logic[`RegDataWidth]    id_reg2,
    input   logic[`RegAddrWidth]    id_wd,
    input   logic    id_we,

    /* 执行阶段信息 */
    output  logic[`AluOpBus]        ex_aluop,
    output  logic[`AluSelBus]       ex_alusel,
    output  logic[`RegDataWidth]    ex_reg1,
    output  logic[`RegDataWidth]    ex_reg2,
    output  logic[`RegAddrWidth]    ex_wd,
    output  logic    ex_we
);

always_ff @(posedge clk) begin
    if(rst == `RstEnable) begin
        ex_aluop    <= `EXE_NOP_OP;
        ex_alusel   <= `EXE_RES_NOP;
        ex_reg1     <= `ZeroWord;
        ex_reg2     <= `ZeroWord;
        ex_wd       <= `NOPRegAddr;
        ex_we       <= `WriteDisable;
    end else begin
        ex_aluop    <= id_aluop;
        ex_alusel   <= id_alusel;
        ex_reg1     <= id_reg1;
        ex_reg2     <= id_reg2;
        ex_wd       <= id_wd;
        ex_we       <= id_we;
    end
end
endmodule
