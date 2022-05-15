module BTB(
    input clk, rst,
    input [31:0] rd_pc,    //输入pc
    output reg rd_pred,           //预测信号
    output reg [31:0] rd_pred_pc,  //从buffer中得到的预测pc
    
    input wr_req,   //写请求信号
    input [31:0] wr_pc, //要写入的分支pc
    input [31:0] wr_pred_pc,    //要写入的预测pc
    input wr_pred_state_bit //预测状态位
);

//ins_mem为256x32，故pc有效位是[9:2]
reg [31:0] pred_pc [0: 1 << 6];
reg pred_state_bit [0: 1 << 6];

always@(*) begin
    if(pred_state_bit[rd_pc[9:2]]) rd_pred = 1'b1;
    else rd_pred = 1'b0;
    rd_pred_pc = pred_pc[rd_pc[9:2]];
end

always@(posedge clk or posedge rst) begin
    if(rst) begin
        for(integer i = 0; i < 1 << 6; i = i + 1) begin
            pred_pc[i] <= 0;
            pred_state_bit[i] <= 1'b0;
        end
        rd_pred <= 0;
        rd_pred_pc <= 0;
    end else begin 
        if(wr_req) begin
            pred_pc[wr_pc[9:2]] <= wr_pred_pc;
            pred_state_bit[wr_pc[9:2]] <= wr_pred_state_bit;
        end
    end
end

endmodule