# ECE_520_LAB_3_FIFO
# Overview
    This lab is about coding a module in Verilog 
    or VHDL that implements 
    a Fifo for a FPGA board.
    The board chosen in my specific implementation 
    is the Zybo Z7-20. The language used is 
    VHDL 2008.
# Design Summary
    The block takes a clk signal, synchronous reset signal,
    DATA_IN signal, WRITE_ENABLE signal, and
    READ_ENABLE signal. The block prioritizes read attempts over 
    write attempts. The block has an internal memory block
    equal to the fifo depth size. It uses a write pointer
    and read pointer to track where to pop items and push items.
    When the fifo is full, it ignores write attempts.
    Likewise, when the fifo is empty, it ignores read attempts.
    The fifo has a read latency paraneter that defaults to one.
    One equates to no extra delay. Every additional value corresponds to 
    an extra clock cycle of output delay. The max
    configurable value is eight, the minimum is one.
    The fifo has configurable parameters for the word size, depth size,
    and Almost Full and Almost Empty Thresholds.
    The fifo outputs a valid signal, data_out signal, data_count signal,
    and full, almost_full, empty, and almost_empty threshold signals.
    The valid signal communicates whether the current read output
    corresponds to a non invalidated read attempt.
# Verification and Results
    ###TODO: change template to reflect this project
    I created two testbenches, one for each module. 
    
    For the blinking led module, because the module needs to count up to the value of the generic input, I added a test to check whether that aspect works. 
    I added another test to verify if when rst is 1 or when led_en is 0, that both the counter and led_out are always zero. This test has easy to follow comments in the code, so for more detail, go to code line 93 in ".\Lab1_rgb_led_ShantiGharib.srcs\sim_1\new\blinking_led_tb.vhd"

    For the rgb controller module, I created 7 different tests, where the first three tests are independent and the fourth test is comprised of 4 parts. The tests check whether each of the rgb color inputs and outputs work and whether any combination of at least two of the three rgb colors' enable signals results in the rgb never illuminating: rg, rb, gb, rgb.

    All the tests eventually passed.

# Known Issues or Limitations
    --empty
# References
    --empty
