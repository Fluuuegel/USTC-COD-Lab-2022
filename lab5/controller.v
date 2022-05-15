module controller(
    input [31:0] inst,
    output rf_wr_en, alu_a_sel, alu_b_sel,
    output reg [1:0] alu_ctrl,
    output reg dm_rd_ctrl,
    output reg dm_wr_ctrl,
    output reg [1:0] rf_wr_sel,
    output [2:0] comp_ctrl,
    output do_branch, do_jump
);

wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;

wire is_add;
wire is_addi;
wire is_sub;
wire is_auipc;
wire is_lw;
wire is_sw;
wire is_beq;
wire is_blt;
wire is_jal;
wire is_jalr;

wire is_add_type;
wire is_u_type;
wire is_jump_type;
wire is_b_type;
wire is_r_type;
wire is_i_type;
wire is_s_type;

assign opcode = inst[6:0];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];

assign is_add = (opcode == 7'h33) && (funct3 == 3'h0) && (funct7 == 7'h0);
assign is_addi = (opcode == 7'h13) && (funct3 == 3'h0);
assign is_sub = (opcode == 7'h33) && (funct3 == 3'h0) && (funct7 == 7'h20);
assign is_auipc = (opcode == 7'h17);
assign is_lw = (opcode == 7'h03) && (funct3 == 3'h2);
assign is_sw = (opcode == 7'h23) && (funct3 == 3'h2);
assign is_beq = (opcode == 7'h63) && (funct3 == 3'h0);
assign is_blt = (opcode == 7'h63) && (funct3 == 3'h4);
assign is_jal = (opcode == 7'h6f);
assign is_jalr = (opcode == 7'h67) && (funct3 == 3'h0);

assign is_add_type = is_auipc | is_jal | is_jalr | is_b_type | is_s_type | is_lw | is_add | is_addi;
assign is_u_type = is_auipc;
assign is_jump_type = is_jal;
assign is_b_type = is_beq | is_blt;
assign is_r_type = is_add | is_sub;
assign is_i_type = is_jalr | is_lw | is_addi;
assign is_s_type = is_sw;

always@(*) begin
    if(is_add_type) alu_ctrl = 2'h0;
    else if(is_sub) alu_ctrl = 2'h1;
end

assign rf_wr_en = is_u_type | is_jump_type | is_r_type | is_i_type;
assign alu_a_sel = is_r_type | is_i_type | is_s_type;
assign alu_b_sel = ~ is_r_type;

always@(*) begin
    if(is_lw) dm_rd_ctrl = 1'b1;
    else dm_rd_ctrl = 1'b0;
end

always@(*) begin
    if(is_sw) dm_wr_ctrl = 1'b1;
    else dm_wr_ctrl = 1'b0;
end

always@(*) begin
    if(opcode == 7'h3) rf_wr_sel = 2'h3;
    else if(((~ is_jalr) & is_i_type) | is_u_type | is_r_type) rf_wr_sel = 2'h2;
    else if(is_jal | is_jalr) rf_wr_sel = 2'h1;
    else rf_wr_sel = 2'h0;
end

assign comp_ctrl = funct3;
assign do_branch = is_b_type;
assign do_jump = is_jal | is_jalr;

endmodule