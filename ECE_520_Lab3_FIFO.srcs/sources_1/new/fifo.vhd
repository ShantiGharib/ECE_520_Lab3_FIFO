----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/04/2026 11:09:14 AM
-- Design Name: 
-- Module Name: fifo - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.functions.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
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
        CLK : in std_logic;
        SRST : in std_logic; --active high, resets read and write pointers
        DATA_IN : in std_logic_vector(WIDTH-1 downto 0);
        WRITE_ENABLE : in std_logic; --active high, is respected only when FIFO has available space
        READ_ENABLE : in std_logic; --active high, is respected only when FIFO is not empty

        DATA_COUNT : out integer range 0 to DEPTH := 0;
        VALID : out std_logic := '0'; --for read ops
        DATA_OUT : out std_logic_vector(WIDTH-1 downto 0); --all zeroes is a valid output so VALID Flag should be used to indicate whether data_out has meaningful value
        ALMOST_FULL : out std_logic;
        ALMOST_EMPTY : out std_logic;
        FULL : out std_logic;
        EMPTY : out std_logic
    );
end fifo;

------------------RULES: 
-- accepts simultaneous read and write enables, but performs only one of the two. Prioritizes read enable.

architecture Behavioral of fifo is
    constant READ_LATENCY_MIN : integer := 1;
    constant READ_LATENCY_MAX : integer := 8;
    signal READ_POINTER  : integer range 0 to DEPTH-1 := 0;
    signal WRITE_POINTER : integer range 0 to DEPTH-1 := 0;
    type slv_vector is array(natural range<>) of std_logic_vector(WIDTH-1 downto 0);
    signal FIFO_RAM : slv_vector(DEPTH-1 downto 0);
    signal DELAYED_OUTPUTS : slv_vector(READ_LATENCY-1 downto 0) := (others => (others => '0'));
    signal DELAYED_VALID_OUTPUT : std_logic_vector(READ_LATENCY-1 downto 0) := (others => '0');
begin
    assert (2**ceil_log2(DEPTH)) = DEPTH;
    assert (READ_LATENCY >= READ_LATENCY_MIN) and (READ_LATENCY <= READ_LATENCY_MAX);
    assert ALMOST_EMPTY_THRESHOLD <= ALMOST_FULL_THRESHOLD and ALMOST_FULL_THRESHOLD <= DEPTH;

    ALMOST_EMPTY <= '1' when (DATA_COUNT <= ALMOST_EMPTY_THRESHOLD) else '0';
    ALMOST_FULL  <= '1' when (DATA_COUNT >=  ALMOST_FULL_THRESHOLD) else '0';
    EMPTY <= '1' when (DATA_COUNT =     0) else '0';
    FULL  <= '1' when (DATA_COUNT = DEPTH) else '0';
    DATA_OUT <= DELAYED_OUTPUTS(READ_LATENCY-1);
    VALID <= DELAYED_VALID_OUTPUT(READ_LATENCY-1);

    FIFO_OPS : process(CLK)
    begin
        if (rising_edge(CLK)) then
            -----READ Latency Pipeline
            for it in READ_LATENCY-1 downto 1 loop
                DELAYED_OUTPUTS(it) <= DELAYED_OUTPUTS(it-1);
                DELAYED_VALID_OUTPUT(it) <= DELAYED_VALID_OUTPUT(it-1);
            end loop;
            DELAYED_OUTPUTS(0) <= (others => '0'); --final value determined below
            DELAYED_VALID_OUTPUT(0) <= '0';        --final value determined below
            -----
            if (SRST = '1') then
                READ_POINTER  <= 0;
                WRITE_POINTER <= 0;
                DATA_COUNT    <= 0;
                DELAYED_VALID_OUTPUT <= (others => '0'); --last assignment wins for signals
                DELAYED_OUTPUTS <= (others => (others => '0'));
            elsif ((READ_ENABLE = '1') and (EMPTY = '0')) then
                ---adjusted for READ Latency Pipeline---
                DELAYED_OUTPUTS(0) <= FIFO_RAM(READ_POINTER);
                DELAYED_VALID_OUTPUT(0) <= '1';
                ----------------------------------------
                READ_POINTER <= READ_POINTER + 1 when (READ_POINTER /= (DEPTH-1)) else 0;
                DATA_COUNT <= DATA_COUNT - 1;
            elsif ((WRITE_ENABLE = '1') and (FULL = '0')) then
                FIFO_RAM(WRITE_POINTER) <= DATA_IN;
                WRITE_POINTER <= WRITE_POINTER + 1 when (WRITE_POINTER /= (DEPTH-1)) else 0;
                DATA_COUNT <= DATA_COUNT + 1;
            end if;
        end if;

    end process;


end Behavioral;
