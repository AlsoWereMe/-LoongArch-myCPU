/* 全局宏定义 */
`define RstEnable       1'b1            
`define RstDisable      1'b0
`define ZeroWord        32'h00000000        // 32位数值0
`define WriteEnable     1'b1
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0                // 译码阶段的输出aluop_o的宽度
`define AluOpBus        7:0                 // 译码阶段的输出alusel_o的宽度
`define AluSelBus       2:0
`define InstValid       1'b0
`define InstInvalid     1'b1
`define True_v          1'b1
`define False_v         1'b0
`define ChipEnable      1'b1
`define ChipDisable     1'b0

/* 指令宏定义 */
// ori
`define EXE_ORI         6'b001101
`define EXE_NOP         6'b000000

// AluOp
`define EXE_OR_OP       8'b00100101
`define EXE_NOP_OP      8'b00000000

// AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_NOP     3'b000

/* ROM宏定义 */
`define InstAddrWidth   31:0
`define InstDataWidth   31:0
`define InstMemNum      131071              // ROM实际大小，128KB
`define InstMemNumLog2  17                  // ROM实际使用的地址线宽度，17位

/* 通用寄存器宏定义 */
`define RegAddrWidth    4:0                 //  Regfile模块的地址线宽度
`define RegDataWidth    31:0                //  Regfile模块的数据线宽度
`define RegWidth        32                  //  通用寄存器的宽度
`define DoubleRegWidth  64
`define DoubleRegBus    63:0
`define RegNum          32
`define RegNumLog2      5                   // 取指时地址实际宽度
`define NOPRegAddr      5'b00000 