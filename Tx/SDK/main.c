/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include <unistd.h>
#include "data.h"

#define DELAY 100000
#define BLACK 0x00000000
#define WHITE 0xFFFFFFFF
#define RED 0xF800F800
#define GREEN 0x07E007E0
#define BLUE 0x001F001F

void fifo_wait(void);

int main (void){

    init_platform();
    print("Init done\n\r");

	int i;
    uint16_t *data_ptr = (uint16_t *) landscape; // cast uint16_t pointer to uint32_t pointer
    uint32_t send, input, trig, trig_new;
    input = 0;
    int j, k;
    char buf[9];

    	for(j = 0; j < 1000000; j++){

		trig_new = (Xil_In32(0x44A00084) & 0x00000100);
  		trig = trig_new;


		input = 220;


			if (input == 220) {
			    data_ptr = (uint16_t *) landscape; // cast uint16_t pointer to uint32_t pointer
			}
			else if (input == 238){
			    data_ptr = (uint16_t *) adele; // cast uint16_t pointer to uint32_t pointer
			}
			else if (input == 204){
			    Xil_Out32(0x44A00004, 0x00000000);
			    continue;
			}
			else if (input == 186){
			    Xil_Out32(0x44A00004, 0x00000020);
			    continue;
			}
			else {
			    Xil_Out32(0x44A00004, 0x00000010);
			    continue;
			}



			for (i = 0; i < (76800/2); i++) {

				// Set top 16 bits of send equal to the value that the pointer is pointing to
				send = (uint32_t) (*data_ptr) << 16;
				// Set lower 16 bits of send equal to the next value of the array
				data_ptr++;
				send |= (uint32_t) (*data_ptr);
				data_ptr++;

				Xil_Out32(0x44A00000, send);

				fifo_wait();

			}
    	}


    cleanup_platform();
    return 0;
}

void fifo_wait(void){
	unsigned int input = Xil_In32(0x44A00084);
	unsigned int fifo_full = input & 0x00010000;


	while(fifo_full != 0){
		input = Xil_In32(0x44A00084);
		fifo_full = input & 0x00010000;

	}
}
