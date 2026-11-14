
--use UNISIM.VComponents.all;

entity fifo is
    generic(
        WIDTH : positive := 16; --size of each WORD
        DEPTH : positive := 32; --Number of WORDs that the FIFO can store (must be a power of two)
        ALMOST_EMPTY_THRESHOLD : positive := 1; --Number of words at or below which ALMOST_EMPTY is asserted
        ALMOST_FULL_THRESHOLD : positive := 31; --Number of words at or above which ALMOST_FULL is asserted
        READ_LATENCY : positive := 1 --Number of output pipeline register stages. Minimum is 1 and maximum is 8.
    );
    Port (
        CLK          : in std_logic;
        SRST         : in std_logic; --active high, resets read and write pointers
        DATA_IN      : in std_logic_vector(WIDTH-1 downto 0);
        WRITE_ENABLE : in std_logic; --active high, is respected only when FIFO has available space
        READ_ENABLE  : in std_logic; --active high, is respected only when FIFO is not empty

        VALID        : out std_logic := '0'; --for read ops
        DATA_COUNT   : out integer range 0 to DEPTH := 0;
        DATA_OUT     : out std_logic_vector(WIDTH-1 downto 0) := (others => '0');
        
        EMPTY, ALMOST_EMPTY : out std_logic := '1';
        FULL ,  ALMOST_FULL : out std_logic := '0'
    );
end fifo;

------------------RULES: 
-- accepts simultaneous read and write enables, but performs only one of the two. Prioritizes read enable.

architecture Behavioral of fifo is
    constant READ_LATENCY_MIN : integer := 1;
    constant READ_LATENCY_MAX : integer := 8;
    constant HAS_LATENCY : boolean := (READ_LATENCY > 1);
    signal READ_POINTER  : integer range 0 to DEPTH-1 := 0;
    signal WRITE_POINTER : integer range 0 to DEPTH-1 := 0;
    type slv_vector is array(natural range<>) of std_logic_vector(WIDTH-1 downto 0);
    signal FIFO_RAM : slv_vector(DEPTH-1 downto 0);
    signal DELAYED_OUTPUTS : slv_vector(READ_LATENCY-1 downto 0) := (others => (others => '0'));
    signal DELAYED_VALID_OUTPUT : std_logic_vector(READ_LATENCY-1 downto 0) := (others => '0');
begin
    assert (2**ceil_log2(DEPTH)) = DEPTH severity failure;
    assert (READ_LATENCY >= READ_LATENCY_MIN) and (READ_LATENCY <= READ_LATENCY_MAX) severity failure;
    assert ALMOST_EMPTY_THRESHOLD <= ALMOST_FULL_THRESHOLD and ALMOST_FULL_THRESHOLD <= DEPTH severity failure;

    FIFO_OPS : process(CLK)
        variable data_count_var : integer range 0 to DEPTH := 0;
    begin
        if (rising_edge(CLK)) then
            if (HAS_LATENCY) then
				--allow data_out to retain same value unless it absolutely should not to allow easier timing requirements
				--valid should still be one clock cycle
                -----READ Latency Pipeline
                DATA_OUT <= DELAYED_OUTPUTS(READ_LATENCY-2);
                VALID    <= DELAYED_VALID_OUTPUT(READ_LATENCY-2);
                for it in READ_LATENCY-2 downto 1 loop
                    DELAYED_OUTPUTS(it)      <= DELAYED_OUTPUTS(it-1);
                    DELAYED_VALID_OUTPUT(it) <= DELAYED_VALID_OUTPUT(it-1);
                end loop;
				DELAYED_VALID_OUTPUT(0) <= '0';
                -----
			else
				VALID <= '0';
            end if;
            
            if (SRST = '1') then
                READ_POINTER   <= 0;
                WRITE_POINTER  <= 0;
                data_count_var := 0;     
				DATA_OUT <= (others => '0');
				VALID    <= '0';
                if (HAS_LATENCY) then
                    DELAYED_OUTPUTS      <= (others => (others => '0'));
                    DELAYED_VALID_OUTPUT <= (others => '0');
                end if;
            elsif ((READ_ENABLE = '1') and (EMPTY /= '1')) then
                if (HAS_LATENCY) then
                    ---adjusted for READ Latency Pipeline---
                    DELAYED_OUTPUTS(0)      <= FIFO_RAM(READ_POINTER);
                    DELAYED_VALID_OUTPUT(0) <= '1';
                    ----------------------------------------
                else
                    DATA_OUT <= FIFO_RAM(READ_POINTER);
                    VALID    <= '1';
                end if;
                READ_POINTER   <= READ_POINTER + 1 when (READ_POINTER /= (DEPTH-1)) else 0;
                data_count_var := data_count_var - 1;

            elsif ((WRITE_ENABLE = '1') and (FULL /= '1')) then
                FIFO_RAM(WRITE_POINTER) <= DATA_IN;
                WRITE_POINTER  <= WRITE_POINTER + 1 when (WRITE_POINTER /= (DEPTH-1)) else 0;
                data_count_var := data_count_var + 1;
            end if;

            DATA_COUNT   <= data_count_var;
            ALMOST_EMPTY <= '1' when (data_count_var <= ALMOST_EMPTY_THRESHOLD) else '0';
            ALMOST_FULL  <= '1' when (data_count_var >=  ALMOST_FULL_THRESHOLD) else '0';
            EMPTY        <= '1' when (data_count_var  =                      0) else '0';
            FULL         <= '1' when (data_count_var  =                  DEPTH) else '0';
        end if;

    end process;


end Behavioral;

# ECE_520_LAB_3_FIFO
# Overview
    This lab is about coding a module in Verilog 
    or VHDL that implements 
    a Fifo for a FPGA board.
    The board chosen in my specific implementation 
    is the Zybo Z7-20. The language used is 
    VHDL 2008.
# Design Summary
    the block takes a clk signal, synchronous reset signal,
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
    full, almost_full, empty, and almost_empty threshold signals.
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
