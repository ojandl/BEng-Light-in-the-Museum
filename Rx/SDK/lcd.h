/*
 * lcd.h
 *
 *  Created on: 2022 July 28
 *      Author: hanji
 */

#ifndef SRC_LCD_H_
#define SRC_LCD_H_

#include "xparameters.h"
#include "xil_io.h"
#include "fonts.h"
#include "string.h"
#include <unistd.h>

// change the following two macro to corresponding
// base address shown in the xparameters.h
#define LCD_BASEADDR 0x60000000
#define PWM_BASEADDR 0x68000000

int LCD_Init();
void LCD_Reset();
void LCD_ResetHard();
void LCD_Clear(unsigned int color);
void LCD_SetBrightness(u32 brightness);
void LCD_SendData(u8 parameter);
void LCD_SendCMD(u8 cmd);
void LCD_SetScanDirecton(u16 direction);
void LCD_SetColourMode();
void LCD_SetStartCursorX(u16 start);
void LCD_SetStopCursorX(u16 stop);
void LCD_SetStartCursorY(u16 start);
void LCD_SetStopCursorY(u16 stop);
void LCD_SelfTest();
void LCD_ClearArea(u16 colour, u16 x, u16 y);
void LCD_Clean(void);



u8* findFontByChara(u8 chara);
void LCD_DisplayChar(u8 chara, u16 x, u16 y, u16 FontColour, u16 BackgroundColour);
void LCD_DisplayStr(char* str, u16 fontColour, u16 BackgroundColour, u16 xstart, u16 ystart);
void LCD_DisplayNum(u32 num, u16 fontColour, u16 BackgroundColour, u16 xstart, u16 ystart);

// Frequently used command
//#define LCD_DrawRect(colour, x, xlen, y, ylen) LCD_ClearArea(colour, x, xlen, y, ylen)
#define LCD_SleepOut(void)  LCD_SendCMD(0x1100)
#define LCD_DisplayOn(void)  LCD_SendCMD(0x2900)
#define LCD_StopTransmit(void) \
	Xil_Out32(LCD_BASEADDR, 0x11110000)


void LCD_SendCMD(u8 cmd){
	Xil_Out32(LCD_BASEADDR, 0x00111000 + cmd);
	Xil_Out32(LCD_BASEADDR, 0x00011000 + cmd);
	Xil_Out32(LCD_BASEADDR, 0x00111000 + cmd);
}

void LCD_SendData(u8 parameter){
	Xil_Out32(LCD_BASEADDR, 0x01111000 + parameter);
	Xil_Out32(LCD_BASEADDR, 0x01011000 + parameter);
	Xil_Out32(LCD_BASEADDR, 0x01111000 + parameter);
}

void Lcd_Init(void)
{
	Xil_Out32(LCD_BASEADDR, 0x11111000);
	usleep(5000);

	Xil_Out32(LCD_BASEADDR, 0x11111000);
	usleep(5000);
	Xil_Out32(LCD_BASEADDR, 0x11101000);
	usleep(15000);
	Xil_Out32(LCD_BASEADDR, 0x11111000);
	usleep(15000);

	Xil_Out32(LCD_BASEADDR, 0x11111000); //CS high, WR high
//	usleep(10);
	Xil_Out32(LCD_BASEADDR, 0x01111000); //CS low
//	usleep(10);

    LCD_SendCMD(0xCB);
    LCD_SendData(0x39);
    LCD_SendData(0x2C);
    LCD_SendData(0x00);
    LCD_SendData(0x34);
    LCD_SendData(0x02);

    LCD_SendCMD(0xCF);
    LCD_SendData(0x00);
    LCD_SendData(0XC1);
    LCD_SendData(0X30);

    LCD_SendCMD(0xE8);
    LCD_SendData(0x85);
    LCD_SendData(0x00);
    LCD_SendData(0x78);

    LCD_SendCMD(0xEA);
    LCD_SendData(0x00);
    LCD_SendData(0x00);

    LCD_SendCMD(0xED);
    LCD_SendData(0x64);
    LCD_SendData(0x03);
    LCD_SendData(0X12);
    LCD_SendData(0X81);

    LCD_SendCMD(0xF7);
    LCD_SendData(0x20);

    LCD_SendCMD(0xC0);    //Power control
    LCD_SendData(0x23);   //VRH[5:0]

    LCD_SendCMD(0xC1);    //Power control
    LCD_SendData(0x10);   //SAP[2:0];BT[3:0]

    LCD_SendCMD(0xC5);    //VCM control
    LCD_SendData(0x3e);   //Contrast
    LCD_SendData(0x28);

    LCD_SendCMD(0xC7);    //VCM control2
    LCD_SendData(0x86);   //--

    LCD_SendCMD(0x36);    // Memory Access Control
    LCD_SendData(0x48);

    LCD_SendCMD(0x3A);
    LCD_SendData(0x55);

    LCD_SendCMD(0xB1);
    LCD_SendData(0x00);
    LCD_SendData(0x18);

    LCD_SendCMD(0xB6);    // Display Function Control
    LCD_SendData(0x08);
    LCD_SendData(0x82);
    LCD_SendData(0x27);

    LCD_SendCMD(0x11);    //Exit Sleep
	usleep(120000);

    LCD_SendCMD(0x29);    //Display on
    LCD_SendCMD(0x2c);
}

