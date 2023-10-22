void welcome_screen(void){
              LCD_DisplayChar('W', 20, 100, BLACK, WHITE);
            	LCD_DisplayChar('E', 36, 100, BLACK, WHITE);
            	LCD_DisplayChar('L', 52, 100, BLACK, WHITE);
            	LCD_DisplayChar('C', 68, 100, BLACK, WHITE);
            	LCD_DisplayChar('O', 84, 100, BLACK, WHITE);
            	LCD_DisplayChar('M', 100, 100, BLACK, WHITE);
            	LCD_DisplayChar('E', 116, 100, BLACK, WHITE);
}

void main_menu(void){
              LCD_DisplayChar('M', 20, 20, BLACK, WHITE);
            	LCD_DisplayChar('A', 36, 20, BLACK, WHITE);
            	LCD_DisplayChar('I', 52, 20, BLACK, WHITE);
            	LCD_DisplayChar('N', 68, 20, BLACK, WHITE);
            	LCD_DisplayChar('M', 100, 20, BLACK, WHITE);
            	LCD_DisplayChar('E', 116, 20, BLACK, WHITE);
            	LCD_DisplayChar('N', 132, 20, BLACK, WHITE);
            	LCD_DisplayChar('U', 148, 20, BLACK, WHITE);
}

void data_select(void){
	            	LCD_DisplayChar('-', 4, ROW1, BLUE, WHITE);
	            	LCD_DisplayChar('R', 20, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('e', 36, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('q', 52, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('u', 68, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('e', 84, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('s', 100, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('t', 116, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('I', 144, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('m', 160, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('a', 176, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('g', 192, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('e', 208, ROW1, BLACK, WHITE);

	            	LCD_DisplayChar('S', 20, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('e', 36, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('t', 52, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('D', 80, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('i', 96, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('m', 112, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('m', 128, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('i', 144, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('n', 160, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('g', 176, ROW2, BLACK, WHITE);

	            	LCD_DisplayChar('S', 20, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('e', 36, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('t', 52, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('B', 80, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('r', 96, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('i', 112, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('g', 128, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('h', 144, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('t', 160, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('n', 176, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('e', 192, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('s', 208, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('s', 224, ROW3, BLACK, WHITE);
}

void select_image(void){
              LCD_DisplayChar('S', POS1, 20, BLACK, WHITE);
            	LCD_DisplayChar('E', POS2, 20, BLACK, WHITE);
            	LCD_DisplayChar('L', POS3, 20, BLACK, WHITE);
            	LCD_DisplayChar('E', POS4, 20, BLACK, WHITE);
            	LCD_DisplayChar('C', POS5, 20, BLACK, WHITE);
            	LCD_DisplayChar('T', POS6, 20, BLACK, WHITE);
            	LCD_DisplayChar('I', POS8, 20, BLACK, WHITE);
            	LCD_DisplayChar('M', POS9, 20, BLACK, WHITE);
            	LCD_DisplayChar('A', POS10, 20, BLACK, WHITE);
            	LCD_DisplayChar('G', POS11, 20, BLACK, WHITE);
            	LCD_DisplayChar('E', POS12, 20, BLACK, WHITE);

	            	LCD_DisplayChar('-', 4, ROW1, BLUE, WHITE);
	            	LCD_DisplayChar('O', POS1, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('l', POS2, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('d', POS3, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('C', POS5, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('o', POS6, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('l', POS7, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('l', POS8, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('e', POS9, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('g', POS10, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('e', POS11, ROW1, BLACK, WHITE);


	            	LCD_DisplayChar('A', POS1, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('d', POS2, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('e', POS3, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('l', POS4, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('e', POS5, ROW2, BLACK, WHITE);

	            	LCD_DisplayChar('B', POS1, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('a', POS2, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('c', POS3, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('k', POS4, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('t', POS6, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('o', POS7, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('m', POS9, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('e', POS10, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('n', POS11, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('u', POS12, ROW3, BLACK, WHITE);
}

void change_dim(void){
              	LCD_DisplayChar('C', POS1, 20, BLACK, WHITE);
            	LCD_DisplayChar('H', POS2, 20, BLACK, WHITE);
            	LCD_DisplayChar('A', POS3, 20, BLACK, WHITE);
            	LCD_DisplayChar('N', POS4, 20, BLACK, WHITE);
            	LCD_DisplayChar('G', POS5, 20, BLACK, WHITE);
            	LCD_DisplayChar('E', POS6, 20, BLACK, WHITE);
            	LCD_DisplayChar('D', POS8, 20, BLACK, WHITE);
            	LCD_DisplayChar('I', POS9, 20, BLACK, WHITE);
            	LCD_DisplayChar('M', POS10, 20, BLACK, WHITE);

	            	LCD_DisplayChar('-', 4, ROW1, BLUE, WHITE);
	            	LCD_DisplayChar('L', POS1, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('o', POS2, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('w', POS3, ROW1, BLACK, WHITE);


	            	LCD_DisplayChar('M', POS1, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('e', POS2, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('d', POS3, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('i', POS4, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('u', POS5, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('m', POS6, ROW2, BLACK, WHITE);


	            	LCD_DisplayChar('H', POS1, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('i', POS2, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('g', POS3, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('h', POS4, ROW3, BLACK, WHITE);
}

void brightness(void){
              LCD_DisplayChar('B', POS1, 20, BLACK, WHITE);
            	LCD_DisplayChar('R', POS2, 20, BLACK, WHITE);
            	LCD_DisplayChar('I', POS3, 20, BLACK, WHITE);
            	LCD_DisplayChar('G', POS4, 20, BLACK, WHITE);
            	LCD_DisplayChar('H', POS5, 20, BLACK, WHITE);
            	LCD_DisplayChar('T', POS6, 20, BLACK, WHITE);
            	LCD_DisplayChar('N', POS7, 20, BLACK, WHITE);
            	LCD_DisplayChar('E', POS8, 20, BLACK, WHITE);
            	LCD_DisplayChar('S', POS9, 20, BLACK, WHITE);
            	LCD_DisplayChar('S', POS10, 20, BLACK, WHITE);


	            	LCD_DisplayChar('-', 4, ROW1, BLUE, WHITE);
	            	LCD_DisplayChar('L', POS1, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('o', POS2, ROW1, BLACK, WHITE);
	            	LCD_DisplayChar('w', POS3, ROW1, BLACK, WHITE);


	            	LCD_DisplayChar('M', POS1, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('e', POS2, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('d', POS3, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('i', POS4, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('u', POS5, ROW2, BLACK, WHITE);
	            	LCD_DisplayChar('m', POS6, ROW2, BLACK, WHITE);


	            	LCD_DisplayChar('H', POS1, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('i', POS2, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('g', POS3, ROW3, BLACK, WHITE);
	            	LCD_DisplayChar('h', POS4, ROW3, BLACK, WHITE);
}
