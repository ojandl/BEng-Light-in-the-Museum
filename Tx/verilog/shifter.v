`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.04.2023 19:32:17
// Design Name: 
// Module Name: shifter
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

module shifternew(
    input rstn,
    input [31:0] in0,
    input pclk,
    input fifo_empty,
    output reg tx,
    output reg fifo_rd_en,
    output reg [1:0] curState,
    output reg [6:0] reqcounter,
    output reg reqcounter_trig,
    output reg trig_out,
    output reg [8:0] bitcounter
    );

    parameter IDLE = 2'b00;
    parameter SYNC = 2'b01;
    parameter SEND = 2'b10;
    parameter WAIT = 2'b11;

    reg [7:0] counter = 8'b0;
//    reg [8:0] bitcounter = 9'b0;
    reg [35:0] curData;
//    reg trig_out;
    reg [1:0] nxtState;
    reg requested = 1'b0;
    reg data_req = 1'b0;
    reg [3:0] parity_bits = 4'b0;
//    reg [5:0] reqcounter = 6'b0;
//    reg reqcounter_trig = 1'b0;

    always@(posedge pclk) begin
        if(rstn == 1'b0) begin
            trig_out <= 1'b0;
            counter <= 8'b0;
        end else begin
            if(counter == 8'd49) begin 
                trig_out <= 1'b1;
                counter <= 8'b0;
            end else begin 
                trig_out <= 1'b0;
                counter <= counter + 1;
            end
        end
    end

    always@(posedge pclk) begin
        if(rstn == 1'b0) begin 
            bitcounter <= 9'b0;
        end else begin 
            if((trig_out == 1'b1) && (curState != IDLE)) begin
                if(bitcounter == 9'd344) begin 
                    bitcounter <= 9'b0;
                end else begin 
                    bitcounter <= bitcounter + 1;
                end
            end
        end
    end
    
    always@(posedge pclk) begin
        if(rstn == 1'b0) begin 
            reqcounter <= 7'b0;
        end else begin 
            if(curState == IDLE)
                reqcounter <= 7'b0;
            if((trig_out == 1'b1) && (curState != IDLE)) begin
                if(reqcounter == 7'h2d) begin 
                    reqcounter <= 7'h0a;
                    reqcounter_trig <= 7'b1;
                end else begin 
                    reqcounter <= reqcounter + 1;
                    reqcounter_trig <= 1'b0;
                end
            end
        end
    end
    
//    reg [6:0] reqcounter_buf;
    
//    always@(posedge pclk) begin
//        if(trig_out == 1'b1) begin
//            reqcounter_buf <= reqcounter;
//        end
//    end

    always@(posedge pclk) begin
        if(curState == SYNC) begin
            curData[35:28] <= in0[31:24];
            curData[27] <= parity_bits[3];
            curData[26:19] <= in0[23:16];
            curData[18] <= parity_bits[2];
            curData[17:10] <= in0[15:8];
            curData[9] <= parity_bits[1];
            curData[8:1] <= in0[7:0];
            curData[0] <= parity_bits[0];
            
        end else begin
            if(trig_out == 1'b1) begin
                if(reqcounter == 7'h2d) begin// && (reqcounter_buf != 7'h09)) begin
                    curData[35:28] <= in0[31:24];
                    curData[27] <= parity_bits[3];
                    curData[26:19] <= in0[23:16];
                    curData[18] <= parity_bits[2];
                    curData[17:10] <= in0[15:8];
                    curData[9] <= parity_bits[1];
                    curData[8:1] <= in0[7:0];
                    curData[0] <= parity_bits[0];
                end else begin
                    if(curState == SEND)
                        curData <= {curData[34:0], 1'b0};
                end
            end
        end
    end

    always@(posedge pclk) begin
        curState <= IDLE;
        if(rstn == 1'b0) begin
            curState <= IDLE;
        end else begin
            if(trig_out == 1'b1)
                curState <= nxtState;
            else
                curState <= curState;
        end
    end

    always@(posedge pclk) begin
        if(rstn == 1'b0) begin
            fifo_rd_en <= 1'b1;
        end else begin
            if(curState == IDLE) begin 
                if(fifo_empty == 1'b1)
                    fifo_rd_en <= 1'b1;
                else
                    fifo_rd_en <= 1'b0;
            end else begin
                if(data_req == 1'b1) begin
                    if(requested == 1'b0) begin
                        fifo_rd_en <= 1'b1;
                        requested <= 1'b1;
                    end else begin
                        fifo_rd_en <= 1'b0;
                        requested <= 1'b1;
                    end
                end else begin
                    fifo_rd_en <= 1'b0;
                    requested <= 1'b0;
                end
            end
        end
    end
    
    reg buffer = 1'b0;    
    
    always@(posedge pclk) begin
        data_req <= 1'b0;
        if(rstn == 1'b0) begin
            data_req <= 1'b0;
            tx <= 1'b0;
        end else begin
            case(curState)
                IDLE: begin
                    data_req <= 1'b0;
                    if(fifo_empty == 1'b0)
                        buffer <= 1'b1;
                    if(trig_out == 1'b1)
                        tx <= ~tx;
                end
                SYNC: begin
                    buffer <= 1'b0;
                    if(bitcounter < 9'd5) begin
                        tx <= 1'b1;
                    end else begin
                        if(bitcounter < 9'd10)
                            tx <= 1'b0;
                    end
                end
                SEND: begin
                    tx <= curData[35];
                    if(reqcounter == 7'h2a)
                        data_req <= 1'b1;
                    else
                        data_req <= 1'b0;
                end
                WAIT: begin
                    tx <= 1'b0;
                    data_req <= 1'b0;
                end
                default: begin
                    tx <= 1'b0;
                    data_req <= 1'b0;
                end
            endcase
        end
    end       
  
    always@(*) begin
        nxtState <= curState;
        case(curState)
            IDLE: begin
                if(buffer == 1'b1)
                    nxtState <= SYNC;
            end
            SYNC: begin
                if(bitcounter == 9'd9)
                    nxtState <= SEND;
            end
            SEND: begin
                if((bitcounter[4:0] == 5'b00111) && (fifo_empty == 1'b1))
                    nxtState <= IDLE;
                if(bitcounter == 9'd334)
                    nxtState <= WAIT;
            end
            WAIT: begin
                if(bitcounter == 9'd344)
                    nxtState <= IDLE;
            end
            default: begin
                nxtState <= IDLE;
                tx <= 1'b0;
            end
        endcase
    end
    
           // the decoded value is determined by the majority of 
    // the sampled value 
    function [3:0] paritygen;
        input [31:0] in0;
        
        integer i;
        integer j;
        reg[3:0] parityreg = 4'b1111;
        begin 

            for(i=0;i<4;i=i+1) begin 
                for(j=0; j<8; j=j+1) begin
                    parityreg[i] = parityreg[i] ^ in0[i*8 + j];
                end
            end 

            paritygen = parityreg;
        end 
    endfunction
    
    always@(in0) begin
        parity_bits = paritygen(in0);
    end

endmodule