void Address_set(unsigned int x1,unsigned int y1,unsigned int x2,unsigned int y2)
{
        LCD_SendCMD(0x2a);
	LCD_SendData(x1>>8);
	LCD_SendData(x1);
	LCD_SendData(x2>>8);
	LCD_SendData(x2);
        LCD_SendCMD(0x2b);
	LCD_SendData(y1>>8);
	LCD_SendData(y1);
	LCD_SendData(y2>>8);
	LCD_SendData(y2);
	LCD_SendCMD(0x2c);
	Xil_Out32(LCD_BASEADDR, 0x01111000); //CS low
}

void H_line(unsigned int x, unsigned int y, unsigned int l, unsigned int c)
{
  unsigned int i,j;
  LCD_SendCMD(0x02c); //write_memory_start
  l=l+x;
  Address_set(x,y,l,y);
  j=l*2;
  for(i=1;i<=j;i++)
  {
    LCD_SendData(c);
  }
  Xil_Out32(LCD_BASEADDR, 0x10111000); //CS high
}

void V_line(unsigned int x, unsigned int y, unsigned int l, unsigned int c)
{
  unsigned int i,j;
  LCD_SendCMD(0x02c); //write_memory_start

  l=l+y;
  Address_set(x,y,x,l);
  j=l*2;
  for(i=1;i<=j;i++)
  {
    LCD_SendData(c);
  }
  Xil_Out32(LCD_BASEADDR, 0x10111000); //CS high
}

void Rect(unsigned int x,unsigned int y,unsigned int w,unsigned int h,unsigned int c)
{
  H_line(x  , y  , w, c);
  H_line(x  , y+h, w, c);
  V_line(x  , y  , h, c);
  V_line(x+w, y  , h, c);
}

void Rectf(unsigned int x,unsigned int y,unsigned int w,unsigned int h,unsigned int c)
{
  unsigned int i;
  for(i=0;i<h;i++)
  {
    H_line(x  , y  , w, c);
    H_line(x  , y+i, w, c);
  }
}
int RGB(int r,int g,int b)
{return r << 16 | g << 8 | b;
}
void LCD_Clear(unsigned int j)
{
  unsigned int i,m;
 Address_set(0,0,240,320);
  //LCD_SendCMD(0x02c); //write_memory_start
  //digitalWrite(LCD_RS,HIGH);
 Xil_Out32(LCD_BASEADDR, 0x01111000); //CS low


  for(i=0;i<240;i++)
    for(m=0;m<320;m++)
    {
      LCD_SendData(j>>8);
      LCD_SendData(j);

    }
  Xil_Out32(LCD_BASEADDR, 0x10111000); //CS high
}

void LCD_Image(uint16_t* arr, int size) {
	 Address_set(0,0,240,320);
	 Xil_Out32(LCD_BASEADDR, 0x01111000); //CS low
	 unsigned int send;
  for (int i = 0; i < size; i++) {
	  send = *(arr+i);
	  LCD_SendData(send >> 8);
	  LCD_SendData(send);
  }
  Xil_Out32(LCD_BASEADDR, 0x10111000); //CS high
}

