module test_fls ();
reg clk, rst, en;
reg [6:0] d;
wire [6:0] f;

fls fls1(clk, rst, en, d, f);
initial begin
    rst = 1'b1; en = 1'b0; d = 2;
end

initial begin
    clk = 1'b0;
    forever begin
        #20 clk = ~clk;
    end 
end

initial begin
    #5 en = 1'b1;
    #10 rst = 1'b0;
    #40 en = 1'b0;
    #7 d = 3;
    #13 en = 1'b1;
    #20 en = 1'b0;
    #10 d = 4;
    #15 en = 1;
    #20 en = 0;
    #20 $finish;
end

endmodule