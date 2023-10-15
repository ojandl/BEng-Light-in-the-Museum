`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.04.2023 22:29:26
// Design Name: 
// Module Name: pwm
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


module pwm (
    input [1:0] pwm,
    input aclk,
    output reg pwm_out
);

reg [2:0] count;

always @ (posedge aclk) begin    
    if (count >= pwm) begin
        pwm_out <= 1;
    end
    else begin
        pwm_out <= 0;
    end
    
    if(count == 3'd7)
        count <= 3'b0;
    else
        count <= count + 1;
end

endmodule

