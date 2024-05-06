`timescale 1ns / 1ps

/* 这个模块是存储器 */
/* 访存阶段的操作就是访问这个模块 */
module mem(
    input   logic                   rst,

    input   logic[`RegAddrWidth]    wd_i,
    input   logic[`RegDataWidth]    wdata_i,
    input   logic                   we_i,
    input   logic[`RegDataWidth]    hi_i,
    input   logic[`RegDataWidth]    lo_i,
    input   logic                   we_hilo_i,

    output  logic[`RegAddrWidth]    wd_o,
    output  logic[`RegDataWidth]    wdata_o,
    output  logic                   we_o,
    output   logic[`RegDataWidth]    hi_o,
    output   logic[`RegDataWidth]    lo_o,
    output   logic                   we_hilo_o
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
