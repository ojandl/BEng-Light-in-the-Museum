`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2023 18:36:35
// Design Name: 
// Module Name: axi_slave_wrapper
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


module axi_slave_wrapper(
    input s_axi_aclk,
    input s_axi_aresetn,
    input [8:0] s_axi_awaddr,
    input [2:0] s_axi_awprot,
    input  s_axi_awvalid,
    output s_axi_awready,
    input [31:0] s_axi_wdata,
    input [3:0] s_axi_wstrb,
    input  s_axi_wvalid,
    output s_axi_wready,
    output [1:0] s_axi_bresp,
    output s_axi_bvalid,
    input  s_axi_bready,
    input [8:0] s_axi_araddr,
    input [2:0] s_axi_arprot,
    input  s_axi_arvalid,
    output s_axi_arready,
    output [31:0] s_axi_rdata,
    output [1:0] s_axi_rresp,
    output s_axi_rvalid,
    input  s_axi_rready,
    
    input fifo_full,
    input fifo_wr_success,
    output [31:0] tx,
    output reg irq,
    output reg fifo_wr_en,
    output reset,
    
    input pclk,
    input trig_out,
    
    input [7:0] data_in,
    input data_valid,
    
//    output fifo_rd,
//    output data_rd,
    output [1:0] dim
//    output clkfreq
    );
   
   wire [31:0] out0;
   wire [31:0] out1;
   wire [31:0] out2;
   wire data_ready;
   reg [31:0] in0;    
   reg [31:0] in1;
   wire [31:0] in2;



    
   axi_lite_gpio_v1_0 #
  (
    .C_S_AXI_ADDR_WIDTH(9),
    .C_S_AXI_BASEADDR(32'h44A0_0000), //Defult value at vivado is all 1's

    .I_PORT_COUNT(2),
    .O_PORT_COUNT(2)
    ) axi_lite_0 (
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awprot(s_axi_awprot),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arprot(s_axi_arprot),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),
    
    .in0(in0),
    .in1(in1),
    .out0(out0),
    .out1(out1),
    .data_ready(data_ready)
    );
    

   reg wr_en_buf = 1'b0;
   reg data_ready_buf = 1'b0;
   reg data_ready_flag = 1'b0;
   reg writing = 1'b0;  
   reg fifo_ready = 1'b1;
   
   reg [1:0] counter = 2'b0;
   reg [31:0] curData;


    always@(posedge s_axi_aclk) begin
        if(writing == 1'b1) begin
            fifo_wr_en <= 1'b0;
            writing <= 1'b0;
        end else begin
            if((fifo_ready == 1'b1) && (data_ready_flag == 1'b1) && (fifo_full == 1'b0)) begin
                fifo_wr_en <= 1'b1;
                writing <= 1'b1;
                data_ready_flag <= 1'b0;
            end else
                fifo_wr_en <= 1'b0;
        

            if((data_ready == 1'b1) && (data_ready_buf == 1'b0))
                data_ready_flag <= 1'b1;
        end
            
        wr_en_buf <= fifo_wr_en;
        data_ready_buf <= data_ready;
    end
    
    always@(posedge s_axi_aclk) begin
            if(fifo_wr_success == 1'b1) begin
                fifo_ready <= 1'b1;
            end else begin
                if((fifo_wr_en == 1'b0) && (wr_en_buf == 1'b1)) begin
                    fifo_ready <= 1'b0;
                end
            end
    end
        

    always@(posedge pclk) begin
        if(data_valid == 1'b1) begin
            case(counter)
                2'b00: begin
                    curData[31:24] <= data_in;
                    counter <= 2'b01;
                end
                2'b01: begin
                    curData[23:16] <= data_in;
                    counter <= 2'b10;
                end
                2'b10: begin
                    curData[15:8] <= data_in;
                    counter <= 2'b11;
                end
                2'b11: begin
                    curData[7:0] <= data_in;
                    in0 <= {curData[31:8], data_in};
                    counter <= 2'b00;
                    in1[28] <= ~in1[28];
                end
                default: begin
                    in0[31:0] <= 32'b0;
                    counter <= 2'b00;
                end
            endcase
        end
    end
    
       always@(posedge pclk) begin
        if(data_valid == 1'b1) begin
            in1[7:0] <= data_in;
            in1[8] <= ~in1[8];
        end
    end
    
    reg irq_done = 1'b0;
    reg in1_buf;
    
    always@(posedge s_axi_aclk) begin
        if((irq_done == 1'b1) || (in1_buf == in1))  begin
            irq <= 1'b0;
        end else begin
            irq <= 1'b1;
            irq_done <= 1'b0;
        end
                    
        if(data_valid == 1'b0) begin
            irq_done <= 1'b0;
        end
        in1_buf <= in1;
    end
    
   always@(posedge s_axi_aclk) begin
        in1[12] <= trig_out;
        in1[16] <= fifo_full;
    end
    
    assign tx = out0;
    assign reset = out1[0];
    assign dim = out1[5:4];
endmodule
