module cpu(
    input clk,
    input rst,

    //io_bus
    output [7:0] io_addr,   //led和seg的地址
    output [31:0] io_dout,  //输出led和seg的数据
    output io_we,   //输出led和seg数据时的使能信号
    input [31:0] io_din,    //输出led和seg数据时的使能信号

    //debug_bus
    input [7:0] m_rf_addr,  //存储器（mem）或寄存器堆（rf）的调试读口地址
    output [31:0] rf_data,  //从rf读取的数据
    output [31:0] m_data,   //从mem读取的数据
    output [31:0] pc_out    //pc的内容
);

wire branch;
wire [31:0] pc;
wire [31:0] pc_in;
wire [31:0] pc_plus4;
wire [31:0] inst;
wire [31:0] imm_out;
wire rf_wr_en;
wire alu_a_sel;
wire alu_b_sel;
wire [1:0] alu_ctrl;
wire dm_rd_ctrl;
wire dm_wr_ctrl;
wire dm_wr_ctrl_aft;
wire [1:0] rf_wr_sel;
wire [2:0] comp_ctrl;
wire do_branch;
wire do_jump;

reg [31:0] rf_wd;
wire [31:0] rf_rd0, rf_rd1;
wire [31:0] alu_a, alu_b, alu_out;
wire [31:0] dm_dout;
wire [31:0] dm_dout_aft;

assign alu_a = alu_a_sel ? rf_rd0 : pc;
assign alu_b = alu_b_sel ? imm_out : rf_rd1;
assign pc_in = (pc >= 32'h3000 && pc <= 32'h33ff) ? pc : 32'h0;
assign pc_out = pc_in;

//io_bus
assign dm_wr_ctrl_aft = (~(alu_out[10])) & dm_wr_ctrl;  //AND gate
assign dm_dout_aft = alu_out[10] ? io_din : dm_dout;    //Mux
assign io_dout = rf_rd1;
assign io_we = alu_out[10] & dm_wr_ctrl;    //AND gate
assign io_addr = alu_out[7:0];

program_counter program_counter(
    clk,
    rst,
    branch,
    alu_out,
    pc,
    pc_plus4
);

alu alu(
    alu_a,
    alu_b,
    alu_ctrl,
    alu_out
);

register_file register_file(
    .clk (clk),
    .rst (rst),
    .ra0 (inst[19:15]),
    .ra1 (inst[24:20]),
    .ra2 (m_rf_addr[4:0]),
    .wa (inst[11:7]),
    .wd (rf_wd),
    .we (rf_wr_en),
    .rd0 (rf_rd0),
    .rd1 (rf_rd1),
    .rd2 (rf_data)
);

imm imm(
    .inst (inst),
    .imm_out (imm_out)
);

br br(
    .a (rf_rd0), 
    .b (rf_rd1), 
    .comp_ctrl (comp_ctrl), 
    .do_branch (do_branch), 
    .do_jump (do_jump), 
    .branch (branch)
);

controller controller(
    inst, 
    rf_wr_en, 
    alu_a_sel, 
    alu_b_sel,
    alu_ctrl, 
    dm_rd_ctrl, 
    dm_wr_ctrl, 
    rf_wr_sel, 
    comp_ctrl, 
    do_branch, 
    do_jump
);

ins_mem ins_mem(
    .a (pc_in[9:2]), 
    .spo (inst)
);

data_mem data_mem(
    .a (alu_out[9:2]), 
    .d (rf_rd1), 
    .dpra (m_rf_addr), 
    .clk (clk), 
    .we (dm_wr_ctrl_aft), 
    .spo (dm_dout), 
    .dpo (m_data)
);

//Mux
always@(*) begin
    case (rf_wr_sel)
        2'b00: rf_wd = 32'h0;
        2'b01: rf_wd = pc_plus4;
        2'b10: rf_wd = alu_out;
        2'b11: rf_wd = dm_dout_aft; 
        default: rf_wd = 32'h0;
    endcase
end

endmodule