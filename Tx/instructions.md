I. Create and configure a new project

  1. Upon launching Vivado, select *Create Project*
  2. Choose the project name and root directory in your filesystem
  3. Select *RTL Project* without specifying sources
  4. Select *Arty S7-25* from the *Boards* list

II. 

  1. Click on *Create block diagram* in the left-hand menu selection. Rename the block diagram as you wish.
  2. In the *Diagram* tab, click on the '+' symbol in the top selection bar. Type in *Microblaze* and confirm. You will see an unconfigured Microblaze block appear in your block diagram.
  3. Double-click on the Microblaze block. Select *Microcontroller preset* in the 'Predefined configurations' option on the first page and keep the rest of the settings on default.
  4. Click on *Run block automation*. In the 'Preset' tab, select *Microcontroller*, and choose the highest value for the 'Local Memory'. Keep the other options unchangedand confirm.

  1. Double-click on the Clocking wizard IP block. Select *sys clock* as 'CLK_IN1' and verify in the 'Output clocks' tab that the frequency of 'clk_out1' is equal to 100 MHz.
  2. Click on *Run connection automation*. Select *clk_in1* and *reset* under the clk_wiz_1 block only. Confirm.
  3. In the *Boards* tab, right-click on DDR3 SDRAM and select *Auto connect*.
  4. Next to the newly-created 'Memory interface generator' block, new input nodes clock nodes labelled 'clk_ref_i' and 'sys_clk_i' have been created by default. Delete both of these by right-clicking on each node and pressing the *delete* key.
  5. 
