`timescale 1ns / 1ps
`include "defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/14 13:20:38
// Design Name: 
// Module Name: ex
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

/* 组合电路模块,传给访存阶段的信息由下一个中继模块ex_mem操作 */
module ex(
    input   logic                   rst,
    input   logic[`AluOpBus]        aluop_i,
    input   logic[`AluSelBus]       alusel_i,
    input   logic[`RegDataWidth]    reg1_i,
    input   logic[`RegDataWidth]    reg2_i,
    input   logic[`RegAddrWidth]    wd_i,
    input   logic                   we_i,

    /* 执行后的结果在wdata_o内 */
    output  logic[`RegDataWidth]    wdata_o,
    output  logic[`RegAddrWidth]    wd_o,
    output  logic                   we_o
    );

    /* 保存逻辑与移位运算的结果 */
    logic[`RegDataWidth]    logic_o;
    logic[`RegDataWidth]    shiftres;

    // Part1:逻辑计算
    always_comb begin
        if(rst == `RstEnable) begin
            logic_o = `ZeroWord;
        end else begin
            /* 判断&计算 */
            case (aluop_i)
                `EXE_OR_OP: begin
                    logic_o = reg1_i | reg2_i;
                end
                `EXE_AND_OP: begin
                    logic_o = reg1_i & reg2_i;
                end
                `EXE_XOR_OP: begin
                    logic_o = reg1_i ^ reg2_i;
                end
                `EXE_NOR_OP: begin
                    logic_o = ~(reg1_i | reg2_i);
                end
                default: begin
                    logic_o = `ZeroWord;
                end
            endcase

        end
    end

    // Part2:移位运算
    always_comb begin
        if(rst == `RstEnable) begin
            shiftres = `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP: begin
                    shiftres = reg2_i <<  reg1_i[4:0];
                end
                `EXE_SRL_OP: begin
                    shiftres = reg2_i >>  reg1_i[4:0];
                end
                `EXE_SRA_OP: begin
                    shiftres = reg2_i >>> reg1_i[4:0];
                end
                default: begin
                    shiftres = `ZeroWord;
                end
            endcase

        end
    end

    // Part3:依据alusel指示的运算类型,选择一个运算结果作为最终结果
    always_comb begin
        /* 传值 */
        wd_o = wd_i;
        we_o = we_i;

        /* 判断具体类型 */
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o = logic_o;
            end
            `EXE_RES_SHIFT: begin
                wdata_o = shiftres;
            end 
            default: begin
                wdata_o = `ZeroWord;
            end
        endcase
    end
endmodule
