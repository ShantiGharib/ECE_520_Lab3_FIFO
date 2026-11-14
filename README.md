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
    I created a python script that selects a random number of test iterations
    from 20 to 1024. For each iteration, it randomly
    chooses one operation, either write, read, or reset.
    Additonally, the likelihood of each operation is not uniform.
    Each run of the script will select a random value from 20% to 95%
    which becomes the odds of a write operation. It will select another value between
    1% to 2.5% whoch becomes the odds of a reset.
    The difference between 100% and the sum of the write and reset odds
    becomes the odds of a read operation.
    The sequence of operations are encoded in a text file.
    The results the fifo should read are encoded in another text file.
    The testbench follows the operations in the first textfile, and 
    verifies its read values against the second text file.
    A bunch of if statements are used to ensure all the signals remain
    valid across the duration of the testbench.

# Known Issues or Limitations
    --empty
# References
    --empty
