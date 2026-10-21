----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/06/2026 12:02:30 PM
-- Design Name: 
-- Module Name: fifo_tb - Behavioral
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
use std.textio.all;
package input_file_parse is
    procedure Next_Step(file input_file : TEXT; L: inout LINE; IS_FIFO_READ_OP : out boolean; write_number : out integer);
	procedure Next_Step_Writes_Only(file input_file : TEXT; L: inout LINE; write_number : out integer);
end package;

package body input_file_parse is
	procedure Next_Step_Writes_Only(file input_file : TEXT; L: inout LINE; write_number : out integer) is
	begin
		readline(input_file, L);
		read(L, write_number);
	end procedure;

    procedure Next_Step(file input_file : TEXT; L: inout LINE; IS_FIFO_READ_OP : out boolean; write_number : out integer) is
        variable first_char : character;
    begin
		write_number := 0;
		readline(input_file, L);
        read(L, first_char);
		if (first_char = '-') then
			IS_FIFO_READ_OP := true;
		else
			IS_FIFO_READ_OP := false;
			read(L, write_number);
		end if;
    end procedure;

end package body;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.finish;
use std.textio.all;
use work.input_file_parse.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo_random2_tb is
--  Port ( );
end fifo_random2_tb;

architecture Behavioral of fifo_random2_tb is
    file input_file : TEXT open READ_MODE is "../../../../sim/input_data.txt";
	file input_file_writes_only : TEXT open READ_MODE is "../../../../sim/input_data_writes_only.txt";
    constant CLK_PERIOD : time := 20 ns;
    --------------generics----
    constant WIDTH_TB : integer := 24;
    constant DEPTH_TB : integer := 2**4;
    constant ALMOST_EMPTY_THRESHOLD_TB : integer := 8;
    constant ALMOST_FULL_THRESHOLD_TB : integer  := 8;
    constant READ_LATENCY_TB : integer := 5;
    -------------------------

    --------------ports------
    signal DATA_IN_TB : std_logic_vector(WIDTH_TB-1 downto 0) := (others => '0');
    
    signal CLK_TB          : std_logic := '0';
    signal SRST_TB         : std_logic := '0'; --active high
    signal WRITE_ENABLE_TB : std_logic := '0'; --active high
    signal READ_ENABLE_TB  : std_logic := '0'; --active high

    --FIFO driven---
    signal DATA_OUT_TB     : std_logic_vector(WIDTH_TB-1 downto 0);
    signal DATA_COUNT_TB   : integer;
    signal VALID_TB        : std_logic;
    signal ALMOST_FULL_TB  : std_logic;
    signal ALMOST_EMPTY_TB : std_logic;
    signal FULL_TB         : std_logic;
    signal EMPTY_TB        : std_logic;
    ---------------
    -------------------------
	signal read_latency_valid_counter : std_logic_vector(READ_LATENCY_TB downto 0) := (others => '0'); --synchronous behavior delays FIFO by one clock cycle 
	signal do_fifo_read_sig : boolean := false;
	signal write_num_sig     : integer := 0;
	signal next_read_num_sig : integer := 0;
	signal FIFO_JUST_MADE_FULL_sig : boolean := false;
	signal data_available_sig : integer := 0;
