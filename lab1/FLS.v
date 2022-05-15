module signal_edge (
    input clk,
    input button,
    output button_edge
);
reg button_r1,button_r2;

always@(posedge clk)
    button_r1 <= button;

always@(posedge clk)
    button_r2 <= button_r1;

assign button_edge = button_r1 & (~button_r2);

endmodule

module fls #(
    parameter RECV_D = 2'b00,
    parameter EXECUTE = 2'b01
)
(
    input clk, rst, en,
    input [6:0] d,
    output reg [6:0] f
);

reg [1:0] cs;
reg [1:0] ns;
reg [6:0] d_bef;
reg [6:0] d_nxt;
reg [2:0] cnt;
wire [6:0] d_sum;
wire z;
wire button_edge;

alu_7 alu(d_bef, d_nxt, 3'b000, d_sum, z);
signal_edge signal_edge(clk, en, button_edge);

initial begin
    cnt <= 2'b0;
end

always @(*) begin
    case(cs)
        RECV_D: begin
            if(cnt == 2'b10) ns = EXECUTE;
            else ns = RECV_D;
        end
        EXECUTE: begin
            ns = EXECUTE;
        end
        default: ns = RECV_D;
    endcase
end

always @(posedge clk) begin
    if(rst) begin
        cnt <= 2'b0;
        f <= 7'b0;
        d_bef <= 7'b0;
        d_nxt <= 7'b0;
    end 
    else if(button_edge) begin
        case (cs)
            RECV_D: begin
                if(cnt == 2'b00) begin 
                    f <= d;
                    d_bef <= d;
                end
                else begin
                    f <= d;
                    d_nxt <= d;
                end
                cnt <= cnt + 1;
            end
            EXECUTE: begin
                d_bef <= d_nxt;
                f <= d_sum;
                d_nxt <= d_sum;
            end
            default: begin
                cnt <= 2'b0;
                f <= 7'b0;
                d_bef <= 7'b0;
                d_nxt <= 7'b0;
            end
        endcase
    end
end

always @(posedge clk) begin
    if(rst) cs <= RECV_D;
    else cs <= ns;
end

endmodule

