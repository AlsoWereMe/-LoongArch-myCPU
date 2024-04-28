`timescale 1ns / 1ps
`include "defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/14 13:23:54
// Design Name: 
// Module Name: mem
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

/* 这个模块是存储器 */
/* 访存阶段的操作就是访问这个模块 */
module mem(
    input   logic                   rst,

    input   logic[`RegAddrWidth]    wd_i,
    input   logic[`RegDataWidth]    wdata_i,
    input   logic                   we_i,
    input   logic[`RehDataWidth]    hi_i,
    input   logic[`RehDataWidth]    lo_i,
    input   logic                   we_hilo_i,

    output  logic[`RegAddrWidth]    wd_o,
    output  logic[`RegDataWidth]    wdata_o,
    output  logic                   we_o,
    input   logic[`RehDataWidth]    hi_o,
    input   logic[`RehDataWidth]    lo_o,
    input   logic                   we_hilo_o
    );

    always_comb begin
        if (rst == `RstEnable) begin
            wd_o      = `ZeroWord;
            wdata_o   = `ZeroWord;
            we_o      = `WriteDisable;
            hi_o      = `ZeroWord;
            lo_o      = `ZeroWord;
            we_hilo_o = `WriteDisable;
        end else begin
            wd_o      = wd_i;
            wdata_o   = wdata_i;
            we_o      = we_i;
            hi_o      = hi_i;
            lo_o      = lo_i;
            we_hilo_o = we_hilo_i;
        end
    end
endmodule
