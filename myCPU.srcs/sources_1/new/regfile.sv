`timescale 1ns / 1ps

module regfile(
    input  logic                  clk,
    input  logic                  rst,

    // 写端口
    input  logic                  we,    // 写使能
    input  logic[`RegAddrWidth]   waddr, // 写入的地址
    input  logic[`RegDataWidth]   wdata, // 写入的数据

    // 读端口1
    input  logic                  re1,
    input  logic[`RegAddrWidth]   raddr1,
    output logic[`RegDataWidth]   rdata1,

    // 读端口2
    input  logic                  re2,
    input  logic[`RegAddrWidth]   raddr2,
    output logic[`RegDataWidth]   rdata2
    );

    // 定义寄存器
    reg[`RegDataWidth] regs[`RegNum];

    // 写端口之逻辑
    always_ff @(posedge clk) begin
        if(rst == `RstEnable) begin
            regs[0] = `ZeroWord;
            regs[1] = `ZeroWord;
            regs[2] = `ZeroWord;
            regs[3] = `ZeroWord;
            regs[4] = `ZeroWord;
        end else begin
            if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin                        // 若写入的寄存器不是0寄存器即可写入
                regs[waddr] <= wdata;
            end
        end
        
    end

    // 读端口1之逻辑
    always_comb begin
        if (rst == `RstEnable) begin
            rdata1 = `ZeroWord;
        end else if (raddr1 == `RegNumLog2'h0) begin                                            // 通用寄存器0恒存储0字
            rdata1 = `ZeroWord;
        end else if ((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin   // 读写端同时启用时
            rdata1 = wdata;
        end else if (re1 == `ReadEnable) begin
            rdata1 = regs[raddr1];
        end else begin
            rdata1 = `ZeroWord;
        end
    end

    // 读端口2之逻辑
    always_comb begin
        if (rst == `RstEnable) begin
            rdata2 = `ZeroWord;
        end else if (raddr2 == `RegNumLog2'h0) begin                                            
            rdata2 = `ZeroWord;
        end else if ((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin   
            rdata2 = wdata;
        end else if (re2 == `ReadEnable) begin
            rdata2 = regs[raddr2];
        end else begin
            rdata2 = `ZeroWord;
        end
    end
endmodule
