`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2023 11:40:41
// Design Name: 
// Module Name: fbsbdecode
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


module fbsbdecoder(
    input pclk, 
    input resetn, 
    input rx, 

    output [7:0] data_o, 
    output dataValid,
//    output dataNew,
//    output data,
//    output trig_out,
    output reg sample,
//    output reg [7:0] curState,
//    output [7:0] errors_out,
//    output reg [5:0] curSampledValue,
//    output [7:0] flags_out,
    output parity_out
//    output reg [5:0] bitcounter,
//    output [2:0] errors_count,
//    output [2:0] flags_count,
//    output reg [30:0] nextSamplePoint,
//    output reg [7:0] data_orig
    );

    reg [1:0] RxD_sync;
    always @(posedge pclk) begin 
        RxD_sync <= {RxD_sync[0], rx}; 
    end
    
    reg [7:0] errors = 8'b0;
    reg [7:0] flags = 8'b0;
    reg [23:0] errors_all = 24'b0;
    reg [23:0] flags_all = 24'b0;
    reg [2:0] tieoff;

    ////////////////////////////////////////////////
    // state machine 

    parameter IDLE = 8'h0; 
    parameter SYNCHIGH0 = 8'h1; 
    parameter SYNCHIGH1 = 8'h2; 
    parameter SYNCHIGH2 = 8'h3; 
    parameter SYNCHIGH3 = 8'h17; 
    parameter SYNCHIGH4 = 8'h18; 

    parameter PENDING = 8'h31; 

    parameter SYNCLOW0 = 8'h4; 
    parameter SYNCLOW1 = 8'h5; 
    parameter SYNCLOW2 = 8'h6; 
    parameter SYNCLOW3 = 8'h19; 
    parameter SYNCLOW4 = 8'h1a; 

    parameter DECODE0 = 8'h7; 
    parameter DECODE1 = 8'h8; 
    parameter DECODE2 = 8'h9; 
    parameter DECODE3 = 8'ha; 
    parameter DECODE4 = 8'hb; 
    parameter DECODE5 = 8'hc; 
    parameter DECODE6 = 8'hd; 
    parameter DECODE7 = 8'he; 
    parameter DECODE8 = 8'hf; 
    parameter DECODE9 = 8'h10; 
    parameter DECODEa = 8'h11; 
    parameter DECODEb = 8'h12; 

    parameter VERIFY0 = 8'h22;
    parameter VERIFY1 = 8'h23;
    parameter VERIFY2 = 8'h24;
    parameter VERIFY3 = 8'h25;

    reg [7:0] nxtState, curState, curStateBuf; 
    reg [5:0] bitcounter;

//    reg sample; 
    reg [30:0] sampleCounter; 
    reg [15:0] nextSamplePoint; 
//    reg [15:0] sampleDur = 16'h0002;
    reg trig_out_reg = 1'b0;
    reg curParity;
    reg [8:0] cur_error_count, cur_flags_count;
    reg [2:0] nxt_error_count, nxt_flags_count;
    
    reg [5:0] curSampledValue, nxtSampledValue;
//    reg [5:0] nxtSampledValue;
    reg [3:0] curSampledValueIndex, nxtSampledValueIndex; 
    
    always@(posedge pclk) begin
        if((curStateBuf == DECODE8) && (curState != DECODE8)) begin
            trig_out_reg <= ~trig_out_reg;
        end
    end

    always @(posedge pclk or negedge resetn) begin 
        if(~resetn) begin 
            sample <= 1'b0; 
            sampleCounter <= 31'h0; 
            nextSamplePoint <= 31'd24; // initial point 
        end else begin 
            if((curState == IDLE) || (curState == PENDING)) begin 
                sample <= 1'b0; 
                sampleCounter <= 31'h0; 
                nextSamplePoint <= 31'd8; // initial point 
            end else begin 
                sampleCounter <= sampleCounter + 1'b1; 
                // sample at middle of the pulse 
                if(sampleCounter == nextSamplePoint) begin 
                    sample <= 1'b1;
                end else begin
                    if(curState == VERIFY0) begin
                        sample <= 1'b0;
                        nextSamplePoint <= nextSamplePoint + 31'h50;
                    end
                        
                    if((curState > SYNCLOW2) && ((curState < DECODE9) || (curState[7:4] == 4'h2))) begin
                        if(sampleCounter >= (nextSamplePoint + 31'd3))begin
                            sample <= 1'b0;
                            nextSamplePoint <= nextSamplePoint + 31'd25; 
//                            sampleDur[0] <= ~sampleDur[0];
                        end
                    end else begin
                            if(sampleCounter > nextSamplePoint)begin
                            sample <= 1'b0;
                            if((curState == 8'h1a) && (curSampledValueIndex == 3'h3))
                                nextSamplePoint <= nextSamplePoint + 31'd17;
                            else
                                nextSamplePoint <= nextSamplePoint + 31'd10; 
                        end    
                    end
                end
            end 
        end 
    end 
    
       // the decoded value is determined by the majority of 
    // the sampled value 
    function [0:0] decodedValueSync;
        input [4:0] sampledValue;
        
        integer i; 
        reg [3:0] zeroCounter; 
        reg [3:0] oneCounter; 
        begin 
            zeroCounter = 4'h0; 
            oneCounter = 4'h0; 
            for(i=0;i<5;i=i+1) begin 
                if(sampledValue[i] == 1'b1) begin 
                    oneCounter = oneCounter + 1'b1; 
                end else if(sampledValue[i] == 1'b0) begin 
                    zeroCounter = zeroCounter + 1'b1; 
                end
            end 

            if(oneCounter > zeroCounter) begin 
                decodedValueSync = 1'b1; 
            end else if(oneCounter < zeroCounter) begin 
                decodedValueSync = 1'b0; 
            end else begin 
                decodedValueSync = 1'bz; 
            end 
        end 
    endfunction

    // the decoded value is determined by the majority of 
    // the sampled value 
    function [2:0] decodedValue;
        input [5:0] sampledValue;
               
        
        integer i; 
        reg [3:0] zeroCounter;
        reg [3:0] oneCounter; 
        reg [3:0] one;
        begin 
            zeroCounter = 4'h0; 
            oneCounter = 4'h0; 
            one = 4'h1;
            for(i=0;i<6;i=i+1) begin 
//                if((curState > 8'h6) && (curState < 8'h13)) begin
                    if(sampledValue[i] == 1'b1) begin 
                        oneCounter = oneCounter + 1'b1; 
                    end if(sampledValue[i] == 1'b0) begin 
                        zeroCounter = zeroCounter + 1'b1; 
                    end
//                end else begin
//                    if(sampledValue[i] == 1'b0) begin 
//                        zeroCounter = zeroCounter + 1'b1; 
//                    end else if(sampledValue[i] == 1'b1) begin 
//                        oneCounter = oneCounter + 1'b1; 
//                    end
            end 
            
//            for(i=0;i<3;i=i+1) begin 
//                if(sampledValue[i+3] == 1'b1) begin 
//                    oneCounter = oneCounter + 1'b1; 
//                end else begin// if(sampledValue[i+3] == 1'b0) begin 
//                    zeroCounter = zeroCounter + 1'b1; 
//                end
//            end 

            if(oneCounter > zeroCounter) begin
                if(zeroCounter > one) begin 
                    decodedValue = 3'b011; 
                end else begin//if(zeroCounter < 4'h2) begin
                    decodedValue = 3'b001;
                end
            end
                
            if(zeroCounter == oneCounter) begin
                decodedValue = 3'b101;
            end
              
            if(zeroCounter > oneCounter) begin  
                if(oneCounter > one) begin
                    decodedValue = 3'b010;
                end else begin//if(oneCounter < 4'h2) begin
                    decodedValue = 3'b000; 
                end
            end
        end
endfunction
  
    reg [11:0] curRawData;
    reg [11:0] nxtRawData;
    reg curDataValid, nxtDataValid; 

//    assign dataValid = curDataValid; 

//    SixBit2fourBit low(
//        .sixbitin(curRawData[5:0]), 
//        .fourbitout(data_o[3:0])
//    );
//    SixBit2fourBit high(
//        .sixbitin(curRawData[11:6]), 
//        .fourbitout(data_o[7:4])
//    );

    reg nxtParity = 1'b0;
    reg parity_parity;

    always @(posedge pclk or negedge resetn) begin 
        if(~resetn) begin 
            curState <= IDLE; 
            curRawData <= 12'h0; 
            curDataValid <= 1'b0; 
            curSampledValue <= 5'h0; 
            curSampledValueIndex = 4'h0; 
            curParity = 1'b0;
            cur_error_count = 9'b0;
            cur_flags_count = 9'b0;
            errors_all = 24'b0;
            flags_all = 24'b0;
        end else begin 
            curStateBuf <= curState;
            curState <= nxtState; 
            curRawData <= nxtRawData; 
            curDataValid <= nxtDataValid; 
            curSampledValue <= nxtSampledValue; 
            curSampledValueIndex <= nxtSampledValueIndex; 
            curParity <= nxtParity;
            cur_error_count <= {cur_error_count[5:0], nxt_error_count};
            cur_flags_count <= {cur_flags_count[5:0], nxt_flags_count};
            errors_all <= {errors_all[15:0], errors};
            flags_all <= {flags_all[15:0], flags};
            parity_parity <= tieoff[0];           
        end 
    end  

    always @(*) begin 
        nxtState = curState; 
        nxtRawData = curRawData; 
        nxtDataValid = 1'b0; 
        nxtSampledValue = curSampledValue; 
        nxtSampledValueIndex = curSampledValueIndex; 

        case(curState)
            IDLE: begin 
                nxtParity <= 1'b0;
                if(&RxD_sync) begin 
                    nxtState = SYNCHIGH0; 
                    nxtRawData = 12'h0; 
                end 
            end 

            SYNCHIGH0: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(decodedValueSync(curSampledValue)) begin 
                        nxtState = SYNCHIGH1; 
                    end else begin 
                        nxtState = IDLE; 
                    end 
                end 

                // if(RxD_sync[1]) begin 
                //     nxtState = SYNCHIGH1; 
                // end else begin 
                //     nxtState = IDLE; 
                // end 
            end 

            SYNCHIGH1: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(decodedValueSync(curSampledValue)) begin 
                        nxtState = SYNCHIGH2; 
                    end else begin 
                        nxtState = IDLE; 
                    end 
                end 
                // if(sample) begin 
                //     if(RxD_sync[1]) begin 
                //         nxtState = SYNCHIGH2; 
                //     end else begin 
                //         nxtState = IDLE; 
                //     end 
                // end 
            end 

            SYNCHIGH2: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(decodedValueSync(curSampledValue)) begin 
                        nxtState = SYNCHIGH3; 
                    end else begin 
                        nxtState = IDLE; 
                    end 
                end 
            end 

            SYNCHIGH3: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(decodedValueSync(curSampledValue)) begin 
                        nxtState = SYNCHIGH4; 
                    end else begin 
                        nxtState = IDLE; 
                    end 
                end 
            end 

            SYNCHIGH4: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(decodedValueSync({curSampledValue, 1'b1})) begin 
                        nxtState = PENDING; 
                    end else begin 
                        nxtState = IDLE; 
                    end 
                end 
            end 

            PENDING: begin 
                if(~|RxD_sync) begin 
                    nxtState = SYNCLOW0; 
                end 
            end 

            SYNCLOW0: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(~decodedValueSync(curSampledValue)) begin 
                        nxtState = SYNCLOW1; 
                    end else begin 
                        nxtState = SYNCLOW0; 
                    end 
                end 
            end 

            SYNCLOW1: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(~decodedValueSync(curSampledValue)) begin 
                        nxtState = SYNCLOW2; 
                    end else begin 
                        nxtState = IDLE; 
                    end 
                end 
            end 

            SYNCLOW2: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(~decodedValueSync(curSampledValue)) begin 
                        nxtState = SYNCLOW3; 
                    end else begin 
                        nxtState = IDLE; 
                    end 
                end 
            end 

            SYNCLOW3: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(~decodedValueSync(curSampledValue)) begin 
                        nxtState = SYNCLOW4; 
                    end else begin 
                        nxtState = IDLE; 
                    end 
                end 
            end 

            SYNCLOW4: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    if(~decodedValueSync({curSampledValue, 1'b0})) begin 
                        nxtState = DECODE0; 
                    end else begin 
                        nxtState = IDLE; 
                    end 
                end 
            end 

            // sample data (16 half bits)
            DECODE0: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                
                nxt_error_count = 3'b0;
                nxt_flags_count = 3'b0;
                
                end

                if(curSampledValueIndex == 4'h6) begin 
                    nxtSampledValueIndex = 4'h0; 
                    {errors[7], flags[7], nxtRawData[7]} = decodedValue(curSampledValue ^ 6'b000111); 
                    nxtParity = nxtRawData[7];
                    nxt_error_count = cur_error_count[2:0] + errors[7];
                    nxt_flags_count = cur_flags_count[2:0] + flags[7];
                    nxtState = DECODE1; 
                end 
                // if(sample) begin 
                //     nxtRawData[0] = RxD_sync[1]; 
                //     nxtState = DECODE1; 
                // end 
            end 

            DECODE1: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h6) begin 
                    nxtSampledValueIndex = 4'h0; 
                    {errors[6], flags[6], nxtRawData[6]} = decodedValue(curSampledValue ^ 6'b000111); 
                    nxtParity = curParity ^ nxtRawData[6];
                    nxt_error_count = cur_error_count[2:0] + errors[6];
                    nxt_flags_count = cur_flags_count[2:0] + flags[6];
                    nxtState = DECODE2; 
                end 
            end 

            DECODE2: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h6) begin 
                    nxtSampledValueIndex = 4'h0; 
                    {errors[5], flags[5], nxtRawData[5]} = decodedValue(curSampledValue ^ 6'b000111); 
                    nxtParity = curParity ^ nxtRawData[5];
                    nxt_error_count = cur_error_count[2:0] + errors[5];
                    nxt_flags_count = cur_flags_count[2:0] + flags[5];                    
                    nxtState = DECODE3; 
                end 
            end 

            DECODE3: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h6) begin 
                    nxtSampledValueIndex = 4'h0; 
                    {errors[4], flags[4], nxtRawData[4]} = decodedValue(curSampledValue ^ 6'b000111); 
                    nxtParity = curParity ^ nxtRawData[4];
                    nxt_error_count = cur_error_count[2:0] + errors[4];
                    nxt_flags_count = cur_flags_count[2:0] + flags[4];                    
                    nxtState = DECODE4; 
                end 
            end 

            DECODE4: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h6) begin 
                    nxtSampledValueIndex = 4'h0; 
                    {errors[3], flags[3], nxtRawData[3]} = decodedValue(curSampledValue ^ 6'b000111); 
                    nxtParity = curParity ^ nxtRawData[3];
                    nxt_error_count = cur_error_count[2:0] + errors[3];
                    nxt_flags_count = cur_flags_count[2:0] + flags[3];                    
                    nxtState = DECODE5; 
                end 
            end 

            DECODE5: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h6) begin 
                    nxtSampledValueIndex = 4'h0; 
                    {errors[2], flags[2], nxtRawData[2]} = decodedValue(curSampledValue ^ 6'b000111); 
                    nxtParity = curParity ^ nxtRawData[2];
                    nxt_error_count = cur_error_count[2:0] + errors[2];
                    nxt_flags_count = cur_flags_count[2:0] + flags[2];                    
                    nxtState = DECODE6; 
                end 
            end 

            DECODE6: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h6) begin 
                    nxtSampledValueIndex = 4'h0; 
                    {errors[1] , flags[1], nxtRawData[1]} = decodedValue(curSampledValue ^ 6'b000111); 
                    nxtParity = curParity ^ nxtRawData[1];
                    nxt_error_count = cur_error_count[2:0] + errors[1];
                    nxt_flags_count = cur_flags_count[2:0] + flags[1];                    
                    nxtState = DECODE7; 
                end 
            end 

            DECODE7: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h6) begin 
                    nxtSampledValueIndex = 4'h0; 
                    {errors[0], flags[0], nxtRawData[0]} = decodedValue(curSampledValue ^ 6'b000111); 
                    nxtParity = curParity ^ nxtRawData[0];
                    nxt_error_count = cur_error_count[2:0] + errors[0];
                    nxt_flags_count = cur_flags_count[2:0] + flags[0];                    
                    nxtState = DECODE8; 
                end 
            end 

            DECODE8: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    {tieoff[2], tieoff[1], tieoff[0]} = decodedValue(curSampledValue ^ 6'b000111); 
//                    nxt_parity_real = curParity ^ tieoff[0];
                    if(bitcounter == 6'd35)
                        nxtState = VERIFY0;
                    else
                        nxtState = DECODE0; 
                end 
            end 

            DECODE9: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[9] = decodedValue(curSampledValue); 
                    nxtState = DECODEa; 
                end 
            end 

            DECODEa: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[10] = decodedValue(curSampledValue); 
                    nxtState = DECODEb; 
                end 
            end 

            DECODEb: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[11] = decodedValue(curSampledValue); 
                    nxtState = VERIFY0; 
                end 
            end 

            VERIFY0: begin 
                // if there is more than five continous zeros 
                // or ones, for example, six ones, 
                // this data is no loger consider as valid 
                // because in 4b6b code, with one bit err, the maximum 
                // continous 1/0 are five 
//                for(i=0;i<7;i=i+1) begin 
//                    verifyReg[i] = (&curRawData[i +: 6]) | (&(~curRawData[i +: 6])); 
//                end 
                nxtState = VERIFY1; 
            end 

            VERIFY1: begin 
                // if any ones at the reg 
//                if(|verifyReg) begin 
//                    nxtDataValid <= 1'b0; 
                    nxtState <= VERIFY2; 
//                end else begin 
//                    nxtDataValid <= 1'b1; 
//                    nxtState <= DECODE0; 
//                end 
            end 
            
            VERIFY2: begin 
                    nxtState <= VERIFY3; 
            end 
            
            VERIFY3: begin 
                    nxtState <= IDLE; 
            end 

            default: begin 
                nxtState = IDLE; 
            end 
        endcase 
    end 
    
    always@(posedge pclk) begin
        if(curStateBuf == DECODE8) begin
            if(curState != curStateBuf) begin
                if(bitcounter < 6'd35)
                    bitcounter <= bitcounter + 1;
            end
        end
        if(curState == IDLE)
            bitcounter <= 18'b0;
    end
    
    reg validFlag = 1'b0;
    reg validReq = 1'b0;
    reg [4:0] dataValid_reg = 5'b0;

    always@(posedge pclk) begin
        dataValid_reg[4:1] <= dataValid_reg[3:0];
        if(validReq == 1'b1) begin
            if(validFlag == 1'b0) begin
                dataValid_reg[0] <= 1'b1;
                validFlag <= 1'b1;
            end else begin
                dataValid_reg[0] <= 1'b0;
            end
        end else begin
            dataValid_reg[0] <= 1'b0;
            validFlag <= 1'b0;
        end
    end
    
    always@(posedge pclk) begin
        if((curStateBuf == DECODE8) && (curState != DECODE8))
            validReq <= 1'b1;
        else
            validReq <= 1'b0;
    end
            
    
    assign data_o = curRawData[7:0];
//    assign trig_out = trig_out_reg;
//    assign errors_out = errors_all[23:16];
//    assign flags_out = flags_all[23:16];
//    assign errors_count = cur_error_count[8:6];
//    assign flags_count = cur_flags_count[8:6];
    assign dataValid = dataValid_reg[4];
    assign parity_out = curParity ^ parity_parity;


endmodule



