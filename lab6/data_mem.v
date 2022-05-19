module data_mem (
    input [9:0]a,   //read and write (dm_addr)
    input [31:0]d,  //write data
    input [7:0]dpra,    //read only (im_addr)
    input clk,
    input [1:0] we, //dm_wr_ctrl
    output reg [31:0]spo,   //mem[a]
    output [31:0]dpo,   //mem[dpra]
    //supplementary
    input [2:0] dm_rd_ctrl
);
reg [3:0] byte_en;
reg [31:0] mem[0:4095];    //255
reg [31:0] mem_out;

wire [31:0] mem_vis [0:9];
assign mem_vis[0][31:0] = mem[0][31:0];
assign mem_vis[1][31:0] = mem[1][31:0];
assign mem_vis[2][31:0] = mem[2][31:0];
assign mem_vis[3][31:0] = mem[3][31:0];
assign mem_vis[4][31:0] = mem[4][31:0];
assign mem_vis[5][31:0] = mem[5][31:0];
assign mem_vis[6][31:0] = mem[6][31:0];
assign mem_vis[7][31:0] = mem[7][31:0];
assign mem_vis[8][31:0] = mem[8][31:0];
assign mem_vis[9][31:0] = mem[9][31:0];

integer i;

initial begin
    for(i = 10; i <= 4095; i = i + 1) mem[i] = 0;
end

initial begin
    //$readmemh("/home/ubuntu/data.coe",mem); if wanna generate bitstream, shouldn't use $readmemh
    mem[0] = 32'h3;
    mem[1] = 32'h5;
    mem[2] = 32'h3;
    mem[3] = 32'h0;
    mem[4] = 32'h8;
    mem[5] = 32'h6;
    mem[6] = 32'h1;
    mem[7] = 32'h5;
    mem[8] = 32'h8;
    mem[9] = 32'h6;
end

assign dpo = mem[dpra];

always@(*) begin
    case(a[1:0])
    2'b00: mem_out = mem[a[9:2]][31:0];
    2'b01: mem_out = {8'h0, mem[a[9:2]][31:8]};
    2'b10: mem_out = {16'h0, mem[a[9:2]][31:16]};
    2'b11: mem_out = {24'h0, mem[a[9:2]][31:24]};
    default: mem_out = 0;
    endcase
end

always@(*) begin
    case(dm_rd_ctrl)
    3'h1: spo = mem_out;    //is_lw
    3'h2: spo = {16'h0, mem_out[15:0]}; //is_lhu
    3'h3: spo = {{16{mem_out[15]}}, mem_out[15:0]}; //is_lh
    3'h4: spo = {24'h0, mem_out[7:0]};  //is_lbu
    3'h5: spo = {{24{mem_out[7]}}, mem_out[7:0]};   //is_lb
    default: spo = 32'h0;
    endcase
end

always@(*) begin
    if(we == 2'b1) byte_en = 4'b1111;
    else if(we == 2'b10) begin
        if(a[1] == 1'b1) byte_en = 4'b1100;
        else byte_en = 4'b0011;
    end
    else if(we == 2'b11) begin
        case(a[1:0])
        2'b00: byte_en = 4'b1;
        2'b01: byte_en = 4'b10;
        2'b10: byte_en = 4'b100;
        2'b11: byte_en = 4'b1000;
        default: byte_en = 4'b0;
        endcase
    end
    else byte_en = 0;
end

always@ (posedge clk) begin
    if(byte_en != 0) begin
        if(byte_en == 4'b1111) mem[a[9:2]] <= d;
        else if(byte_en == 4'b0011) mem[a[9:2]] <= {mem[a[9:2]][31:16], d[15:0]};
        else if(byte_en == 4'b1100) mem[a[9:2]] <= {d[15:0], mem[a[9:2]][15:0]};
        else if(byte_en == 4'b0001) mem[a[9:2]] <= {mem[a[9:2]][31:8], d[7:0]};
        else if(byte_en == 4'b0010) mem[a[9:2]] <= {mem[a[9:2]][31:16], d[7:0], mem[a[9:2]][7:0]};
        else if(byte_en == 4'b0100) mem[a[9:2]] <= {mem[a[9:2]][31:24], d[7:0], mem[a[9:2]][15:0]};
        else if(byte_en == 4'b1000) mem[a[9:2]] <= {d[7:0], mem[a[9:2]][23:0]};
        else mem[a[9:2]] <= d;
    end
end

endmodule