`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2023 17:18:45
// Design Name: 
// Module Name: partialwrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module partialwrapper(
    input [31:0] wr_data,
//    input data_ready,
    input pclk,
    input aclk,
    input resetn,
    output tx_out,
    input [1:0] dim,
    input fifo_wr_en,
    
    output fifo_full,
    output fifo_wr_success,
    output led_check
);

    wire tx;

    wire done_out;
    wire fifo_empty;
    wire [1:0] bitcount;
    wire rd_en;
    wire tx_inc;
    wire [1:0] state;
    reg [1:0] state_buf;
    wire fifo_rd_success;
    wire data_req;
    
    wire [31:0] in0;
  
    shifternew uut(
        .rstn(resetn),
        .in0(in0),
//        .tx_inc(tx_inc),
        .pclk(pclk),
        .fifo_empty(fifo_empty),
//        .out0(out0),
        .tx(tx),
//        .done_out(done_out),
        .fifo_rd_en(rd_en),
        .curState(state)
//        .bitcount(bitcount),
//        .fifo_rd_success(fifo_rd_success)
//        .transmitting(transmitting)
        );

        
//    controlB uutB (
//        .pclk(pclk),
//        .resetn(resetn),
//        .tx_rinc(tx_inc),
//        .tx_rempty(done_out),
//        .tx_rdata(out0),
//        .state_out(state),
//        .tx(tx)
//        );
        
    async_fifo fifo0 (
        .write_clk(aclk),
        .read_clk(pclk),
        .rstn(resetn),
        .write_en(fifo_wr_en),
        .read_en(rd_en),
        .data_in(wr_data),
        .data_out(in0),
        .full(fifo_full),
        .empty(fifo_empty),

        .fifo_wr_success(fifo_wr_success),
        .fifo_rd_success(fifo_rd_success)

        );

    vppm_module vppm0 (
        .pclk(pclk),
        .dim(dim),
        .state(state_buf),
        .state_buf(state),
        .tx_in(tx),
        .tx_out(tx_out),
        .led_check(led_check)
        );

    always@(posedge pclk) begin
        state_buf <= state;
    end
    
endmodule
