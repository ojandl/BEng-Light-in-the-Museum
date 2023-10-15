`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2023 19:35:45
// Design Name: 
// Module Name: slow_clk
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


module slowClock(
    input aclk,
    input resetn,
    output reg pclk
    );

reg [2:0] counter = 3'b0;
reg [2:0] threshold = 3'd4;

always@(posedge resetn or posedge aclk)
begin
    if (resetn == 1'b0)
        begin
            pclk <= 0;
            counter <= 0;
        end
    else
        begin
            counter <= counter + 1;
            if ( counter == threshold) begin//00)
                begin
                    counter <= 3'b0;
                    pclk <= ~pclk;
                end
            end
        end
end

endmodule   