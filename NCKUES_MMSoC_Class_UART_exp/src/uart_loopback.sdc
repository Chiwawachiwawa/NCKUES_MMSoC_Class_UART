//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: V1.9.9 Beta-6
//Created Time: 2023-11-17 13:23:20
create_clock -name sys_clk -period 20 -waveform {0 10} [get_ports {sys_clk}]
