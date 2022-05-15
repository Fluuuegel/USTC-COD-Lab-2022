module decoder
(
    input en,
    input [1:0]sel,
    output reg ea, eb, ef
);
always @(*) begin
    if(en) begin
        case (sel)
            2'b00: begin
                ea = 1'b1;
                eb = 1'b0;
                ef = 1'b0;
            end
            2'b01: begin
                ea = 1'b0;
                eb = 1'b1;
                ef = 1'b0;
            end
            2'b10: begin
                ea = 1'b0;
                eb = 1'b0;
                ef = 1'b1;
            end
            default: begin
                ea = 1'b0;
                eb = 1'b0;
                ef = 1'b0;
            end
        endcase
    end
    else begin
        ea = 1'b0;
        eb = 1'b0;
        ef = 1'b0;
    end
end
endmodule

module alu_6 # (
    parameter ADD_6 = 3'b000,
    parameter SUB_6 = 3'b001,
    parameter AND_6 = 3'b010,
    parameter OR_6 = 3'b011,
    parameter XOR_6 = 3'b100
)
(
    input clk,
    input en,
    input [1:0] sel,
    input [5:0] x,
    output reg [5:0] y,
    output reg z
);

reg [2:0] fr;
reg [5:0] ar;
reg [5:0] br;
wire ea;
wire eb;
wire ef;
reg [5:0] yout;
reg zout;

decoder decoder(en, sel, ea, eb, ef);

always @(posedge clk) begin
    if(ea) ar <= x;
    else if(eb) br <= x;
    else if(ef) fr <= x[2:0];
    else begin
        ar <= ar;
        br <= br;
        fr <= fr;
    end
end

always @(*) begin
    case (fr)
        ADD_6: y = ar + br;
        SUB_6: y = ar - br;
        AND_6: y = ar & br;
        OR_6:  y = ar | br;
        XOR_6: y = ar ^ br;
        default: y = 6'b0;
    endcase
end

always @(*) begin
    if(y == 6'b0)
        z = 1'b1;
    else 
        z = 1'b0;
end

always @(posedge clk) begin
    yout <= y;
    zout <= z;
end
endmodule