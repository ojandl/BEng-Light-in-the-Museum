`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2023 06:58:22
// Design Name: 
// Module Name: vppm
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


module vppm_module(
    input pclk,
    input [1:0] dim,
    input [1:0] state,
    input [1:0] state_buf,
    input tx_in,
    
    output reg tx_out,
    output reg led_check
    );
    
    parameter IDLE = 2'b00;
    parameter SYNC = 2'b01;
    parameter SEND = 2'b10;
    
    parameter LOW = 2'b00;
    parameter MID = 2'b01;
    parameter HIGH = 2'b10;
    
    reg [5:0] counter = 6'b0;
    reg [7:0] forevercounter = 8'b0;
    reg idle = 1'b0;
    reg idlecount = 4'b0;
     
    always@(posedge pclk) begin
        if(state == SEND) begin
            if(counter == 6'd49)
                counter <= 6'd0;
            else
                counter <= counter + 1;
        end else begin
            counter <= 6'b0;
        end
    end
    
    always@(posedge pclk) begin
        if(state == IDLE) begin
            if(forevercounter == 8'd249)
                forevercounter <= 8'd50;
            else
                forevercounter <= forevercounter + 1;
        end else
            forevercounter <= 8'b0;
    end  
         
    always@(posedge pclk) begin
        led_check <= 1'b0;
        case(state)
            SEND: begin
                if((counter > 6'd20) && (counter < 6'd31)) begin
                    if(counter < 6'd26) begin    
                        if(dim == HIGH) begin
                            tx_out <= 1'b1;
                        end else begin
                            if(dim == LOW) begin
                                tx_out <= 1'b0;
                            end else begin
                                tx_out <= tx_in ^ 1'b1;
                            end
                        end
                    end else begin
                        if(dim == HIGH) begin
                            tx_out <= 1'b1;
                        end else begin
                            if(dim == LOW) begin
                                tx_out <= 1'b0;
                            end else begin
                                tx_out <= tx_in;
                            end
                        end
                    end
                end else begin
                    if(counter < 6'd21)
                       tx_out <= tx_in ^ 1'b1;
                    else begin
                          tx_out <= tx_in ^ 1'b0;
                    end
                end
            end
            IDLE: begin
//                if(state_buf != IDLE)
//                    tx_out <= 1'b0;
//                else begin
                    if(dim == HIGH) begin
                        led_check <= 1'b0;
                        if(forevercounter < 8'd130)
                            tx_out <= 1'b0;
                        else
                            tx_out <= 1'b1;
                    end else begin
                        if(dim == MID) begin
                            led_check <= 1'b1;
                            if(forevercounter < 8'd150)
                                tx_out <= 1'b0;
                            else
                                tx_out <= 1'b1;
                        end
                        else begin
                            led_check <= 1'b0;
                            if(forevercounter < 8'd170)
                                tx_out <= 1'b0;
                            else
                                tx_out <= 1'b1;
                        end
                    end
                end
//            end
            SYNC: begin
                tx_out <= tx_in;
            end
            default: begin
                tx_out <= 1'b0;
            end
        endcase
    end                        
   
endmodule
