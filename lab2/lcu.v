module lcu (
    input [3:0] in,
    input enq, deq, clk, rst,
    input [3:0] rd0,
    output reg [3:0] out,
    output reg full, emp,
    output reg [2:0] ra0,
    output reg [2:0] wa,
    output reg we, 
    output reg [3:0] wd,
    output reg [7:0] valid
);

reg [2:0] head;
reg [2:0] tail;

parameter IDLE = 2'b00;
parameter ENQU = 2'b01;
parameter DEQU = 2'b10;

reg [1:0] cs;
reg [1:0] ns;
reg tmp_1;
reg tmp_2;
reg enq_edge;
reg deq_edge;

initial begin
    cs <= 2'b0;
    ra0 <= 3'b0;
    valid <= 8'b0;
end

always @(posedge clk) begin
    tmp_1 <= enq;
    enq_edge <= enq & ~tmp_1;
    tmp_2 <= deq;
    deq_edge <= deq & ~tmp_2;
end

always @(*) begin
    case(cs)
        IDLE: begin
            if(enq_edge & !full & !deq_edge) ns = ENQU;
            else if(!enq_edge & !emp & deq_edge) ns = DEQU;
            else ns = IDLE;
        end
        ENQU: begin
            if(enq_edge & !full & !deq_edge) ns = ENQU;
            else if(!enq_edge & !emp & deq_edge) ns = DEQU;
            else ns = IDLE;
        end
        DEQU: begin
            if(enq_edge & !full & !deq_edge) ns = ENQU;
            else if(!enq_edge & !emp & deq_edge) ns = DEQU;
            else ns = IDLE;
        end
        default: ns = IDLE;
    endcase
end

always @(posedge clk) begin
    if(rst) begin
        head <= 3'b0;
        tail <= 3'b0;
        valid <= 8'b0;
        emp <= 1'b1;
        full <= 1'b0;
    end
    else begin
        case(cs)
            ENQU: begin
                we <= 1'b1;
                wa <= tail;
                wd <= in;
                valid[tail] <= 1'b1;
                tail <= tail + 1'b1;
                full <= (tail + 1'b1 == head) ? 1'b1 : 1'b0;
                emp <= 1'b0;
            end
            DEQU: begin
                ra0 <= head;
                out <= rd0;
                valid[head] <= 1'b0;
                head <= head + 1'b1;
                emp <= (tail == head + 1'b1) ? 1'b1 : 1'b0;
                full <= 1'b0;
            end
            default: begin
                we <= 1'b0;
            end
        endcase
    end
end

always @(posedge clk) begin
    if(rst) cs <= IDLE;
    else cs <= ns;
end

endmodule