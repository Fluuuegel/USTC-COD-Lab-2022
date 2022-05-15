module cpu_pl(
    input clk,
    input rst,

    //io_bus
    output [31:0] io_addr,   //led和seg的地址
    output [31:0] io_dout,  //输出led和seg的数据
    output io_we,   //输出led和seg数据时的使能信号
    input [31:0] io_din,    //输出led和seg数据时的使能信号

    //debug_bus
    input [7:0] m_rf_addr,  //存储器（mem）或寄存器堆（rf）的调试读口地址
    output [31:0] rf_data,  //从rf读取的数据
    output [31:0] m_data,   //从mem读取的数据

    //PC/IF/ID
    output [31:0] pc_out,
    output [31:0] pcd,
    output [31:0] ir,
    output [31:0] pcin,

    //ID/EX
    output [31:0] pce,
    output [31:0] a,
    output [31:0] b,
    output [31:0] imm_debug,
    output [4:0] rd,
    output [31:0] ctrl,

    //EX/MEM
    output [31:0] y,
    output [31:0] bm,
    output [4:0] rdm,
    output [31:0] ctrlm,

    //MEM/WB
    output [31:0] yw,
    output [31:0] mdr,
    output [4:0] rdw,
    output [31:0] ctrlw
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

//5-stage pipeline
wire [31:0] IFIDpc;
wire [31:0] IFIDinst;

wire [31:0] IDEXpc;
wire [4:0] IDEXRd;
wire [31:0] IDEXImm;
wire [31:0] IDEXrf_rd0;
wire [31:0] IDEXrf_rd1;
wire IDEXrf_wr_en;
wire IDEXalu_a_sel;
wire IDEXalu_b_sel;
wire [1:0] IDEXalu_ctrl;
wire IDEXdm_rd_ctrl;
wire IDEXdm_wr_ctrl;
wire [1:0] IDEXrf_wr_sel;
wire [2:0] IDEXcomp_ctrl;
wire IDEXdo_branch;
wire IDEXdo_jump;

wire [31:0] EXMEMalu_out;
wire [31:0] EXMEMrf_rd1;
wire [4:0] EXMEMRd;
wire EXMEMrf_wr_en;
wire EXMEMdm_rd_ctrl;
wire EXMEMdm_wr_ctrl;
wire [1:0] EXMEMrf_wr_sel;
wire [31:0] EXMEMpc;

wire MEMWBrf_wr_en;
wire [1:0] MEMWBrf_wr_sel;
wire [31:0] MEMWBdm_dout;
wire [31:0] MEMWBalu_out;
wire [4:0] MEMWBRd;
wire [31:0] MEMWBpc;

//forwarding unit
wire [4:0] IDEXRs1;
wire [4:0] IDEXRs2;
wire [1:0] ForwardA;
wire [1:0] ForwardB;
reg [31:0] IDEXrf_rd0_fd;
reg [31:0] IDEXrf_rd1_fd;

forward forward(IDEXRs1, IDEXRs2, IDEXRd, EXMEMRd, MEMWBRd, EXMEMrf_wr_en, MEMWBrf_wr_en, ForwardA, ForwardB);

always@(*) begin
    case (ForwardA)
        2'b00: IDEXrf_rd0_fd = IDEXrf_rd0;
        2'b01: IDEXrf_rd0_fd = rf_wd;
        2'b10: IDEXrf_rd0_fd = EXMEMalu_out;
        default: IDEXrf_rd0_fd = IDEXrf_rd0;
    endcase

    case (ForwardB)
        2'b00: IDEXrf_rd1_fd = IDEXrf_rd1;
        2'b01: IDEXrf_rd1_fd = rf_wd;
        2'b10: IDEXrf_rd1_fd = EXMEMalu_out;
        default: IDEXrf_rd1_fd = IDEXrf_rd1;
    endcase
end

//hazard detection
wire PCWrite;
wire IFIDWrite;
wire stallpl;

wire dFlush;
wire eFlush;

hazard_detection hazard_detection(IDEXdm_rd_ctrl, IDEXRd, IFIDinst[19:15], IFIDinst[24:20], PCWrite, IFIDWrite, stallpl, branch, dFlush, eFlush);

reg rf_wr_en_hd;
reg dm_wr_ctrl_hd;
always@(*) begin
    if(stallpl) rf_wr_en_hd <= 1'b0;
    else rf_wr_en_hd <= rf_wr_en;
    if(stallpl) dm_wr_ctrl_hd <= 1'b0;
    else dm_wr_ctrl_hd <= dm_wr_ctrl;
end

//io_bus
assign dm_wr_ctrl_aft = (~(io_addr[10])) & EXMEMdm_wr_ctrl;  //AND gate
assign dm_dout_aft = io_addr[10] ? io_din : dm_dout;    //Mux
assign io_dout = rf_wd;
assign io_we = io_addr[10] & EXMEMdm_wr_ctrl;    //AND gate
assign io_addr = EXMEMalu_out;

assign alu_a = IDEXalu_a_sel ? IDEXrf_rd0_fd : IDEXpc;
assign alu_b = IDEXalu_b_sel ? IDEXImm : IDEXrf_rd1_fd;
assign pc_in = (pc >= 32'h3000 && pc <= 32'h33ff) ? pc : 32'h0;

assign pc_out = pc_in;
assign pcd = IFIDpc;
assign ir = IFIDinst;
assign pce = IDEXpc;
assign a = IDEXrf_rd0;
assign b = IDEXrf_rd1;
assign imm_debug = IDEXImm;
assign rd = IDEXRd;

wire fStall;
wire dStall;
assign fStall = !PCWrite;
assign dStall = !IFIDWrite;

assign ctrl = {fStall, dStall, dFlush, eFlush, 2'b0 , ForwardA , 2'b0, ForwardB, 1'b0, IDEXrf_wr_en, IDEXrf_wr_sel, 2'b0, IDEXdm_rd_ctrl, IDEXdm_wr_ctrl, 2'b0, IDEXdo_jump, IDEXdo_branch, 2'b0, alu_a_sel, alu_b_sel, 2'b0, alu_ctrl};

assign y = EXMEMalu_out;
assign bm = EXMEMrf_rd1;
assign rdm = EXMEMRd;
assign ctrlm = {30'b0, EXMEMdm_rd_ctrl, EXMEMdm_wr_ctrl};

assign yw = MEMWBalu_out;
assign mdr = MEMWBdm_dout;
assign rdw = MEMWBRd;
assign ctrlw = {29'b0, MEMWBrf_wr_en, MEMWBrf_wr_sel};

program_counter program_counter(clk, rst, branch, alu_out, PCWrite, pc, pcin, pc_plus4);

IFID IFID(clk, pc_in, inst, IFIDWrite, IFIDpc, IFIDinst, dFlush);

register_file register_file(.clk (clk), .rst (rst), .ra0 (IFIDinst[19:15]), .ra1 (IFIDinst[24:20]), .ra2 (m_rf_addr[4:0]), .wa (MEMWBRd), .wd (rf_wd), .we (MEMWBrf_wr_en), .rd0 (rf_rd0), .rd1 (rf_rd1), .rd2 (rf_data));

imm imm(.inst (IFIDinst), .imm_out (imm_out));

controller controller(IFIDinst, rf_wr_en, alu_a_sel, alu_b_sel, alu_ctrl, dm_rd_ctrl, dm_wr_ctrl, rf_wr_sel, comp_ctrl, do_branch, do_jump);

IDEX IDEX(clk, IFIDpc, IFIDinst[11:7], imm_out, rf_rd0, rf_rd1, rf_wr_en_hd, alu_a_sel, alu_b_sel, alu_ctrl, dm_rd_ctrl, dm_wr_ctrl_hd, rf_wr_sel, comp_ctrl, do_branch, do_jump, IDEXpc, 
IDEXRd, IDEXImm, IDEXrf_rd0, IDEXrf_rd1, IDEXrf_wr_en, IDEXalu_a_sel, IDEXalu_b_sel, IDEXalu_ctrl, IDEXdm_rd_ctrl, IDEXdm_wr_ctrl, IDEXrf_wr_sel, IDEXcomp_ctrl, IDEXdo_branch, IDEXdo_jump, 
IFIDinst[19:15], IFIDinst[24:20], eFlush, IDEXRs1, IDEXRs2);

alu alu(alu_a, alu_b, IDEXalu_ctrl, alu_out);

br br(.a (IDEXrf_rd0_fd), .b (IDEXrf_rd1_fd), .comp_ctrl (IDEXcomp_ctrl), .do_branch (IDEXdo_branch), .do_jump (IDEXdo_jump), .branch (branch));

EXMEM EXMEM(clk, alu_out, IDEXrf_rd1_fd, IDEXRd, IDEXpc, IDEXrf_wr_en, IDEXdm_rd_ctrl, IDEXdm_wr_ctrl, IDEXrf_wr_sel, EXMEMalu_out, EXMEMrf_rd1, EXMEMRd, EXMEMpc, EXMEMrf_wr_en, EXMEMdm_rd_ctrl, EXMEMdm_wr_ctrl, EXMEMrf_wr_sel);

ins_mem ins_mem(.a (pc_in[9:2]), .spo (inst));

data_mem data_mem(.a (EXMEMalu_out[9:2]), .d (EXMEMrf_rd1), .dpra (m_rf_addr), .clk (clk), .we (dm_wr_ctrl_aft), .spo (dm_dout), .dpo (m_data));

MEMWB MEMWB(clk, EXMEMrf_wr_en, EXMEMrf_wr_sel, dm_dout_aft, EXMEMalu_out, EXMEMRd, EXMEMpc, MEMWBrf_wr_en, MEMWBrf_wr_sel, MEMWBdm_dout, MEMWBalu_out, MEMWBRd, MEMWBpc);

//the last mux
always@(*) begin
    case (MEMWBrf_wr_sel)
        2'b00: rf_wd = 32'h0;
        2'b01: rf_wd = MEMWBpc + 32'h4;
        2'b10: rf_wd = MEMWBalu_out;
        2'b11: rf_wd = MEMWBdm_dout;  //2'b11: rf_wd = dm_dout_aft; 
        default: rf_wd = 32'h0;
    endcase
end

endmodule