void LCD_DisplayChar(u8 chara, u16 x, u16 y, u16 FontColour, u16 BackgroundColour){
	u8* fontAddr;
	fontAddr = findFontByChara(chara);
	for(int i=0;i<256;i++){
		if(i % 4 == 0){
			Address_set(x, y+i/4, 240, 320);
		}
		u8 tmp = fontAddr[i];
		if(tmp == 0x00){
			LCD_SendData(BackgroundColour);
			LCD_SendData(BackgroundColour);
			LCD_SendData(BackgroundColour);
			LCD_SendData(BackgroundColour);
			LCD_SendData(BackgroundColour);
			LCD_SendData(BackgroundColour);
			LCD_SendData(BackgroundColour);
			LCD_SendData(BackgroundColour);
			continue;
		}


		for(int j=0;j<8;j++){
			if(tmp&0x80) LCD_SendData(FontColour);
			else LCD_SendData(BackgroundColour);
			tmp = tmp << 1;
		}
	}
	Xil_Out32(LCD_BASEADDR, 0x01111000); //CS low
}

void LCD_DisplayStr(char* str, u16 fontColour, u16 BackgroundColour, u16 xstart, u16 ystart){
	u16 x = xstart;
    u16 y = ystart;
    
    while (*str != '\0') {
        LCD_DisplayChar(*str, x, y, fontColour, BackgroundColour);
        str++;
        x += 16; // Assuming a font with a fixed width of 8 pixels
    }
}

void LCD_ClearArea(u16 colour, u16 x, u16 y){
	for(int i=0;i<256;i++){
		if(i % 4 == 0){
			Address_set(x, y+i/4, 240, 320);
		}
		for(int j=0; j<8; j++){
			LCD_SendData(colour);
		}

	}
}

void LCD_Clean(void){
	Address_set(0,0,240,320);

	for(int i=0; i<76800; i++){
		LCD_SendData(0xFF);
		LCD_SendData(0xFF);
	}
}

u8* findFontByChara(u8 chara){
	switch(chara){
		case 'a': return a_64;
		case 'b': return b_64;
		case 'c': return c_64;
		case 'd': return d_64;
		case 'e': return e_64;
		case 'f': return f_64;
		case 'g': return g_64;
		case 'h': return h_64;
		case 'i': return i_64;
		case 'j': return j_64;
		case 'k': return k_64;
		case 'l': return l_64;
		case 'm': return m_64;
		case 'n': return n_64;
		case 'o': return o_64;
		case 'p': return p_64;
		case 'q': return q_64;
		case 'r': return r_64;
		case 's': return s_64;
		case 't': return t_64;
		case 'u': return u_64;
		case 'v': return v_64;
		case 'w': return w_64;
		case 'x': return x_64;
		case 'y': return y_64;
		case 'z': return z_64;
		case 'A': return A_64;
		case 'B': return B_64;
		case 'C': return C_64;
		case 'D': return D_64;
		case 'E': return E_64;
		case 'F': return F_64;
		case 'G': return G_64;
		case 'H': return H_64;
		case 'I': return I_64;
		case 'J': return J_64;
		case 'K': return K_64;
		case 'L': return L_64;
		case 'M': return M_64;
		case 'N': return N_64;
		case 'O': return O_64;
		case 'P': return P_64;
		case 'Q': return Q_64;
		case 'R': return R_64;
		case 'S': return S_64;
		case 'T': return T_64;
		case 'U': return U_64;
		case 'V': return V_64;
		case 'W': return W_64;
		case 'X': return X_64;
		case 'Y': return Y_64;
		case 'Z': return Z_64;
		case ' ': return SPACE_64;
		case '.': return dot_64;
		case '0': return zero_64;
		case '1': return one_64;
		case '2': return two_64;
		case '3': return three_64;
		case '4': return four_64;
		case '5': return five_64;
		case '6': return six_64;
		case '7': return seven_64;
		case '8': return eight_64;
		case '9': return nine_64;
		case '-': return arrow_right_64;
		default:
			return NULL;
	}
}


#endif /* SRC_LCD_H_ */
