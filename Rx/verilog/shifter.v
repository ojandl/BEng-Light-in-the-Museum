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
    output reg fifo_rd_en
//    output reg [1:0] curState
    );

    parameter IDLE = 2'b00;
    parameter SYNC = 2'b01;
    parameter SEND = 2'b10;
    parameter WAIT = 2'b11;

    reg [1:0] curState;
    reg [7:0] counter = 8'b0;
    reg [8:0] bitcounter = 9'b0;
    reg [31:0] curData;
    reg trig_out;
    reg [1:0] nxtState;
    reg requested = 1'b0;
    reg data_req = 1'b0;

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
                if(bitcounter == 9'd310) begin 
                    bitcounter <= 9'b0;
                end else begin 
                    bitcounter <= bitcounter + 1;
                end
            end
        end
    end

    always@(posedge pclk) begin
        if(curState == SYNC) begin
            curData <= in0;
        end else begin
            if(trig_out == 1'b1) begin
                if(bitcounter[4:0] == 5'b01001) begin
                    curData <= in0;
                end else begin
                    if(curState == SEND)
                        curData <= {curData[30:0], 1'b0};
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
    
    always@(posedge pclk) begin
        data_req <= 1'b0;
        if(rstn == 1'b0) begin
            data_req <= 1'b0;
            tx <= 1'b0;
        end else begin
            case(curState)
                IDLE: begin
                    data_req <= 1'b0;
                    if(trig_out == 1'b1)
                        tx <= 1'b0;
                end
                SYNC: begin
                    if(bitcounter < 9'd5)
                        tx <= 1'b1;
                    else begin
                        if(bitcounter < 9'd10)
                            tx <= 1'b0;
                    end
                end
                SEND: begin
                    tx <= curData[31];
                    if(bitcounter[4:0] == 5'b00111)
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
                if(fifo_empty == 1'b0)
                    nxtState <= SYNC;
            end
            SYNC: begin
                if(bitcounter == 9'd9)
                    nxtState <= SEND;
            end
            SEND: begin
                if((bitcounter[4:0] == 5'b00111) && (fifo_empty == 1'b1))
                    nxtState <= IDLE;
                if(bitcounter == 9'd298)
                    nxtState <= WAIT;
            end
            WAIT: begin
                if(bitcounter == 9'd310)
                    nxtState <= IDLE;
            end
            default: begin
                nxtState <= IDLE;
                tx <= 1'b0;
            end
        endcase
    end

endmodule
