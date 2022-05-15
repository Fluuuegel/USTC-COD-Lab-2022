module test_bench #(parameter WIDTH = 32) ();
reg [WIDTH - 1 : 0] a, b;
reg [2:0] f;
wire [WIDTH -1 : 0] y;
wire z;
alu_32 alu_32(a, b, f, y, z);
initial begin
    a = 32'h3; b = 32'h5; f = 3'h0;
    #20 a = 32'h3; b = 32'h5; f = 3'h1;
    #20 a = 32'h3; b = 32'h5; f = 3'h2;
    #20 a = 32'h3; b = 32'h5; f = 3'h3;
    #20 a = 32'h3; b = 32'h5; f = 3'h4;
    #20 $finish;
end

endmodule