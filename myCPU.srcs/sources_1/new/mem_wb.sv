`timescale 1ns / 1ps
`include "defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/14 13:23:54
// Design Name: 
// Module Name: mem_wb
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

/* 访存-写回 */
module mem_wb(
    input   logic                   rst,
    input   logic                   clk,

    input   logic[`RegDataWidth]    mem_wdata,
    input   logic[`RegAddrWidth]    mem_wd,
    input   logic                   mem_we,
    input   logic[`RegDataWidth]    mem_hi,
    input   logic[`RegDataWidth]    mem_lo,
    input   logic                   mem_we_hilo,

    output  logic[`RegDataWidth]    wb_wdata,
    output  logic[`RegAddrWidth]    wb_wd,
    output  logic                   wb_we,
    output  logic[`RegDataWidth]    wb_hi,
    output  logic[`RegDataWidth]    wb_lo,
    output  logic                   wb_we_hilo,
    );

    always_ff @(posedge clk) begin
        if(rst == `RstEnable) begin
            wb_wd       <= `ZeroWord;
            wb_wdata    <= `ZeroWord;
            wb_we       <= `WriteDisable;
            wb_hi       <= `ZeroWord;
            wb_lo       <= `ZeroWord;
            wb_we_hilo  <= `WriteDisable;
        end else begin
            wb_wd       <= mem_wd;
            wb_wdata    <= mem_wdata;
            wb_we       <= mem_we;
            wb_hi       <= mem_hi;
            wb_lo       <= mem_lo;
            wb_we_hilo  <= mem_we_hilo;
        end
    end
endmodule
