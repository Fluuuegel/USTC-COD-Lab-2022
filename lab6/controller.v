module controller(
    input [31:0] inst,
    output rf_wr_en, alu_a_sel, alu_b_sel,
    output reg [3:0] alu_ctrl,
    output reg [2:0] dm_rd_ctrl,
    output reg [1:0] dm_wr_ctrl,
    output reg [1:0] rf_wr_sel,
    output [2:0] comp_ctrl,
    output do_branch, do_jump
);

wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;

wire is_add;
wire is_addi;
wire is_lw;
wire is_sw;
wire is_beq;
wire is_jal;

//supplementary
wire is_lui;    //Load Upper Immediate x[rd] = sext(imm[31:12] << 12)
wire is_auipc;  //Add Upper Immediate to PC x[rd] = pc + sext(imm[31:12] << 12)
wire is_jalr;   //Jump and Link Register t = pc + 4; pc = (x[rs1] + sext(offset))&~1; x[rd] = t;
wire is_bne;    
wire is_blt;
wire is_bge;
wire is_bltu;
wire is_bgeu;
wire is_lb; //load byte
wire is_lh; //load halfword
wire is_lbu; //load byte, unsigned
wire is_lhu; //load halfword, unsinged
wire is_sb; //store byte
wire is_sh; //store halfword
wire is_slti;   //Set if Less Than Immediate
wire is_sltiu;
wire is_xori;
wire is_ori;
wire is_andi;
wire is_slli;
wire is_srli;
wire is_srai;
wire is_sub;
wire is_sll;
wire is_slt;
wire is_sltu;
wire is_xor;
wire is_srl;
wire is_sra;
wire is_or;
wire is_and;

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

assign is_lw = (opcode == 7'h03) && (funct3 == 3'h2);
assign is_sw = (opcode == 7'h23) && (funct3 == 3'h2);
assign is_beq = (opcode == 7'h63) && (funct3 == 3'h0);
assign is_blt = (opcode == 7'h63) && (funct3 == 3'h4);
assign is_jal = (opcode == 7'h6f);

//supplementary
assign is_lui = (opcode == 7'h37);
assign is_auipc = (opcode == 7'h17);
assign is_jalr = (opcode == 7'h67) && (funct3 == 3'h0);
assign is_bne = (opcode == 7'h63) && (funct3 == 3'h1);
assign is_blt = (opcode == 7'h63) && (funct3 == 3'h4);
assign is_bge = (opcode == 7'h63) && (funct3 == 3'h5);
assign is_bltu = (opcode == 7'h63) && (funct3 == 3'h6);
assign is_bgeu = (opcode == 7'h63) && (funct3 == 3'h7);
assign is_lb = (opcode == 7'h03) && (funct3 == 3'h0);
assign is_lh = (opcode == 7'h03) && (funct3 == 3'h1);
assign is_lbu = (opcode == 7'h03) && (funct3 == 3'h4);
assign is_lhu = (opcode == 7'h03) && (funct3 == 3'h5);
assign is_sb = (opcode == 7'h23) && (funct3 == 3'h0);
assign is_sh = (opcode == 7'h23) && (funct3 == 3'h1);
assign is_slti = (opcode == 7'h13) && (funct3 == 3'h2);
assign is_sltiu = (opcode == 7'h13) && (funct3 == 3'h3);
assign is_xori = (opcode == 7'h13) && (funct3 == 3'h4);
assign is_ori = (opcode == 7'h13) && (funct3 == 3'h6);
assign is_andi = (opcode == 7'h13) && (funct3 == 3'h7);
assign is_slli = (opcode == 7'h13) && (funct3 == 3'h1) && (funct7 == 7'h00);
assign is_srli = (opcode == 7'h13) && (funct3 == 3'h5) && (funct7 == 7'h00);
assign is_srai = (opcode == 7'h13) && (funct3 == 3'h5) && (funct7 == 7'h20);
assign is_sll = (opcode == 7'h33) && (funct3 == 3'h1) && (funct7 == 7'h00);
assign is_slt = (opcode == 7'h33) && (funct3 == 3'h2) && (funct7 == 7'h00);
assign is_sltu = (opcode == 7'h33) && (funct3 == 3'h3) && (funct7 == 7'h00);
assign is_xor = (opcode == 7'h33) && (funct3 == 3'h4) && (funct7 == 7'h00);
assign is_srl = (opcode == 7'h33) && (funct3 == 3'h5) && (funct7 == 7'h00);
assign is_sra = (opcode == 7'h33) && (funct3 == 3'h5) && (funct7 == 7'h20);
assign is_or = (opcode == 7'h33) && (funct3 == 3'h6) && (funct7 == 7'h00);
assign is_and = (opcode == 7'h33) && (funct3 == 3'h7) && (funct7 == 7'h00);


assign is_add_type = is_auipc | is_jal | is_jalr | is_b_type | is_s_type | is_lb | is_lh | is_lw | is_lbu | is_lhu | is_add | is_addi;
assign is_u_type = is_lui | is_auipc;
assign is_jump_type = is_jal;
assign is_b_type = is_beq | is_bne | is_blt | is_bge | is_bltu | is_bgeu;
assign is_r_type = is_add | is_sub | is_sll | is_slt | is_sltu | is_xor | is_srl | is_sra | is_or | is_and;
assign is_i_type = is_jalr | is_lb | is_lh | is_lw | is_lbu | is_lhu | is_addi | is_slti | is_sltiu | is_xori | is_ori | is_andi | is_slli | is_srli | is_srai;
assign is_s_type = is_sw | is_sb | is_sh;

always@(*) begin
    if(is_add_type) alu_ctrl = 4'h1;
    else if(is_sub) alu_ctrl = 4'h2;
    else if(is_lui) alu_ctrl = 4'h3;
    else if(is_slt | is_slti) alu_ctrl = 4'h4;
    else if(is_sltu | is_sltiu) alu_ctrl = 4'h5;
    else if(is_xor | is_xori) alu_ctrl = 4'h6;
    else if(is_or | is_ori) alu_ctrl = 4'h7;
    else if(is_and | is_andi) alu_ctrl = 4'h8;
    else if(is_sll | is_slli) alu_ctrl = 4'h9;
    else if(is_srl | is_srli) alu_ctrl = 4'ha;
    else if(is_sra | is_srai) alu_ctrl = 4'hb;
    else    alu_ctrl = 4'h0;
end

assign rf_wr_en = is_u_type | is_jump_type | is_r_type | is_i_type;
assign alu_a_sel = is_r_type | is_i_type | is_s_type;
assign alu_b_sel = ~ is_r_type;

always@(*) begin
    if(is_lw) dm_rd_ctrl = 3'b1;
    else if(is_lhu) dm_rd_ctrl = 3'h2;
    else if(is_lh) dm_rd_ctrl = 3'h3;
    else if(is_lbu) dm_rd_ctrl = 3'h4;
    else if(is_lb) dm_rd_ctrl = 3'h5;
    else dm_rd_ctrl = 3'b0;
end

always@(*) begin
    if(is_sw) dm_wr_ctrl = 2'b1;
    else if(is_sh) dm_wr_ctrl = 2'h2;
    else if(is_sb) dm_wr_ctrl = 2'h3;
    else dm_wr_ctrl = 2'b0;
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