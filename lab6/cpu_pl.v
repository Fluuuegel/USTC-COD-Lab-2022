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
wire jump;
wire br_pred_f; //IF
wire br_pred_d; //ID
wire br_pred_e; //EX
wire [31:0] br_pred_pc_f;

wire [31:0] pc;
wire [31:0] pc_in;
wire [31:0] pc_plus4;
wire [31:0] inst;
wire [31:0] imm_out;
wire rf_wr_en;
wire alu_a_sel;
wire alu_b_sel;
wire [3:0] alu_ctrl;
wire [2:0] dm_rd_ctrl;
wire [1:0] dm_wr_ctrl;
wire [1:0] dm_wr_ctrl_aft;
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
wire [3:0] IDEXalu_ctrl;
wire [2:0] IDEXdm_rd_ctrl;
wire [1:0] IDEXdm_wr_ctrl;
wire [1:0] IDEXrf_wr_sel;
wire [2:0] IDEXcomp_ctrl;
wire IDEXdo_branch;
wire IDEXdo_jump;

wire [31:0] EXMEMalu_out;
wire [31:0] EXMEMrf_rd1;
wire [4:0] EXMEMRd;
wire EXMEMrf_wr_en;
wire [2:0] EXMEMdm_rd_ctrl;
wire [1:0] EXMEMdm_wr_ctrl;
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

forward forward(
    .IDEXRs1 (IDEXRs1), 
    .IDEXRs2 (IDEXRs2), 
    .IDEXRd (IDEXRd), 
    .EXMEMRd (EXMEMRd), 
    .MEMWBRd (MEMWBRd), 
    .EXMEMrf_wr_en (EXMEMrf_wr_en), 
    .MEMWBrf_wr_en (MEMWBrf_wr_en), 
    .ForwardA (ForwardA), 
    .ForwardB (ForwardB)
);

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
wire fStall;
wire dStall;
wire dFlush;
wire eFlush;

hazard_detection hazard_detection(
    .IDEXdm_rd_ctrl (IDEXdm_rd_ctrl), 
    .IDEXRd (IDEXRd), 
    .IFIDRs1 (IFIDinst[19:15]), 
    .IFIDRs2 (IFIDinst[24:20]), 
    .fStall (fStall), 
    .dStall (dStall), 
    .branch (branch), 
    .br_pred_e (br_pred_e), 
    .jump (jump), 
    .dFlush (dFlush), 
    .eFlush (eFlush)
);

//io_bus
assign dm_wr_ctrl_aft = (~(io_addr[10])) & EXMEMdm_wr_ctrl;  //AND gate
assign dm_dout_aft = (io_addr[10]) ? io_din : dm_dout;    //Mux
assign io_dout = rf_wd;
assign io_we = io_addr[10] & (|EXMEMdm_wr_ctrl);    //AND gate
assign io_addr = EXMEMalu_out;

assign alu_a = IDEXalu_a_sel ? IDEXrf_rd0_fd : IDEXpc;
assign alu_b = IDEXalu_b_sel ? IDEXImm : IDEXrf_rd1_fd;
assign pc_in = (pc >= 32'h3000 && pc <= 32'h33ff) ? pc : 32'h0;

