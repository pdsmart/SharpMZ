## Generated SDC file "sharpmz-lite.out.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.1.1 Internal Build 593 12/11/2017 SJ Standard Edition"

## DATE    "Fri Nov 16 23:12:31 2018"

##
## DEVICE  "5CSEBA6U23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {FPGA_CLK1_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {FPGA_CLK1_50}]
create_clock -name {FPGA_CLK2_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {FPGA_CLK2_50}]
create_clock -name {FPGA_CLK3_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {FPGA_CLK3_50}]
create_clock -name {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk} -period 10.000 -waveform { 0.000 5.000 } [get_pins -compatibility_mode {*|h2f_user0_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {CK112M} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 224 -divide_by 100 -master_clock {FPGA_CLK3_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {CK64M} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 128 -divide_by 100 -master_clock {FPGA_CLK3_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[1]}] 
create_generated_clock -name {CK32M} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 64 -divide_by 100 -master_clock {FPGA_CLK3_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[2]}] 
create_generated_clock -name {CK16M} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 32 -divide_by 100 -master_clock {FPGA_CLK3_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[3]}] 
create_generated_clock -name {CK8M} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 16 -divide_by 100 -master_clock {FPGA_CLK3_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[4]}] 
create_generated_clock -name {CK4M} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 8 -divide_by 100 -master_clock {FPGA_CLK3_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[5]}] 
create_generated_clock -name {CK2M} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 4 -divide_by 100 -master_clock {FPGA_CLK3_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN01|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[6]}] 
create_generated_clock -name {CK56M75} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 1135 -divide_by 1000 -master_clock {FPGA_CLK2_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {CK28M375} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 5675 -divide_by 10000 -master_clock {FPGA_CLK2_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[1]}] 
create_generated_clock -name {CK25M175} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 5035 -divide_by 10000 -master_clock {FPGA_CLK2_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[2]}] 
create_generated_clock -name {CK17M734475} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 3546895 -divide_by 10000000 -master_clock {FPGA_CLK2_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[3]}] 
create_generated_clock -name {CK14M1875} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 28375 -divide_by 100000 -master_clock {FPGA_CLK2_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[4]}] 
create_generated_clock -name {CK8M867237} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 17734474 -divide_by 100000000 -master_clock {FPGA_CLK2_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[5]}] 
create_generated_clock -name {CK7M09375} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 141875 -divide_by 1000000 -master_clock {FPGA_CLK2_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[6]}] 
create_generated_clock -name {CK3M546875} -source [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 709375 -divide_by 10000000 -master_clock {FPGA_CLK2_50} [get_pins {emu|sharp_mz|CLKGEN0|PLLMAIN02|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[7]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {CK56M75}] -rise_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -rise_from [get_clocks {CK56M75}] -fall_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -fall_from [get_clocks {CK56M75}] -rise_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -fall_from [get_clocks {CK56M75}] -fall_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -rise_from [get_clocks {CK112M}] -rise_to [get_clocks {CK112M}] -setup 0.190  
set_clock_uncertainty -rise_from [get_clocks {CK112M}] -rise_to [get_clocks {CK112M}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CK112M}] -fall_to [get_clocks {CK112M}] -setup 0.190  
set_clock_uncertainty -rise_from [get_clocks {CK112M}] -fall_to [get_clocks {CK112M}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CK112M}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.170  
set_clock_uncertainty -rise_from [get_clocks {CK112M}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.170  
set_clock_uncertainty -rise_from [get_clocks {CK112M}] -rise_to [get_clocks {FPGA_CLK3_50}]  0.220  
set_clock_uncertainty -rise_from [get_clocks {CK112M}] -fall_to [get_clocks {FPGA_CLK3_50}]  0.220  
set_clock_uncertainty -fall_from [get_clocks {CK112M}] -rise_to [get_clocks {CK112M}] -setup 0.190  
set_clock_uncertainty -fall_from [get_clocks {CK112M}] -rise_to [get_clocks {CK112M}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CK112M}] -fall_to [get_clocks {CK112M}] -setup 0.190  
set_clock_uncertainty -fall_from [get_clocks {CK112M}] -fall_to [get_clocks {CK112M}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CK112M}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.170  
set_clock_uncertainty -fall_from [get_clocks {CK112M}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.170  
set_clock_uncertainty -fall_from [get_clocks {CK112M}] -rise_to [get_clocks {FPGA_CLK3_50}]  0.220  
set_clock_uncertainty -fall_from [get_clocks {CK112M}] -fall_to [get_clocks {FPGA_CLK3_50}]  0.220  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {CK112M}]  0.170  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {CK112M}]  0.170  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.060  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {FPGA_CLK3_50}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {FPGA_CLK3_50}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {FPGA_CLK2_50}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {FPGA_CLK2_50}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {CK112M}]  0.170  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {CK112M}]  0.170  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.060  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {FPGA_CLK3_50}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {FPGA_CLK3_50}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -rise_to [get_clocks {FPGA_CLK2_50}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}] -fall_to [get_clocks {FPGA_CLK2_50}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {FPGA_CLK3_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {FPGA_CLK3_50}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {FPGA_CLK3_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {FPGA_CLK3_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {FPGA_CLK3_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -rise_to [get_clocks {FPGA_CLK3_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {FPGA_CLK3_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK3_50}] -fall_to [get_clocks {FPGA_CLK3_50}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK3_50}]  0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK3_50}]  0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK2_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK2_50}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK2_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK2_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {CK112M}]  0.220  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {sysmem|fpga_interfaces|clocks_resets|h2f_user0_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK3_50}]  0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK3_50}]  0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK2_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -rise_to [get_clocks {FPGA_CLK2_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK2_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {FPGA_CLK2_50}] -fall_to [get_clocks {FPGA_CLK2_50}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_ports {KEY*}] 
set_false_path -from [get_ports {BTN_*}] 
set_false_path -to [get_ports {LED_*}]
set_false_path -to [get_ports {VGA_*}]
set_false_path -to [get_ports {AUDIO_SPDIF}]
set_false_path -to [get_ports {AUDIO_L}]
set_false_path -to [get_ports {AUDIO_R}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

