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
#include "irq.h"
#include "unistd.h"
#include "lcd.h"
#include "fonts.h"
#include "data.h"

#define BLACK 0x0000
#define WHITE 0xFFFF
#define BLUE 0x001F

#define INIT 0
#define MENU 1
#define DATA_SELECT 2
#define RECEIVE 3
#define DIM_SELECT 4
#define BRIGHT_SELECT 5
#define STAT 6
#define STAT2 7
#define STAT3 8
#define STAT4 9

#define LOW 0
#define MID 1
#define HIGH 2

#define ROW1 90
#define ROW2 160
#define ROW3 230

#define POS1 20
#define POS2 36
#define POS3 52
#define POS4 68
#define POS5 84
#define POS6 100
#define POS7 116
#define POS8 132
#define POS9 148
#define POS10 164
#define POS11 180
#define POS12 196
#define POS13 212
#define POS14 128

#define LANDSCAPE 1
#define ADELE 2
#define BACK 3

void show_stats(uint32_t paritys);
void show_stats2(void);
void show_stats3(void);
void show_stats4(void);
void show_stats5(void);



volatile static int BUTTON0 = FALSE;
volatile static int BUTTON1 = FALSE;
volatile static int packets = 0;
volatile uint32_t errors;
volatile uint32_t parity;
volatile uint32_t correction;

