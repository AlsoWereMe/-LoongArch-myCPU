`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/03/24 23:00:48
// Design Name: 
// Module Name: rom
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

module rom (
    input logic ce,
    input logic [5:0] addr,  /* 要读取的指令地址 */
    output logic [31:0] inst  /* 取出的指令 */
);

  logic rom[63:0];

  always_comb begin
    if (ce == 1'b0) begin
      inst = 32'h0;
    end else begin
      inst = rom[addr];
    end
  end
endmodule
