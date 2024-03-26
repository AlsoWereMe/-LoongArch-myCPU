# CPU开发记录



## defines

> 此模块为宏定义集成，有利于提高代码可读性

```verilog
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
`define InstAddrBus     31:0
`define InstBus         31:0
`define InstMemNum      131071              // ROM实际大小，128KB
`define InstMemNumLog2  17                  // ROM实际使用的地址线宽度，17位

/* 通用寄存器宏定义 */
`define RegAddrBus      4:0                 //  Regfile模块的地址线宽度
`define RegBus          31:0                //  Regfile模块的数据线宽度
`define RegWidth        32                  //  通用寄存器的宽度
`define DoubleRegWidth  64
`define DoubleRegBus    63:0
`define RegNum          32
`define RegNumLog2      5
`define NOPRegAddr      5'b00000 
```

> 随着进度推进，代码会补充，后同



## pc_reg

> PC模块

![image-20240326173425162](C:\Users\PATHF\AppData\Roaming\Typora\typora-user-images\image-20240326173425162.png)

```systemverilog
module pc_reg(
    input  logic                clk,
    input  logic                rst,
    output logic[`InstAddrBus]  pc,
    output logic                ce
    );

    always_ff @(posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable;
        end else begin
            ce <= `ChipEnable;
        end
    end

    always_ff @(posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= `ZeroWord;
        end else begin
            pc <= pc + 4'h4;            // 每个时钟周期，在指令存储器使能时，PC的值加4
        end 
    end
    
endmodule
```



## IF/ID

> IF/ID暂时保存取值阶段所取指令及其对应地址，在下一个时钟周期传递至译码阶段

![image-20240326173404698](C:\Users\PATHF\AppData\Roaming\Typora\typora-user-images\image-20240326173404698.png)

```systemverilog
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
```

