I. Create and configure a new project

  1. Upon launching Vivado, select *Create Project*
  2. Choose the project name and root directory in your filesystem
  3. Select *RTL Project* without specifying sources
  4. Select *Arty S7-25* from the *Boards* list

II. Add and configure MicroBlaze core

  1. Click on *Create block diagram* in the left-hand menu selection. Rename the block diagram as you wish.
  2. In the *Diagram* tab, click on the '+' symbol in the top selection bar. Type in *Microblaze* and confirm. You will see an unconfigured Microblaze block appear in your block diagram.
  3. Double-click on the Microblaze block. Select *Microcontroller preset* in the 'Predefined configurations' option on the first page and keep the rest of the settings on default.
  4. Click on *Run block automation*. In the 'Preset' tab, select *Microcontroller*, and choose the highest value for the 'Local Memory'. Keep the other options unchangedand confirm.

III. Configure clock and add DDR3 SDRAM

  1. Double-click on the Clocking wizard IP block. Select *sys clock* as 'CLK_IN1' and verify in the 'Output clocks' tab that the frequency of 'clk_out1' is equal to 100 MHz.
  2. Click on *Run connection automation*. Select *clk_in1* and *reset* under the clk_wiz_1 block only. Confirm.
  3. In the *Boards* tab, right-click on DDR3 SDRAM and select *Auto connect*.
  4. Next to the newly-created 'Memory interface generator' block, new input nodes clock nodes labelled 'clk_ref_i' and 'sys_clk_i' have been created by default. Delete both of these by right-clicking on each node and pressing the *delete* key.

IV. Add custom IP to design

  1. Import all verilog sources from the *verilog* directory found on this github page to the *design sources* tab in Vivado.
  2. Drag-and-drop the following custom IP modules from the *design sources* tab into your design block diagram: *slowClock, fbsbdecoder, partialwrapper, axi_slave_wrapper, resethandle*.
  3. Add two *Constant* blocks to your design by clicking the 'plus' icon in the top bar. For the first constant block, configure it by a double-click to a value of '0' and a width of '1'. Then, connect its output pin to the *in1* input pin of the microblaze_0_xlconcat block. For the second constant block, set the value to '0', width to '12' and then connect this to the 'device_temp_i[11:0] input of the Memory Interface Generator block.

V. Make connections between IP blocks
  1. Find the block diagram template named vppm_new.pdf found within the Tx folder of this github project. Use it as a template to finish all missing connections in your block design. Any necessary external input/output pins can be added by clicking on a input/output node of an IP block and typing Ctrl+K. You can use the 'make connections automatically' tool for any AXI connections to avoid the configuraition of the AXI Interconnect block.

VI. Validate project, add constraints and create bitfile
  1. Press the 'validate design' button on the top menu bar (or press F6) to validate all connections. Fix any errors reported.
  2. Right-click on the block design name found within the 'sources' section on the left-hand side of the screen. Click on *Create HDL Wrapper...* and Vivado manage wrapper in the next dialogue.
  3. Set the created wrapper as top by right-clicking on the wrapper and selecting *Set as Top*.
  4. Add the constaints file named Arty-S7-25-Master.xdc to the project
  5. Create bitfile through synthesis and implementation and then export the hardware. Upon completing this, you will be able to move on to building software by launching SDK