//debug_bus
assign pc_out = pc_in;
assign pcd = IFIDpc;
assign ir = IFIDinst;
assign pce = IDEXpc;
assign a = IDEXrf_rd0;
assign b = IDEXrf_rd1;
assign imm_debug = IDEXImm;
assign rd = IDEXRd;
assign ctrl = {
    fStall,
    dStall,
    dFlush,
    eFlush,
    2'b0 ,
    ForwardA ,
    2'b0,
    ForwardB, 
    1'b0, 
    IDEXrf_wr_en, 
    IDEXrf_wr_sel, 
    IDEXdm_rd_ctrl, 
    IDEXdm_wr_ctrl, 
    2'b0, 
    IDEXdo_jump, 
    IDEXdo_branch, 
    2'b0, 
    alu_a_sel, 
    alu_b_sel, 
    alu_ctrl
};
assign y = EXMEMalu_out;
assign bm = EXMEMrf_rd1;
assign rdm = EXMEMRd;
assign ctrlm = {27'b0, EXMEMdm_rd_ctrl, EXMEMdm_wr_ctrl};
assign yw = MEMWBalu_out;
assign mdr = MEMWBdm_dout;
assign rdw = MEMWBRd;
assign ctrlw = {29'b0, MEMWBrf_wr_en, MEMWBrf_wr_sel};

program_counter program_counter(
    .clk (clk), 
    .rst (rst), 
    .br (branch), 
    .br_pred_e (br_pred_e), 
    .br_pred_f (br_pred_f),
    .br_pred_pc (br_pred_pc_f),
    .jump (jump),
    .alu_out (alu_out),
    .fStall (fStall),
    .pce (pce),
    .pc (pc),
    .pcin (pcin),
    .pc_plus4 (pc_plus4)
);

IFID IFID(
    .clk (clk), 
    .pc_in (pc_in), 
    .inst (inst), 
    .dStall (dStall), 
    .IFIDpc (IFIDpc), 
    .IFIDinst (IFIDinst), 
    .dFlush (dFlush), 
    .br_pred_f (br_pred_f), 
    .br_pred_d (br_pred_d)
);

register_file register_file(
    .clk (clk), 
    .rst (rst), 
    .ra0 (IFIDinst[19:15]), 
    .ra1 (IFIDinst[24:20]), 
    .ra2 (m_rf_addr[4:0]), 
    .wa (MEMWBRd), 
    .wd (rf_wd), 
    .we (MEMWBrf_wr_en), 
    .rd0 (rf_rd0), 
    .rd1 (rf_rd1), 
    .rd2 (rf_data)
);

imm imm(
    .inst (IFIDinst), 
    .imm_out (imm_out)
);

controller controller(
    .inst (IFIDinst), 
    .rf_wr_en (rf_wr_en), 
    .alu_a_sel (alu_a_sel), 
    .alu_b_sel (alu_b_sel), 
    .alu_ctrl (alu_ctrl), 
    .dm_rd_ctrl (dm_rd_ctrl), 
    .dm_wr_ctrl (dm_wr_ctrl), 
    .rf_wr_sel (rf_wr_sel), 
    .comp_ctrl (comp_ctrl), 
    .do_branch (do_branch), 
    .do_jump (do_jump)
);

IDEX IDEX(
    .clk (clk), 
    .IFIDpc (IFIDpc), 
    .Rd (IFIDinst[11:7]), 
    .Imm (imm_out), 
    .rf_rd0 (rf_rd0), 
    .rf_rd1 (rf_rd1), 
    .rf_wr_en (rf_wr_en), 
    .alu_a_sel (alu_a_sel), 
    .alu_b_sel (alu_b_sel), 
    .alu_ctrl (alu_ctrl), 
    .dm_rd_ctrl (dm_rd_ctrl), 
    .dm_wr_ctrl (dm_wr_ctrl), 
    .rf_wr_sel (rf_wr_sel), 
    .comp_ctrl (comp_ctrl), 
    .do_branch (do_branch), 
    .do_jump (do_jump), 
    .IDEXpc (IDEXpc), 
    .IDEXRd (IDEXRd), 
    .IDEXImm (IDEXImm), 
    .IDEXrf_rd0 (IDEXrf_rd0), 
    .IDEXrf_rd1 (IDEXrf_rd1), 
    .IDEXrf_wr_en (IDEXrf_wr_en), 
    .IDEXalu_a_sel (IDEXalu_a_sel), 
    .IDEXalu_b_sel (IDEXalu_b_sel), 
    .IDEXalu_ctrl (IDEXalu_ctrl), 
    .IDEXdm_rd_ctrl (IDEXdm_rd_ctrl), 
    .IDEXdm_wr_ctrl (IDEXdm_wr_ctrl), 
    .IDEXrf_wr_sel (IDEXrf_wr_sel), 
    .IDEXcomp_ctrl (IDEXcomp_ctrl), 
    .IDEXdo_branch (IDEXdo_branch), 
    .IDEXdo_jump (IDEXdo_jump), 
    .IFIDRs1 (IFIDinst[19:15]), 
    .IFIDRs2 (IFIDinst[24:20]), 
    .eFlush (eFlush), 
    .IDEXRs1 (IDEXRs1), 
    .IDEXRs2 (IDEXRs2), 
    .br_pred_d (br_pred_d), 
    .br_pred_e (br_pred_e)
);

alu alu(
    .a (alu_a), 
    .b (alu_b), 
    .alu_ctrl (IDEXalu_ctrl), 
    .alu_out (alu_out)
);

br br(
    .a (IDEXrf_rd0_fd), 
    .b (IDEXrf_rd1_fd), 
    .comp_ctrl (IDEXcomp_ctrl), 
    .do_branch (IDEXdo_branch), 
    .do_jump (IDEXdo_jump), 
    .branch (branch), 
    .jump (jump)
);

EXMEM EXMEM(
    .clk (clk),
    .alu_out (alu_out),
    .IDEXrf_rd1(IDEXrf_rd1_fd),
    .IDEXRd (IDEXRd),
    .IDEXpc (IDEXpc),
    .IDEXrf_wr_en (IDEXrf_wr_en),
    .IDEXdm_rd_ctrl (IDEXdm_rd_ctrl),
    .IDEXdm_wr_ctrl (IDEXdm_wr_ctrl),
    .IDEXrf_wr_sel (IDEXrf_wr_sel),
    .EXMEMalu_out (EXMEMalu_out),
    .EXMEMrf_rd1 (EXMEMrf_rd1),
    .EXMEMRd (EXMEMRd),
    .EXMEMpc (EXMEMpc),
    .EXMEMrf_wr_en (EXMEMrf_wr_en), 
    .EXMEMdm_rd_ctrl (EXMEMdm_rd_ctrl),
    .EXMEMdm_wr_ctrl (EXMEMdm_wr_ctrl),
    .EXMEMrf_wr_sel (EXMEMrf_wr_sel)
);

ins_mem ins_mem(
    .a (pc_in[9:2]), 
    .spo (inst)
);

data_mem data_mem(
    .a (EXMEMalu_out[9:0]), 
    .d (EXMEMrf_rd1), 
    .dpra (m_rf_addr), 
    .clk (clk), 
    .we (EXMEMdm_wr_ctrl), //if use stack please change dm_wr_ctrl_aft to EXMEMdm_wr_ctrl
    .spo (dm_dout), 
    .dpo (m_data), 
    .dm_rd_ctrl (EXMEMdm_rd_ctrl)
);

MEMWB MEMWB(
    .clk (clk), 
    .EXMEMrf_wr_en (EXMEMrf_wr_en), 
    .EXMEMrf_wr_sel (EXMEMrf_wr_sel), 
    .dm_dout (dm_dout),  //if use stack please change dm_dout_aft to dm_dout
    .EXMEMalu_out (EXMEMalu_out), 
    .EXMEMRd (EXMEMRd), 
    .EXMEMpc (EXMEMpc), 
    .MEMWBrf_wr_en (MEMWBrf_wr_en), 
    .MEMWBrf_wr_sel (MEMWBrf_wr_sel), 
    .MEMWBdm_dout (MEMWBdm_dout), 
    .MEMWBalu_out (MEMWBalu_out), 
    .MEMWBRd (MEMWBRd), 
    .MEMWBpc (MEMWBpc)
);

//branch prediction
BTB BTB(
    .clk (clk),
    .rst (rst),
    .rd_pc (pc),
    .rd_pred_pc (br_pred_pc_f),
    .rd_pred (br_pred_f),
    .wr_req (br_pred_e ^ branch),
    .wr_pc (pce),
    .wr_pred_pc (alu_out),
    .wr_pred_state_bit(branch)
);

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