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


module partialwrappernew(
    input [31:0] wr_data,
//    input data_ready,
    input pclk,
    input aclk,
    input resetn,
    output tx,
//    output tx_out,
//    input dim,
    
    
//    output tx_inc,
//    output [7:0] out0,
//    output tx_empty,
//    output data_req,
    output fifo_full,
//    output done_out,
//    output fifo_empty,
//    output [1:0] bitcount,
//    output rd_en,
//    output tx_inc,
//    output [1:0] state,
//    output transmitting,
//    output fifo_rd_success,
    input fifo_wr_en,
//    input data_ready,
    output fifo_wr_success//,
//    output fifo_ready
    );
    
    
    
    
//    wire tx_inc;
    wire [7:0] out0;
//    wire done_out;
//    wire transmitting;
    wire data_req;
  //  reg fifo_wr_en;
    wire fifo_empty;
//    wire [1:0] bitcount;
    wire rd_en;
    
    wire [31:0] in0;
//    reg data_ready_buf = 1'b0;
//    reg writing = 1'b0; 
//    reg fifo_ready = 1'b1; 
    wire fifo_rd_success; 
    
  
    shifternew uut(
        .rstn(resetn),
        .in0(in0),
//        .tx_inc(tx_inc),
        .pclk(pclk),
        .fifo_empty(fifo_empty),
//        .out0(out0),
        .tx(tx),
//        .done_out(done_out),
        .fifo_rd_en(rd_en)
//        .curState(state)
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

//    vppm_module vppm0 (
//        .pclk(pclk),
//        .dim(dim),
//        .state(state),
//        .tx_in(tx),
//        .tx_out(tx_out)
//        );

    
endmodule
