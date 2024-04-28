`timescale 1ns / 1ps
`include "defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/14 13:23:54
// Design Name: 
// Module Name: ex_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/* 执行-访存阶段的过渡 */
/* 每当一个上升沿到来,传值 */
module ex_mem(
    input   logic                   clk,
    input   logic                   rst,

    /* 执行阶段传入信息 */
    input   logic[`RegDataWidth]    ex_wdata,
    input   logic[`RegAddrWidth]    ex_wd,
    input   logic                   ex_we,
    input   logic[`RegDataWidth]    ex_hi,
    input   logic[`RegDataWidth]    ex_lo,
    input   logic                   ex_we_hilo,

    /* 传给访存阶段的信息 */
    output  logic[`RegDataWidth]    mem_wdata,
    output  logic[`RegAddrWidth]    mem_wd,
    output  logic                   mem_we,
    output  logic[`RegDataWidth]    mem_hi,
    output  logic[`RegDataWidth]    mem_lo,
    output  logic                   mem_we_hilo
    );

    always_ff @(posedge clk) begin
        if(rst == `RstEnable) begin
            mem_wd      <= `ZeroWord;
            mem_wdata   <= `ZeroWord;
            mem_we      <= `WriteDisable;
            mem_hi      <= `ZeroWord;
            mem_lo      <= `ZeroWord;
            mem_we_hilo <= `WriteDisable;
        end else begin
            mem_wd      <= ex_wd;
            mem_wdata   <= ex_wdata;
            mem_we      <= ex_we;
            mem_hi      <= ex_hi;
            mem_lo      <= ex_lo;
            mem_we_hilo <= ex_we_hilo;
        end
    end
endmodule
