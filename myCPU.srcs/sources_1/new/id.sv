`timescale 1ns / 1ps
`include "defines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/13 17:17:00
// Design Name: 
// Module Name: id
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

module id(
    input logic                  rst,
    input logic [`InstAddrWidth] pc_i,
    input logic [`InstDataWidth] inst_i,

    // 寄存器堆有两个读端口,设置两个读端口输入
    input logic [`RegDataWidth] reg1_data_i,
    input logic [`RegDataWidth] reg2_data_i,

    // 输出给寄存堆的信息
    /* reg1_re_o是寄存器堆第一个读端口的使能端所接收的信号 */
    output logic                 reg1_re_o,
    output logic                 reg2_re_o,
    output logic [`RegAddrWidth] reg1_addr_o,
    output logic [`RegAddrWidth] reg2_addr_o,

    // 给执行阶段的信息
    /* aluop和alusel分别代表将要进行运算的子类型和类型 */
    /* 类型代表:逻辑,移位,算术等 */
    /* 子类型代表:或,与,异或等 */
    output logic [`AluOpBus] aluop_o,
    output logic [`AluSelBus] alusel_o,

    /* reg1_o和reg2_o代表的是源操作数1和2 */
    output logic [`RegDataWidth] reg1_o,
    output logic [`RegDataWidth] reg2_o,

    /* wd_o代表指令将要写入的寄存器地址,we_o代表是否要写入 */
    output logic [`RegAddrWidth] wd_o,
    output logic                 we_o
);

  // 运算指令涉及的每个部分
  logic[5:0] op;
  logic[4:0] sa;
  logic[5:0] func;
  logic[4:0] rs;
  logic[4:0] rt;
  logic[4:0] rd;

  // 赋值
  always_comb begin
    op   = inst_i[31:26];
    sa   = inst_i[10:6];
    func = inst_i[5:0];
    rs   = inst_i[25:21];
    rt   = inst_i[20:16];
    rd   = inst_i[15:11];
  end


  // 指令的立即数
  logic[`RegDataWidth]    imm;

  // 指令是否有效的代表
  logic inst_valid;

  // Part1:指令译码
  always_comb begin
    if (rst == `RstEnable) begin
        aluop_o     = `EXE_NOP_OP;
        alusel_o    = `EXE_RES_NOP;
        wd_o        = `NOPRegAddr;
        we_o        = `WriteDisable;
        inst_valid  = `InstValid;
        reg1_re_o   = `ReadDisable;
        reg2_re_o   = `ReadDisable;
        reg1_addr_o = `NOPRegAddr;
        reg2_addr_o = `NOPRegAddr;
        imm         = `ZeroWord;
    end else begin
        aluop_o     = `EXE_NOP_OP;
        alusel_o    = `EXE_RES_NOP;
        wd_o        = rd;
        we_o        = `WriteDisable;    /* 此时正在进行译码,直到译码完成为止,不能进行写入寄存器的操作 */
        inst_valid  = `InstInvalid;
        reg1_re_o   = `ReadDisable;     /* 同理不能对寄存器堆进行读出 */
        reg2_re_o   = `ReadDisable;
        reg1_addr_o = rs;               /* 默认rs对应寄存器1,rt对应寄存器2 */
        reg2_addr_o = rt;
        imm         = `ZeroWord;

        case (op)                           /* 判断当前指令类型 */
        `EXE_ORI:   begin               
            we_o  = `WriteEnable;

            /* 指明指令的类型与子类型 */
            aluop_o     = `EXE_OR_OP;
            alusel_o    = `EXE_RES_LOGIC;

            /* 读出寄存器1rs里的数据,不需要读出寄存器2rt里的数据 */
            reg1_re_o   = `ReadEnable;
            reg2_re_o   = `ReadDisable;
            reg1_addr_o = rs;
            reg2_addr_o = rt;

            /* 取得立即数 */
            imm = {16'h0,inst_i[15:0]};

            /* ORI指令,计算结果写入rt */
            wd_o = rt;

            /* 指令有效 */
            inst_valid = `InstValid;
        end 
        endcase
    end

  end

  // Part2:确定源操作数1 reg1_o
  always_comb begin
    if(rst == `RstEnable) begin
        reg1_o = `ZeroWord;
    end else if(reg1_re_o == `ReadEnable) begin
        reg1_o = reg1_data_i;
    end else if(reg1_re_o == `ReadDisable) begin
        reg1_o = imm;
    end else begin
        reg1_o = `ZeroWord;
    end
  end

  // Part3:确定源操作数2 reg2_o
  always_comb begin
    if(rst == `RstEnable) begin
        reg2_o = `ZeroWord;
    end else if(reg2_re_o == `ReadEnable) begin
        reg2_o = reg2_data_i;
    end else if(reg2_re_o == `ReadDisable) begin
        reg2_o = imm;
    end else begin
        reg2_o = `ZeroWord;
    end
  end

  /* Part2和Part3里的源操作数在读使能端不工作时用立即数取代 */
  /* 实际上源操作数1的读使能端不太会不工作,因为基本没有写入rs的指令 */
endmodule