begin

    CLK_PROCESS : process
    begin
        wait for CLK_PERIOD / 2;
        CLK_TB <= '0';
        wait for CLK_PERIOD / 2;
        CLK_TB <= '1';
    end process;


    fifo_inst: entity work.fifo
    generic map (
    WIDTH                  => WIDTH_TB,
    DEPTH                  => DEPTH_TB,
    ALMOST_EMPTY_THRESHOLD => ALMOST_EMPTY_THRESHOLD_TB,
    ALMOST_FULL_THRESHOLD  => ALMOST_FULL_THRESHOLD_TB,
    READ_LATENCY           => READ_LATENCY_TB
    )
    port map (
    CLK          => CLK_TB,
    SRST         => SRST_TB,
    DATA_IN      => DATA_IN_TB,
    WRITE_ENABLE => WRITE_ENABLE_TB,
    READ_ENABLE  => READ_ENABLE_TB,
    DATA_COUNT   => DATA_COUNT_TB,
    VALID        => VALID_TB,
    DATA_OUT     => DATA_OUT_TB,
    ALMOST_FULL  => ALMOST_FULL_TB,
    ALMOST_EMPTY => ALMOST_EMPTY_TB,
    FULL         => FULL_TB,
    EMPTY        => EMPTY_TB
    );

    test_process : process
    variable L : line;
	variable L_writes_only : line;
	variable do_fifo_read : boolean := false;
	variable write_num     : integer := 0;
	variable next_read_num : integer := 0;
	variable FIFO_JUST_MADE_FULL : boolean := false;
	variable data_available : integer := 0;
    begin
		while not endfile(input_file) loop
            wait until rising_edge(CLK_TB);
			if (READ_ENABLE_TB = '1' and (data_available > DATA_COUNT_TB or (read_latency_valid_counter(0) = '1' and data_available = DATA_COUNT_TB)))
			then
				report "TEST FAILED: DATA_COUNT not accurate";
				if (data_available > DATA_COUNT_TB) then
				    report "data_available should not exceed the FIFO's data_count output after a Read request";
				else
				    report "data_available should always be one clock cycle ahead of the FIFO's data_count output after a successful Read operation";
				end if;
                report "data_available = " & to_string(data_available) & ", DATA_COUNT = " & to_string(DATA_COUNT_TB);
                wait for CLK_PERIOD/4;
				finish;
			elsif (WRITE_ENABLE_TB = '1' and (data_available < DATA_COUNT_TB or (not FIFO_JUST_MADE_FULL and data_available = DEPTH_TB and data_available = DATA_COUNT_TB)))
			then
				report "TEST FAILED: DATA_COUNT not accurate";
				if (data_available < DATA_COUNT_TB) then
				    report "data_available should not be less than the FIFO's data_count output after a write request";
				else
				    report "data_available should always be one clock cycle ahead of the FIFO's data_count output after a successful write operation";
				end if;
                report "data_available = " & to_string(data_available) & ", DATA_COUNT = " & to_string(DATA_COUNT_TB);
                wait for CLK_PERIOD/4;
				finish;			
			elsif (DATA_COUNT_TB = 0 and EMPTY_TB /= '1')
			then
				report "TEST FAILED: EMPTY Flag not working";
                wait for CLK_PERIOD/4;
				finish;
			elsif (DATA_COUNT_TB = DEPTH_TB and FULL_TB /= '1')
			then
				report "TEST FAILED: FULL Flag not working";
                wait for CLK_PERIOD/4;
				finish;
			elsif (DATA_COUNT_TB <= ALMOST_EMPTY_THRESHOLD_TB and ALMOST_EMPTY_TB /= '1')
			then
				report "TEST FAILED: ALMOST_EMPTY Flag not working";
                wait for CLK_PERIOD/4;
				finish;
			elsif (DATA_COUNT_TB >= ALMOST_FULL_THRESHOLD_TB and ALMOST_FULL_TB /= '1') then
				report "TEST FAILED: ALMOST_FULL Flag not working";
                wait for CLK_PERIOD/4;
				finish;
			end if;
    		
			Next_Step(input_file, L, do_fifo_read, write_num);
			
			if (read_latency_valid_counter(READ_LATENCY_TB) = '1') then
                if (not endfile(input_file_writes_only)) then
                    Next_Step_Writes_Only(input_file_writes_only, L_writes_only, next_read_num);
                else
                    report "Catastrophic file reading error has occurred. TEST SIGNIFICANTLY FAILED";
                    wait for CLK_PERIOD/4;
                    finish;
                end if;
                if (VALID_TB /= '1' or DATA_OUT_TB /= std_logic_vector(to_unsigned(next_read_num, WIDTH_TB))) then
				    report "TEST FAILED: Either the FIFO storage, the Read_Latency pipeline, or both err";
				    report "VALID_TB = " & to_string(VALID_TB) & ", DATA_OUT_TB = " & to_string(TO_INTEGER(unsigned(DATA_OUT_TB))) & ", Next READ Number = " & to_string(next_read_num);
                    wait for CLK_PERIOD/4;
				    finish;
                end if;
			end if;
			
			FIFO_JUST_MADE_FULL := false;
			read_latency_valid_counter(READ_LATENCY_TB downto 1) <= read_latency_valid_counter(READ_LATENCY_TB-1 downto 0);
            read_latency_valid_counter(0) <= '0';
			if (do_fifo_read) then
				--read
				READ_ENABLE_TB <= '1';
				WRITE_ENABLE_TB <= '0';
				if (data_available /= 0) then
					data_available := data_available - 1;
					read_latency_valid_counter(0) <= '1';
				else
					read_latency_valid_counter(0) <= '0';
				end if;
			else
				--write
				READ_ENABLE_TB <= '0';
				WRITE_ENABLE_TB <= '1';
				if (data_available /= DEPTH_TB) then
					FIFO_JUST_MADE_FULL := true when (data_available = DEPTH_TB - 1) else false;
					data_available := data_available + 1;
					DATA_IN_TB <= std_logic_vector(to_unsigned(write_num, WIDTH_TB));
				end if;
			end if;
            do_fifo_read_sig <= do_fifo_read;
	        write_num_sig <= write_num;
	        next_read_num_sig <= next_read_num;
	        FIFO_JUST_MADE_FULL_sig <= FIFO_JUST_MADE_FULL;
	        data_available_sig <= data_available;
		end loop;

		report "RNG TEST PASSED";
        wait for CLK_PERIOD/4;
		finish;
    
	end process;


end Behavioral;