`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/24 22:54:41
// Design Name: 
// Module Name: pc_reg
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

// pc负责给出取指令的地址，并提供ROM的使能信号
// 每个时钟周期取指令地址将递增

module pc_reg (
    input logic clk,
    input logic rst,
    output logic [5:0] pc,
    output logic ce
);

  always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
      ce <= 1'b0;
    end else begin
      ce <= 1'b1;
    end
  end

  always_ff @(posedge clk) begin
    if (ce == 1'b0) begin
      pc <= 6'h00;
    end else begin
      pc <= pc + 1'b1;
    end
  end
endmodule
