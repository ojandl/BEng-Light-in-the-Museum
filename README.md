<p>This repository contains complementary source code to my final year BEng thesis titled 'Light in the Museum'. It also contains instructions how to reproduce this project, given the availability of suitable hardware.

**BEng thesis title:** Light in the Museum<br>
**Author:** Oldřich Jandl<br>
**University:** The University of Edinburgh<br>
**Date of submission:** 3. 5. 2023<br>
</p>


The top level overview of the designed system is shown below. Note that this repository solely concerns digital subsystems (blocks contained within the light blue background in the figure below). Information regarding analogue subsystems can be found in the thesis.

![image](https://github.com/ojandl/BEng-Light-in-the-Museum/assets/147755709/b54069c1-cf0c-4e08-94c1-e1fd5831fb05)

**Navigation**
+ Rx
  + Source codes (Verilog) for reconstructing Vivado project for the receiver FPGA
  + Software code (C) running on Zynq PS
+ Tx
  + Source codes for reconstructing Vivado project for the transmitter FPGA
  + Software code (C) running on Microblaze core
+ Documentation
  + Instructions, required software, hardware used, thesis abstract,...

Please consult the README.md file found within the corresponding subdirectory for further details about each section.
