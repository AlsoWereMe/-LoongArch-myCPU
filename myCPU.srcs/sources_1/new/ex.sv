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

    /* HI与LO寄存器值，由HILO模块给出 */
    input   logic[`RegDataWidth]    hi_i,
    input   logic[`RegDataWidth]    lo_i,

    /* 回写模块导致的数据相关 */
    input   logic[`RegDataWidth]    wb_hi_i,
    input   logic[`RegDataWidth]    wb_lo_i,
    input   logic[`RegDataWidth]    wb_we_hilo_i,

    /* 访存阶段HILO导致的数据相关 */
    input   logic[`RegDataWidth]    mem_hi_i,
    input   logic[`RegDataWidth]    mem_lo_i,
    input   logic[`RegDataWidth]    mem_we_hilo_i,

    /* 执行阶段对HI,LO的写 */
    output  logic[`RegDataWidth]    hi_o,
    output  logic[`RegDataWidth]    lo_o,
    output  logic[`RegDataWidth]    we_hilo_o,

    /* 执行后的结果在wdata_o内 */
    output  logic[`RegDataWidth]    wdata_o,
    output  logic[`RegAddrWidth]    wd_o,
    output  logic                   we_o
    );

    /* 保存逻辑,移位与移动运算的结果 */
    logic[`RegDataWidth]    logic_o;
    logic[`RegDataWidth]    shiftres;
    logic[`RegDataWidth]    moveres;

    /* HI,LO是存储的输出给HILO模块的对应值 */
    logic[`RegDataWidth]    HI;
    logic[`RegDataWidth]    LO;

    // Part1:逻辑计算
    always_comb begin : Logic_Caculation
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
    always_comb begin : Shift_1_Caculation
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
    always_comb begin : Shift_2_Caculation
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
            `EXE_RES_MOVE: begin
                wdata_o = moveres;
            end
            default: begin
                wdata_o = `ZeroWord;
            end
        endcase
    end

    // Part4:HI,LO寄存器输入，直接将HI,LO的值由访存或回写阶段的输出值驱动以能够处理数据相关
    always_comb begin : HILO_DataDependency
        if (rst == `RstEnable) begin
            {HI,LO} = {`ZeroWord,`ZeroWord};
        end else if (mem_we_hilo_i == `WriteEnable) begin
            {HI,LO} = {mem_hi_i,mem_lo_i};
        end else if (wb_we_hilo_i == `WriteEnable) begin
            {HI,LO} = {wb_hi_i,wb_lo_i};
        end else begin
            {HI,LO} = {hi_i,lo_i};
        end
    end

    // Part5:MFHI,MFLO,MOVN,MOVZ
    always_comb begin : MFHI_MFLO_MOVN_MOVZ
        if (rst == `RstEnable) begin
            moveres = `ZeroWord;
        end else begin
            moveres = `ZeroWord;
            case (aluop_i)
                `EXE_MFHI_OP:   begin
                    moveres = HI;
                end
                `EXE_MFLO_OP:   begin
                    moveres = LO;
                end 
                // 在译码阶段就已经对reg1进行了确定是否要传入数据
                // 假如需要传入数据此时寄存器的使能端将被启用
                // 由MOV指令的格式可知只需要rs本身传入rd
                // 所以直接将reg1内的值（也即rs）作为结果即可
                `EXE_MOVN_OP:   begin
                    moveres = reg1_i;
                end
                `EXE_MOVZ_OP:   begin
                    moveres = reg1_i;
                end
                default:    begin
                    
                end
            endcase
        end
    end

    // Part6:MTHI,MTLO
    always_comb begin : MTHI_MTLO
        if (rst == `RstEnable) begin
            we_hilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end else if (aluop_i == `EXE_MTHI_OP) begin
            we_hilo_o = `WriteEnable;
            hi_o = reg1_i;
            lo_o = LO;
        end else if (aluop_i == `EXE_MTLO_OP) begin
            we_hilo_o = `WriteEnable;
            hi_o = HI;
            lo_o = reg1_i;
        end else begin
            we_hilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end
    end 
endmodule
