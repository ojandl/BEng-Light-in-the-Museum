`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2023 10:39:21
// Design Name: 
// Module Name: fifo
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


module async_fifo #(parameter DATA_WIDTH = 32)
(
    input write_clk,
    input read_clk,
    input rstn,
    input write_en,
    input read_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg empty,
    output reg full,
    output reg fifo_wr_success,
    output reg fifo_rd_success
//    output reg [4:0] write_pointer,
//    output reg [4:0] read_pointer
);

reg [0:31] fifo [DATA_WIDTH-1:0];
reg [4:0] write_pointer = 5'd0;
reg [4:0] read_pointer = 5'd0;
integer i;

//initial begin
//    write_pointer <= 32'b0;
//    read_pointer <= 32'b0;
//end

always@(posedge write_clk) begin
    if (rstn == 1'b0) begin
        write_pointer <= 5'd0;
        full <= 0;
//        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
//            fifo[i] <= 32'b0;
//        end
    end else begin
        if((write_en == 1'b1) && (full == 1'b0)) begin
            fifo[write_pointer] <= data_in;
            if (write_pointer == 5'd31) begin
                write_pointer <= 5'd0;
            end else begin
                write_pointer <= write_pointer + 1;
            end
            fifo_wr_success <= 1'b1;
        end else
            fifo_wr_success <= 1'b0;
        
        if ((write_pointer + 1 == read_pointer) || (write_pointer == 5'd31 && read_pointer == 5'd0))
            full <= 1;
        else
            full <= 0;
    end
end


always@(posedge read_clk) begin
    if (rstn == 1'b0) begin
        read_pointer <= 0;
        fifo_rd_success <= 1'b0;
        empty <= 1'b1;
    end else begin   
        if (read_en && (empty == 1'b0)) begin
            data_out <= fifo[read_pointer];
            fifo_rd_success <= 1'b1;
            if(read_pointer == 5'd31)
                read_pointer <= 5'b0;
            else
                read_pointer <= read_pointer + 1;
        end else
            fifo_rd_success <= 1'b0;

        
        if (write_pointer == read_pointer)
            empty <= 1'b1;
        else
            empty <= 1'b0;
    end
end
endmodule

