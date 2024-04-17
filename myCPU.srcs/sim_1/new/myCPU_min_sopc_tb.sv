`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/15 15:45:53
// Design Name: 
// Module Name: myCPU_min_sopc_tb
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


module myCPU_min_sopc_tb();
    logic   clk;
    logic   rst;

    always #10 clk = ~clk;

    initial begin
        // 初始化
        clk = 0;
        rst = 1;
        #100; // 等待一段时间

        // 释放复位
        rst = 0;

        // 观察输出或进行进一步的测试
        #1000; // 等待一段时间让系统运行

        $finish; // 结束仿真
    end

    myCPU_min_sop myCPU_min_sop0(
        .clk(clk),
        .rst(rst)
    );
endmodule
