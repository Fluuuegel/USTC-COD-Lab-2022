module alu_7 #(parameter WIDTH = 7)
(
    input [WIDTH - 1 : 0] a, b,
    input [2:0] f,
    output reg [WIDTH -1 : 0] y,
    output reg z
);

parameter ADD_32 = 3'b000;
parameter SUB_32 = 3'b001;
parameter AND_32 = 3'b010;
parameter OR_32 = 3'b011;
parameter XOR_32 = 3'b100;

always @(*) begin
    case (f)
        ADD_32: y = a + b;
        SUB_32: y = a - b;
        AND_32: y = a & b;
        OR_32:  y = a | b;
        XOR_32: y = a ^ b;
        default: y = 32'b0;
    endcase
end 

always @(*) begin
    if(y == 32'b0)
        z = 1'b0;
    else 
        z = 1'b1;
end

endmodule