int main()
{
    init_platform();

    Lcd_Init();
    LCD_Image(data, 76800);


    sleep(1);
    int i;
    int Status;
	int state = INIT;
	int state_data = LANDSCAPE;
	int state_dim = MID;
	int state_bright = MID;
	int dim = LOW;
	int bright = HIGH;
	int arrow = LOW;
	unsigned int new, hold, send;
	static int broken = FALSE;
	new = 0;
	hold = 0;

    /*
    *  Run the Gic example , specify the Device ID generated in xparameters.h
    */
    Status = ScuGicExample(INTC_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        print("GIC Example Test Failed\r\n");
        return XST_FAILURE;
    }

    while(1){
		switch (state) {
            case INIT:

				LCD_Clean();
               	usleep(100);

                welcome_screen();
                sleep(5); // wait for 2 seconds
                state = MENU; // move to the next state
                break;
            case MENU:
            	LCD_Clean();
            	packets = 0;
                	LCD_ClearArea(WHITE, 20, 100);
                	LCD_ClearArea(WHITE, 36, 100);
                	LCD_ClearArea(WHITE, 52, 100);
                	LCD_ClearArea(WHITE, 68, 100);
                	LCD_ClearArea(WHITE, 84, 100);
                	LCD_ClearArea(WHITE, 100, 100);
					LCD_ClearArea(WHITE, 116, 100);

		main_menu();

            	state = DATA_SELECT;

			data_select();



					while(BUTTON1 == FALSE){
						if((state == DATA_SELECT) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW1);
							state = DIM_SELECT;
			            	LCD_DisplayChar('-', 4, ROW2, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						if((state == DIM_SELECT) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW2);
							state = BRIGHT_SELECT;
			            	LCD_DisplayChar('-', 4, ROW3, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						if((state == BRIGHT_SELECT) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW3);
							state = DATA_SELECT;
			            	LCD_DisplayChar('-', 4, ROW1, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						usleep(100);


				}
				BUTTON1 = FALSE;
                break;

            case DATA_SELECT:
				LCD_Clean();
				LCD_Clean();

            	usleep(100);
            	state_data = LANDSCAPE;
            	state = RECEIVE;

            	select_image();

	            	usleep(40000);

	            	BUTTON1 = FALSE;

					while(BUTTON1 == FALSE){
						if((state_data == LANDSCAPE) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW1);
							state = RECEIVE;
							state_data = ADELE;
			            	LCD_DisplayChar('-', 4, ROW2, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						if((state_data == ADELE) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW2);
							state = MENU;
							state_data = BACK;
			            	LCD_DisplayChar('-', 4, ROW3, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						if((state_data == BACK) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW3);
							state = RECEIVE;
							state_data = LANDSCAPE;
			            	LCD_DisplayChar('-', 4, ROW1, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						usleep(100);


				}
				BUTTON1 = FALSE;
				break;


            case RECEIVE:
           	 Xil_Out32(0x6000000C, 0x00000001);
        	 Xil_Out32(0x6000000C, 0);

        	 LCD_Clean();

            	 Address_set(0,0,240,320);
            	 Xil_Out32(LCD_BASEADDR, 0x01111000); //CS low

            	for(int j = 0; j < 5; j++){
            		if(state_data == ADELE){
            	     Xil_Out32(0x60000008, 0x11111111);
            	     Xil_Out32(0x60000008, 0x11111111);
            		}
            		if(state_data == LANDSCAPE){
            			Xil_Out32(0x60000008, 0x22222222);
            			Xil_Out32(0x60000008, 0x22222222);
            		}
            	}

            	BUTTON1 = FALSE;

            	for (int i = 0; i < (76800/2); i++) {
            		 while((hold & 0x10000000) == (new & 0x10000000)){
            			 new = Xil_In32(0x60000084);
            			 if(BUTTON1 == TRUE){
            				 broken = TRUE;
            				 break;
            			 }
            		 }
					 hold = new;
					 send = Xil_In32(0x60000080);

					 LCD_SendData(send >> 24);
					 LCD_SendData(send >> 16);
					 LCD_SendData(send >> 8);
					 LCD_SendData(send);
					 packets += 1;
					 if(broken == TRUE){
						 broken = FALSE;
						 break;
					 }
            	 }
            	while((BUTTON0 == FALSE) && (BUTTON1 == FALSE)){
            	}
            	BUTTON0 = FALSE;
            	BUTTON1 = FALSE;
            	state = STAT;
            	break;

            case STAT:
				LCD_Clean();
				if(state_data == ADELE){
            	show_stats(32);
				} else {
					show_stats(26);
				}

				sleep(3);
				if(BUTTON1 == TRUE){
					state = MENU;
					BUTTON1 = FALSE;
				}
				else{
					state = STAT2;
				}
            	break;
			
			case STAT2:
				LCD_Clean();

				show_stats2();

            	sleep(3);
				if(BUTTON1 == TRUE){
					state = MENU;
					BUTTON1 = FALSE;
				}
				else{
					state = STAT;
				}

            	break;

			case DIM_SELECT:
				LCD_Clean();

            		change_dim();

	            	usleep(40000);

	            	BUTTON1 = FALSE;
					state = MENU;

					while(BUTTON1 == FALSE){
						if((state_dim == LOW) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW1);
							state_dim = MID;
			            	LCD_DisplayChar('-', 4, ROW2, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						if((state_dim == MID) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW2);
							state_dim = HIGH;
			            	LCD_DisplayChar('-', 4, ROW3, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						if((state_dim == HIGH) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW3);
							state_dim = LOW;
			            	LCD_DisplayChar('-', 4, ROW1, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}
					}

				switch(state_dim){
					case LOW:
	            	     Xil_Out32(0x60000008, 0x55555555);
	            	     Xil_Out32(0x60000008, 0x55555555);
	            	     break;
					case MID:
	            	     Xil_Out32(0x60000008, 0x33333333);
	            	     Xil_Out32(0x60000008, 0x33333333);
	            	     break;
					case HIGH:
	            	     Xil_Out32(0x60000008, 0x44444444);
	            	     Xil_Out32(0x60000008, 0x44444444);
	            	     break;
				}
				BUTTON1 = FALSE;
				usleep(100);

				break;
			case BRIGHT_SELECT:
				LCD_Clean();

            		brightness();

	            	usleep(40000);

	            	BUTTON1 = FALSE;
					state = MENU;

					while(BUTTON1 == FALSE){
						if((state_bright == LOW) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW1);
							state_bright = MID;
			            	LCD_DisplayChar('-', 4, ROW2, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						if((state_bright == MID) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW2);
							state_bright = HIGH;
			            	LCD_DisplayChar('-', 4, ROW3, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}

						if((state_bright == HIGH) && (BUTTON0 == TRUE)){
							LCD_ClearArea(WHITE, 4, ROW3);
							state_bright = LOW;
			            	LCD_DisplayChar('-', 4, ROW1, BLUE, WHITE);
			            	BUTTON0 = FALSE;
						}
					}

				switch(state_bright){
					case LOW:
	            	     Xil_Out32(0x60000004, 0x00000000);
	            	     break;
					case MID:
	            	     Xil_Out32(0x60000004, 0x00000001);
	            	     break;
					case HIGH:
	            	     Xil_Out32(0x60000004, 0x00000002);
	            	     break;
				}

				BUTTON1 = FALSE;
				usleep(100000);
				break;

             }
    }

    print("Hello World\n\r");

    cleanup_platform();
    return 0;
}


void DeviceDriverHandler(void *CallbackRef)
{
	errors = Xil_In32(0x60000088);
	correction = Xil_In32(0x60000090);
	parity =  Xil_In32(0x60000094);

	unsigned int input = Xil_In32(0x60000084);
    while ((input & 0x00110000) != 0) {
        if((input & 0x00010000) != 0){
        	BUTTON0 = TRUE;
		}
		else{
			BUTTON0 = FALSE;
		}
		if((input & 0x00100000) != 0) {
			BUTTON1 = TRUE;
		}
		else{
			BUTTON1 = FALSE;
		}
        input = Xil_In32(0x60000084);
    }
}

void fifo_wait(void){
	unsigned int input = Xil_In32(0x60000084);
	unsigned int fifo_full = input & 0x01000000;


	while(fifo_full != 0){
		input = Xil_In32(0x60000084);
		fifo_full = input & 0x01000000;

	}
}

void show_stats(uint32_t paritys){

    char buffer[11]; // Maximum size of 32-bit unsigned integer in decimal format + null terminator

    sprintf(buffer, "%u", parity); // Convert the uint32_t value to a string in decimal format
    int positions [] = {POS1, POS2, POS3, POS4, POS5, POS6, POS7, POS8};

    LCD_DisplayChar('P', positions[0], ROW1, BLACK, WHITE);
    LCD_DisplayChar('a', positions[1], ROW1, BLACK, WHITE);
    LCD_DisplayChar('r', positions[2], ROW1, BLACK, WHITE);
    LCD_DisplayChar('i', positions[3], ROW1, BLACK, WHITE); 
    LCD_DisplayChar('t', positions[4], ROW1, BLACK, WHITE);
    LCD_DisplayChar('y', positions[5], ROW1, BLACK, WHITE); 


    for (int i = 0; buffer[i] != '\0'; i++) {
		uint8_t digit = buffer[i];
        LCD_DisplayChar(digit, positions[i], ROW2, BLACK, WHITE); 
        }
    LCD_DisplayChar(' ', positions[2], ROW2, BLACK, WHITE); 
    LCD_DisplayChar(' ', positions[3], ROW2, BLACK, WHITE);
    LCD_DisplayChar(' ', positions[4], ROW2, BLACK, WHITE);


    }

void show_stats2(void){

	    char buffer[11]; // Maximum size of 32-bit unsigned integer in decimal format + null terminator

	    sprintf(buffer, "%u", packets); // Convert the uint32_t value to a string in decimal format
	    int positions [] = {POS1, POS2, POS3, POS4, POS5, POS6, POS7, POS8};

	    LCD_DisplayChar('P', positions[0], ROW1, BLACK, WHITE); // Send the digit using the send() function
	    LCD_DisplayChar('a', positions[1], ROW1, BLACK, WHITE); // Send the digit using the send() function
	    LCD_DisplayChar('c', positions[2], ROW1, BLACK, WHITE); // Send the digit using the send() function
	    LCD_DisplayChar('k', positions[3], ROW1, BLACK, WHITE); // Send the digit using the send() function
	    LCD_DisplayChar('e', positions[4], ROW1, BLACK, WHITE); // Send the digit using the send() function
	    LCD_DisplayChar('t', positions[5], ROW1, BLACK, WHITE); // Send the digit using the send() function
	    LCD_DisplayChar('s', positions[6], ROW1, BLACK, WHITE); // Send the digit using the send() function



	    for (int i = 0; buffer[i] != '\0'; i++) {
			uint8_t digit = buffer[i];
	        LCD_DisplayChar(digit, positions[i], ROW2, BLACK, WHITE); // Send the digit using the send() function
	        }

	    }

void show_stats3(void){

    char buffer[11]; // Maximum size of 32-bit unsigned integer in decimal format + null terminator

    sprintf(buffer, "%u", correction); // Convert the uint32_t value to a string in decimal format
    int positions [] = {POS1, POS2, POS3, POS4, POS5, POS6, POS7, POS8, POS9, POS10, POS11};

    LCD_DisplayChar('C', positions[0], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('o', positions[1], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('r', positions[2], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('r', positions[3], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('e', positions[4], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('c', positions[5], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('t', positions[6], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('i', positions[7], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('o', positions[8], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('n', positions[9], ROW1, BLACK, WHITE); // Send the digit using the send() function
    LCD_DisplayChar('s', positions[10], ROW1, BLACK, WHITE); // Send the digit using the send() function



    for (int i = 0; buffer[i] != '\0'; i++) {
		uint8_t digit = buffer[i];
        LCD_DisplayChar(digit, positions[i], ROW2, BLACK, WHITE); // Send the digit using the send() function
        }

    }



