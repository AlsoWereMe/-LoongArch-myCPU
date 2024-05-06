`timescale 1ns / 1ps

module inst_rom(
    input   logic                   ce,
    input   logic[`InstAddrWidth]   addr,
    output  logic[`InstDataWidth]   inst
    );

    /* 指令存储器数组 */
    reg[`InstDataWidth] inst_mem[`InstMemNum];

    /* 利用data文件初始化存储器数组,这是仿真用法 */
    initial begin
        $readmemh   ("inst_rom_init.mem",inst_mem);
    end

    always_comb begin
        if(ce == `ChipDisable) begin
            inst = `ZeroWord;
        end else begin
            /* MIPS用字节寻址,指令给出的地址每加1代表偏移一个字节,而每一条指令四个字节 */
            /* 于是,对于给出的地址addr,假如他是0x4,他代表指令存储器里的第二条指令,也即inst_mem[1] */
            /* 我们实际使用17bit来寻址 */
            /* 所以寻址时,需要将addr除4,也即右移2位然后取低17位 */
            /* 反映在代码上就是addr[`InstMemNumLog2 + 1:2] */
            /* 它等价于(addr >> 2)[`InstMemNumLog2:0] */
            inst = inst_mem[addr[`InstMemNumLog2 + 1:2]];
        end
    end
endmodule
