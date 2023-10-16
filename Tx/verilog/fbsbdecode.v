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
    output reg dataValid,
    output [7:0] data,
    output trig_out
    );
    
    reg sample;
    wire dataNew;
//    wire [7:0] data_o;

    reg [1:0] RxD_sync;
    always @(posedge pclk) begin 
        RxD_sync <= {RxD_sync[0], rx}; 
    end 

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

    reg [7:0] curState, nxtState, curStateBuf; 
//    reg [7:0] nxtState, curStateBuf; 
    reg [5:0] bitcounter;

//    reg sample; 
    reg [15:0] sampleCounter; 
    reg [15:0] nextSamplePoint; 
    reg trig_out_reg = 1'b0;
    
    reg [4:0] curSampledValue, nxtSampledValue;
    reg [3:0] curSampledValueIndex, nxtSampledValueIndex; 
    
    always@(posedge pclk) begin
        if((curStateBuf == DECODE7) && (curState != DECODE7)) begin
            trig_out_reg <= ~trig_out_reg;
        end
    end

    always @(posedge pclk or negedge resetn) begin 
        if(~resetn) begin 
            sample <= 1'b0; 
            sampleCounter <= 16'h0; 
            nextSamplePoint <= 16'd24; // initial point 
        end else begin 
            if((curState == IDLE) || (curState == PENDING)) begin 
                sample <= 1'b0; 
                sampleCounter <= 16'h0; 
                nextSamplePoint <= 16'd8; // initial point 
            end else begin 
                sampleCounter <= sampleCounter + 1'b1; 
                // sample at middle of the pulse 
                if(sampleCounter == nextSamplePoint) begin 
                    sample <= 1'b1;
                end else begin
                    if((curState >= DECODE0) && (curState <= DECODE7)) begin
                        if(sampleCounter >= (nextSamplePoint + 16'h4))begin
                            sample <= 1'b0;
                            nextSamplePoint <= nextSamplePoint + 16'd50; 
                        end
                    end else begin
                            if(sampleCounter > nextSamplePoint)begin
                            sample <= 1'b0;
                            if((curState == SYNCLOW4) && (curSampledValueIndex == 4'h3))
                                nextSamplePoint <= nextSamplePoint + 16'd20; 
                            else
                                nextSamplePoint <= nextSamplePoint + 16'd10; 
                        end    
                    end
                end
            end 
        end 
    end 
    
       // the decoded value is determined by the majority of 
    // the sampled value 
    function [0:0] decodedValue;
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
                decodedValue = 1'b1; 
            end else if(oneCounter < zeroCounter) begin 
                decodedValue = 1'b0; 
            end else begin 
                decodedValue = 1'bz; 
            end 
        end 
    endfunction

    // the decoded value is determined by the majority of 
    // the sampled value 
//    function [0:0] decodedValue;
//        input [4:0] sampledValue;
               
        
//        integer i; 
//        reg [3:0] zeroCounter; 
//        reg [3:0] oneCounter; 
//        begin 
//            zeroCounter = 4'h0; 
//            oneCounter = 4'h0; 
//            for(i=0;i<3;i=i+1) begin 
//                if((curState > 8'h6) && (curState < 8'h13)) begin
//                    if(sampledValue[i] == 1'b1) begin 
//                        zeroCounter = zeroCounter + 1'b1; 
//                    end else if(sampledValue[i] == 1'b0) begin 
//                        oneCounter = oneCounter + 1'b1; 
//                    end
//                end else begin
//                    if(sampledValue[i] == 1'b0) begin 
//                        zeroCounter = zeroCounter + 1'b1; 
//                    end else if(sampledValue[i] == 1'b1) begin 
//                        oneCounter = oneCounter + 1'b1; 
//                    end
//            end 
            
//            for(i=0;i<2;i=i+1) begin 
//                if(sampledValue[i] == 1'b1) begin 
//                    oneCounter = oneCounter + 1'b1; 
//                end else if(sampledValue[i] == 1'b0) begin 
//                    zeroCounter = zeroCounter + 1'b1; 
//                end
//            end 

//            if(oneCounter > zeroCounter) begin 
//                decodedValue = 1'b1; 
//            end else if(oneCounter < zeroCounter) begin 
//                decodedValue = 1'b0; 
//            end else begin 
//                decodedValue = 1'bz; 
//            end 
//        end 
//    end
//endfunction
  
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

    always @(posedge pclk or negedge resetn) begin 
        if(~resetn) begin 
            curState <= IDLE; 
            curRawData <= 12'h0; 
            curDataValid <= 1'b0; 
            curSampledValue <= 5'h0; 
            curSampledValueIndex = 4'h0; 
        end else begin 
            curStateBuf <= curState;
            curState <= nxtState; 
            curRawData <= nxtRawData; 
            curDataValid <= nxtDataValid; 
            curSampledValue <= nxtSampledValue; 
            curSampledValueIndex <= nxtSampledValueIndex; 
        end 
    end 
    
    

    // used for verify 
    integer i; 
    reg [6:0] verifyReg; 

    always @(*) begin 
        nxtState = curState; 
        nxtRawData = curRawData; 
        nxtDataValid = 1'b0; 
        nxtSampledValue = curSampledValue; 
        nxtSampledValueIndex = curSampledValueIndex; 

        case(curState)
            IDLE: begin 
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
                    if(decodedValue(curSampledValue)) begin 
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
                    if(decodedValue(curSampledValue)) begin 
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
                    if(decodedValue(curSampledValue)) begin 
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
                    if(decodedValue(curSampledValue)) begin 
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
                    if(decodedValue({curSampledValue[3:0], 1'b1})) begin 
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
                    if(~decodedValue(curSampledValue)) begin 
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
                    if(~decodedValue(curSampledValue)) begin 
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
                    if(~decodedValue(curSampledValue)) begin 
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
                    if(~decodedValue(curSampledValue)) begin 
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
                    if(~decodedValue({curSampledValue[3:0], 1'b0})) begin 
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
                end 

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[7] = ~decodedValue(curSampledValue); 
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

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[6] = ~decodedValue(curSampledValue); 
                    nxtState = DECODE2; 
                end 
            end 

            DECODE2: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[5] = ~decodedValue(curSampledValue); 
                    nxtState = DECODE3; 
                end 
            end 

            DECODE3: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[4] = ~decodedValue(curSampledValue); 
                    nxtState = DECODE4; 
                end 
            end 

            DECODE4: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[3] = ~decodedValue(curSampledValue); 
                    nxtState = DECODE5; 
                end 
            end 

            DECODE5: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[2] = ~decodedValue(curSampledValue); 
                    nxtState = DECODE6; 
                end 
            end 

            DECODE6: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[1] = ~decodedValue(curSampledValue); 
                    nxtState = DECODE7; 
                end 
            end 

            DECODE7: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h4) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[0] = ~decodedValue(curSampledValue); 
//                    if(bitcounter == 6'd35)
                        nxtState = IDLE;
//                    else
//                        nxtState = DECODE0; 
                end 
            end 

            DECODE8: begin 
                if(sample) begin 
                    nxtSampledValue[nxtSampledValueIndex] = RxD_sync[1]; 
                    nxtSampledValueIndex = curSampledValueIndex + 1'b1; 
                end 

                if(curSampledValueIndex == 4'h5) begin 
                    nxtSampledValueIndex = 4'h0; 
                    nxtRawData[8] = decodedValue(curSampledValue); 
                    nxtState = DECODE9; 
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
                for(i=0;i<7;i=i+1) begin 
                    verifyReg[i] = (&curRawData[i +: 6]) | (&(~curRawData[i +: 6])); 
                end 
                nxtState = VERIFY1; 
            end 

            VERIFY1: begin 
                // if any ones at the reg 
                if(|verifyReg) begin 
                    nxtDataValid <= 1'b0; 
                    nxtState <= IDLE; 
                end else begin 
                    nxtDataValid <= 1'b1; 
                    nxtState <= DECODE0; 
                end 
            end 

            default: begin 
                nxtState = IDLE; 
            end 
        endcase 
    end 
    
//    always@(posedge pclk) begin
//        if(curStateBuf == DECODE7) begin
//            if(curState != curStateBuf) begin
//                if(bitcounter < 6'd36)
//                    bitcounter <= bitcounter + 1;
//            end
//        end
//        if(curState == IDLE)
//            bitcounter <= 6'b0;
//    end
    
    reg validFlag = 1'b0;
    reg validReq = 1'b0;

    always@(posedge pclk) begin
        if(validReq == 1'b1) begin
            if(validFlag == 1'b0) begin
                dataValid <= 1'b1;
                validFlag <= 1'b1;
            end else begin
                dataValid <= 1'b0;
            end
        end else begin
            dataValid <= 1'b0;
            validFlag <= 1'b0;
        end
    end
    
    always@(curState) begin
        if(curStateBuf == DECODE7)
            validReq <= 1'b1;
        else
            validReq <= 1'b0;
    end
            
    
    assign data = curRawData[7:0];
    assign trig_out = trig_out_reg;


endmodule



