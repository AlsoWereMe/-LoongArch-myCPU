`timescale 1ns / 1ps
`include "defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/26 17:32:27
// Design Name: 
// Module Name: if_id
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


module if_id(
    input logic         clk,
    input logic         rst,

    // 取指阶段取得的指令及其地址
    input logic[`InstAddrBus]   if_pc,
    input logic[`InstBus]       if_inst,

    // 输出给译码阶段的指令及其地址
    output logic[`InstAddrBus]  id_pc,
    output logic[`InstBus]      id_inst
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
