`timescale 1ns / 1ps

/* CPU顶层模块,在这里将每个模块连接 */
module myCPU(
    input   logic                   clk,
    input   logic                   rst,
    input   logic[`RegDataWidth]    rom_data_i,
    output  logic[`RegDataWidth]    rom_addr,
    output  logic                   rom_ce
    );

    // 定义驱动线变量

    /* rom -> if_id */
    logic   if_inst_i;

    /* pc_reg -> if_id */
    logic[`InstAddrWidth]   pc;
    
    /* if_id -> id */
    logic[`InstAddrWidth]   id_pc_i;  
    logic[`InstDataWidth]   id_inst_i;

    /* regfile -> id */
    logic[`RegDataWidth]    id_reg1_data_i;
    logic[`RegDataWidth]    id_reg2_data_i;

    /* id -> id_ex */
    logic[`AluOpBus]        id_aluop_o;
    logic[`AluSelBus]       id_alusel_o;
    logic[`RegDataWidth]    id_reg1_o;
    logic[`RegDataWidth]    id_reg2_o;
    logic[`RegAddrWidth]    id_wd_o;
    logic                   id_we_o;

    /* id -> regfile */
    logic[`RegAddrWidth]    id_reg1_addr_o;
    logic                   id_reg1_re_o;
    logic[`RegAddrWidth]    id_reg2_addr_o;
    logic                   id_reg2_re_o;

    /* id_ex -> ex */
    logic[`AluOpBus]        ex_aluop_i;
    logic[`AluSelBus]       ex_alusel_i;
    logic[`RegDataWidth]    ex_reg1_i;
    logic[`RegDataWidth]    ex_reg2_i;
    logic[`RegAddrWidth]    ex_wd_i;
    logic                   ex_we_i;

    /* ex -> ex_mem */
    logic[`RegDataWidth]    ex_wdata_o;   
    logic[`RegAddrWidth]    ex_wd_o;
    logic                   ex_we_o;

    /* ex_mem -> mem */
    logic[`RegDataWidth]    mem_wdata_i;   
    logic[`RegAddrWidth]    mem_wd_i;
    logic                   mem_we_i;

    /* mem -> mem_wb */
    logic[`RegDataWidth]    mem_wdata_o;   
    logic[`RegAddrWidth]    mem_wd_o;
    logic                   mem_we_o;

    /* mem_wb -> regfile */
    logic[`RegDataWidth]    wb_wdata_o;   
    logic[`RegAddrWidth]    wb_wd_o;
    logic                   wb_we_o; 

    /* ex -> ex_mem */
    logic[`RegDataWidth]    ex_hi_o;
    logic[`RegDataWidth]    ex_lo_o;
    logic                   ex_we_hilo_o;

    /* ex_mem -> mem */
    logic[`RegDataWidth]    mem_hi_i;
    logic[`RegDataWidth]    mem_lo_i;
    logic                   mem_we_hilo_i;
    
    /* mem -> mem_wb */
    logic[`RegDataWidth]    mem_hi_o;
    logic[`RegDataWidth]    mem_lo_o;
    logic                   mem_we_hilo_o;

    /* mem_wb -> hilo_reg */
    logic[`RegDataWidth]    wb_hi;
    logic[`RegDataWidth]    wb_lo;
    logic                   wb_we_hilo;

    /* hilo_reg -> ex*/
    logic[`RegDataWidth]    hilo_hi_o;
    logic[`RegDataWidth]    hilo_lo_o;

    // 实例化模块
    pc_reg my_pc_reg(
        .clk(clk),
        .rst(rst),

        .pc(pc),
        .ce(rom_ce)
        );
    /* pc代表指令的地址,故指令存储器的地址就是pc */
    assign rom_addr = pc;
    
    if_id my_if_id(
        .clk(clk),
        .rst(rst),
        .if_pc(pc),
        .if_inst(rom_data_i),

        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
    );

    id my_id(
        .rst(rst),
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),
        .reg1_data_i(id_reg1_data_i),
        .reg2_data_i(id_reg2_data_i),

        .aluop_o(id_aluop_o),
        .alusel_o(id_alusel_o),
        .reg1_o(id_reg1_o),
        .reg2_o(id_reg2_o),
        .wd_o(id_wd_o),
        .we_o(id_we_o),
        .reg1_addr_o(id_reg1_addr_o),
        .reg2_addr_o(id_reg2_addr_o),
        .reg1_re_o(id_reg1_re_o),
        .reg2_re_o(id_reg2_re_o)
    );

    id_ex my_id_ex(
        .clk(clk),
        .rst(rst),
        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wd(id_wd_o),
        .id_we(id_we_o),

        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wd(ex_wd_i),
        .ex_we(ex_we_i)
    );

    ex my_ex(
        .rst(rst),
        .aluop_i(ex_aluop_i),
        .alusel_i(ex_alusel_i),
        .reg1_i(ex_reg1_i),
        .reg2_i(ex_reg2_i),
        .wd_i(ex_wd_i),
        .we_i(ex_we_i),
        // HILO
        .hi_i(hilo_hi_o),
        .lo_i(hilo_lo_o),

        .wb_we_hilo_i(wb_we_hilo),
        .wb_hi_i(wb_hi),
        .wb_lo_i(wb_lo),

        .mem_we_hilo_i(mem_we_hilo_o),
        .mem_hi_i(mem_hi_o),
        .mem_lo_i(mem_lo_o),

        .hi_o(ex_hi_o),
        .lo_o(ex_lo_o),
        .we_hilo_o(ex_we_hilo_o),

        .wdata_o(ex_wdata_o),
        .wd_o(ex_wd_o),
        .we_o(ex_we_o)
    );

    ex_mem my_ex_mem(
        .clk(clk),
        .rst(rst),
        .ex_wdata(ex_wdata_o),
        .ex_wd(ex_wd_o),
        .ex_we(ex_we_o),
        // HILO
        .ex_we_hilo(ex_we_hilo_o),
        .ex_hi(ex_hi_o),
        .ex_lo(ex_lo_o),
        
        .mem_wdata(mem_wdata_i),
        .mem_wd(mem_wd_i),
        .mem_we(mem_we_i),
        // HILO
        .mem_we_hilo(mem_we_hilo_i),
        .mem_hi(mem_hi_i),
        .mem_lo(mem_lo_i)
    );

    mem my_mem(
        .rst(rst),
        .wd_i(mem_wd_i),
        .wdata_i(mem_wdata_i),
        .we_i(mem_we_i),
        // HILO
        .we_hilo_i(mem_we_hilo_i),
        .hi_i(mem_hi_i),
        .lo_i(mem_lo_i),

        .wd_o(mem_wd_o),
        .wdata_o(mem_wdata_o),
        .we_o(mem_we_o),
        // HILO
        .we_hilo_o(mem_we_hilo_o),
        .hi_o(mem_hi_o),
        .lo_o(mem_lo_o)
    );

    mem_wb my_mem_wb(
        .clk(clk),
        .rst(rst),
        .mem_wdata(mem_wdata_o),
        .mem_wd(mem_wd_o),
        .mem_we(mem_we_o),
        // HILO
        .mem_we_hilo(mem_we_hilo_o),
        .mem_hi(mem_hi_o),
        .mem_lo(mem_lo_o),
        
        .wb_wdata(wb_wdata_o),
        .wb_wd(wb_wd_o),
        .wb_we(wb_we_o),
        // HILO
        .wb_we_hilo(wb_we_hilo),
        .wb_hi(wb_hi),
        .wb_lo(wb_lo)
    );

    hilo_reg my_hilo_reg(
        .clk(clk),
        .rst(rst),
        .we(wb_we_hilo),
        .hi_i(wb_hi),
        .lo_i(wb_lo),

        .hi_o(hilo_hi_o),
        .lo_o(hilo_lo_o)
    );

    regfile my_reg(
        .clk(clk),
        .rst(rst),
        .we(wb_we_o),
        .waddr(wb_wd_o),
        .wdata(wb_wdata_o),
        .re1(id_reg1_re_o),
        .raddr1(id_reg1_addr_o),
        .re2(id_reg2_re_o),
        .raddr2(id_reg2_addr_o),

        .rdata1(id_reg1_data_i),
        .rdata2(id_reg2_data_i)
    );
endmodule
