`timescale 1ns / 1ps

module hilo_reg(
    input   logic   clk,
    input   logic   rst,

    input   logic   we,
    input   logic[`RegDataWidth]    hi_i,
    input   logic[`RegDataWidth]    lo_i,

    output  logic[`RegDataWidth]    hi_o,
    output  logic[`RegDataWidth]    lo_o
    );

    logic[`RegDataWidth]    hi;
    logic[`RegDataWidth]    lo;
    assign hi_o = hi;
    assign lo_o = lo;
    
    always_ff @( posedge clk ) begin : FunctionPart
        if (rst == `RstEnable) begin
            hi <= `ZeroWord;
            lo <= `ZeroWord;
        end else if(we == `WriteEnable) begin
            // 假如复位无效且能写，存储新值并将新写入的值直接作为新值输出
            hi <= hi_i;
            lo <= lo_i;
        end
    end
endmodule
