`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2023 06:57:51
// Design Name: 
// Module Name: resethandle
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


module resethandle(
    input user_rst,
    input sys_rstn,
    output rstn_out
    );
    
    assign rstn_out = ~(user_rst || ~sys_rstn);
        
    
endmodule
