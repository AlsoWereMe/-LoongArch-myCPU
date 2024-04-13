# CPU开发记录

## CPU模块连接图

​	![image-20240413153516653](C:\Users\PATHF\AppData\Roaming\Typora\typora-user-images\image-20240413153516653.png)

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



---

---

接下来是译码阶段相关模块实现

## Regfile

> 寄存器模块，32个32位通用整数寄存器

接口如下

![image-20240327123458231](C:\Users\PATHF\AppData\Roaming\Typora\typora-user-images\image-20240327123458231.png)

![image-20240327123512197](C:\Users\PATHF\AppData\Roaming\Typora\typora-user-images\image-20240327123512197.png)

```systemverilog
module regfile(
    input  logic                clk,
    input  logic                rst,

    // 写端口
    input  logic                we,    // 写使能
    input  logic[`RegAddrBus]   waddr, // 写入的地址
    input  logic[`RegBus]       wdata, // 写入的数据

    // 读端口1
    input  logic                re1,
    input  logic[`RegAddrBus]   raddr1,
    output logic[`RegBus]       rdata1,

    // 读端口2
    input  logic                re2,
    input  logic[`RegAddrBus]   raddr2,
    output logic[`RegBus]       rdata2
    );

    // 定义寄存器
    reg[`RegBus] regs[`RegNum];

    // 写端口之逻辑
    always_ff @(posedge clk) begin
        if(rst == `RstEnable) begin
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
```



## id

> 译码器核心部件,翻译指令的模块

![image-20240413171115592](C:\Users\PATHF\AppData\Roaming\Typora\typora-user-images\image-20240413171115592.png)

![image-20240413171122830](C:\Users\PATHF\AppData\Roaming\Typora\typora-user-images\image-20240413171122830.png)

```systemverilog
module id (
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
    output logic [`RegAddrWidth] aluop_o,
    output logic [`RegAddrWidth] alusel_o,

    /* reg1_o和reg2_o代表的是源操作数1和2 */
    output logic [`RegDataWidth] reg1_o,
    output logic [`RegDataWidth] reg2_o,

    /* wd_o代表指令将要写入的寄存器地址,wreg_o代表是否要写入 */
    output logic [`RegAddrWidth] wd_o,
    output logic                 wreg_o
);

  // 运算指令涉及的每个部分
  logic[5:0] op   = inst_i[31:26];
  logic[4:0] sa   = inst_i[10:6];
  logic[5:0] func = inst_i[5:0];
  logic[4:0] rs   = ints_i[25:21];
  logic[4:0] rt   = inst_i[20:16];
  logic[4:0] rd   = inst_i[15:11];

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
        wreg_o      = `WriteDisable;
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
        wreg_o      = `WriteDisable;    /* 此时正在进行译码,直到译码完成为止,不能进行写入寄存器的操作 */
        inst_valid  = `InstInvalid;
        reg1_re_o   = `ReadDisable;     /* 同理不能对寄存器堆进行读出 */
        reg2_re_o   = `ReadDisable;
        reg1_addr_o = rs;               /* 默认rs对应寄存器1,rt对应寄存器2 */
        reg2_addr_o = rt;
        imm         = `ZeroWord;

        case (op)                           /* 判断当前指令类型 */
        `EXE_ORI:   begin               
            wreg_o  = `WriteEnable;

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
    end eles if(reg1_re_o == `ReadDisable) begin
        reg1_o = imm;
    end else begin
        reg1_o = `ZeroWord;
    end
        
  end

  // Part3:确定源操作数2 reg2_o
  always_comb begin
    if(rst == `RstEnable) begin
        reg2_o = `ZeroWord;
    end else if(reg1_re_o == `ReadEnable) begin
        reg2_o = reg2_data_i;
    end eles if(reg2_re_o == `ReadDisable) begin
        reg2_o = imm;
    end else begin
        reg2_o = `ZeroWord;
    end
  end

  /* Part2和Part3里的源操作数在读使能端不工作时用立即数取代 */
  /* 实际上源操作数1的读使能端不太会不工作,因为基本没有写入rs的指令 */
endmodule
```



## id_ex

> 译码到执行阶段的中继模块,暂存id传来的信息,在时钟周期更替的时候传至执行阶段

![image-20240413175202000](C:\Users\PATHF\AppData\Roaming\Typora\typora-user-images\image-20240413175202000.png)

代码如下

```systemverilog
module id_ex(
    input   logic   clk,
    input   logic   rst,

    /* 译码阶段信息 */
    input   logic[`AluOpBus]        id_aluop,
    input   logic[`AluSelBus]       id_alusel,
    input   logic[`RegDataWidth]    id_reg1,
    input   logic[`RegDataWidth]    id_reg2,
    input   logic[`RegAddrWidth]    id_wd,
    input   logic    id_we,

    /* 执行阶段信息 */
    output  logic[`AluOpBus]        ex_aluop,
    output  logic[`AluSelBus]       ex_alusel,
    output  logic[`RegDataWidth]    ex_reg1,
    output  logic[`RegDataWidth]    ex_reg2,
    output  logic[`RegAddrWidth]    ex_wd,
    output  logic    ex_we
);

always_ff @(posedge clk) begin
    if(rst == `RstEnable) begin
        ex_aluop    <= `EXE_NOP_OP;
        ex_alusel   <= `EXE_RES_NOP;
        ex_reg1     <= `ZeroWord;
        ex_reg2     <= `ZeroWord;
        ex_wd       <= `NOPRegAddr;
        ex_we       <= `WriteDisable;
    end else begin
        ex_aluop    <= id_aluop;
        ex_alusel   <= id_alusel;
        ex_reg1     <= id_reg1;
        ex_reg2     <= id_reg2;
        ex_wd       <= id_wd;
        ex_we       <= id_we;
    end
end
endmodule
```

