I. Create and configure a new project

  1. Upon launching Vivado, select *Create Project*
  2. Choose the project name and root directory in your filesystem
  3. Select *RTL Project* without specifying sources
  4. Select *xc7z020clg400-1* from the *Parts* list

II. Add and configure Zynq core

  1. Click on *Create block diagram* in the left-hand menu selection. Rename the block diagram as you wish.
  2. In the *Diagram* tab, click on the '+' symbol in the top selection bar. Type in *ZYNQ7 Processing System* and confirm. You will see an unconfigured ZYNQ block appear in your block diagram.
  3. Double-click on the Zynq block. Under 'Interrupts', enable IRQ_F2P[15:0] under the PL-PS Interrupt Ports subsection. Change the page navigator to MIO Configuration - there, enable Quad SPI Flash to MIO 1...6, and enable CAN0 to MIO 14...15. Next, under the PS-PL configuration tab in the page navigator, enable S AXI HP0 interface.
  4. Still in the Zynq core configuration settings, click on the *Clock configuration* tab. Under PL Fabric Clocks, enable the FCLK_CLK0 clock, using the IO PLL as the source, and request a frequency of 100 MHz. Leave all other settings at default and confirm configuration by click *OK*

IV. Add custom IP to design

  1. Import all verilog sources from the *verilog* directory found on this github page to the *design sources* tab in Vivado.
  2. Drag-and-drop the following custom IP modules from the *design sources* tab into your design block diagram: *partialwrappernew, fbsbdecoder, axi_slave_wrapper, pwm*.

V. Make connections between IP blocks
  1. Find the block diagram template named ADC_vppm.pdf found within the Rx folder of this github project. Use it as a template to finish all missing connections in your block design. Any necessary external input/output pins can be added by clicking on a input/output node of an IP block and typing Ctrl+K. You can use the 'make connections automatically' tool for any AXI connections to avoid the configuraition of the AXI Interconnect block.

VI. Validate project, add constraints and create bitfile
  1. Press the 'validate design' button on the top menu bar (or press F6) to validate all connections. Fix any errors reported.
  2. Right-click on the block design name found within the 'sources' section on the left-hand side of the screen. Click on *Create HDL Wrapper...* and Vivado manage wrapper in the next dialogue.
  3. Set the created wrapper as top by right-clicking on the wrapper and selecting *Set as Top*.
  4. Add the constaints file named XADC_LCD_wrapper.xdc to the project
  5. Create bitfile through synthesis and implementation and then export the hardware. Upon completing this, you will be able to move on to building software by launching SDK
