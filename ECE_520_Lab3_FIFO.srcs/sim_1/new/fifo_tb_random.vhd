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
	type FIFO_OP is (READ_FIFO, WRITE_FIFO, RESET_FIFO);
    procedure Next_Step(file input_file : TEXT; L: inout LINE; PENDING_FIFO_OP : out FIFO_OP; write_number : out integer);
	procedure Next_Step_Writes_Only(file input_file : TEXT; L: inout LINE; write_number : out integer);
end package;

package body input_file_parse is
	procedure Next_Step_Writes_Only(file input_file : TEXT; L: inout LINE; write_number : out integer) is
	begin
		readline(input_file, L);
		read(L, write_number);
	end procedure;

    procedure Next_Step(file input_file : TEXT; L: inout LINE; PENDING_FIFO_OP : out FIFO_OP; write_number : out integer) is
        variable first_char : character;
    begin
		write_number := 0;
		readline(input_file, L);
        read(L, first_char);
		if (first_char = '-') then
			PENDING_FIFO_OP := READ_FIFO;
		elsif (first_char = 'R') then
			PENDING_FIFO_OP := RESET_FIFO;
		else
			PENDING_FIFO_OP := WRITE_FIFO;
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

entity fifo_random_tb is
--  Port ( );
end fifo_random_tb;

architecture Behavioral of fifo_random_tb is
    file input_file : TEXT open READ_MODE is "../../../../sim/input_data.txt";
	file input_file_writes_only : TEXT open READ_MODE is "../../../../sim/input_data_writes_only.txt";
    constant CLK_PERIOD : time := 20 ns;
    --------------generics----
    constant WIDTH_TB : integer := 24;
    constant DEPTH_TB : integer := 16;
    constant ALMOST_EMPTY_THRESHOLD_TB : integer := 3;
    constant ALMOST_FULL_THRESHOLD_TB : integer := 9;
    constant READ_LATENCY_TB : integer := 4;
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
	signal pending_fifo_op_sig    : FIFO_OP;
	signal write_num_sig          : integer := 0;
	signal next_read_num_sig      : integer := 0;
	signal data_in_fifo_prev_sig  : integer := 0;
	signal data_in_fifo_prev2_sig : integer := 0;
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
	variable L_writes_only      : line;
	variable pending_fifo_op    : FIFO_OP;
	variable write_num          : integer := 0;
	variable next_read_num      : integer := 0;
	variable data_in_fifo_prev  : integer :=  0;
	variable data_in_fifo_prev2 : integer :=  0; --expectation is fifo data_count signal is behind by two clock cycles. one clock cycle to update data_count, another clock cycle for others to read the change
    begin
		while not endfile(input_file) loop
			--assumption is an operation is performed every iteration
            wait until rising_edge(CLK_TB);
			if (data_in_fifo_prev2 /= DATA_COUNT_TB) 
			then
				report "TEST FAILED: DATA_COUNT not accurate";
				report "data_in_fifo = " & to_string(data_in_fifo_prev2) & ", DATA_COUNT = " & to_string(DATA_COUNT_TB);
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
    		
			Next_Step(input_file, L, pending_fifo_op, write_num);
			
			if (read_latency_valid_counter(READ_LATENCY_TB) = '1' and (VALID_TB /= '1' or DATA_OUT_TB /= std_logic_vector(to_unsigned(next_read_num, WIDTH_TB)))) then
				report "TEST FAILED";
				if (VALID_TB /= '1') then
					report "VALID_TB should equal '1' for valid read operations";
				else
					report "DATA_OUT_TB = " & to_string(TO_INTEGER(unsigned(DATA_OUT_TB))) & " when it should = " & to_string(next_read_num);
				end if;
				wait for CLK_PERIOD/4;
				finish;
			end if;

			if (read_latency_valid_counter(READ_LATENCY_TB-1) = '1') then
                if (not endfile(input_file_writes_only)) then
                    Next_Step_Writes_Only(input_file_writes_only, L_writes_only, next_read_num);
                else
                    report "TEST FAILED: reads go through when they shouldn't";
                    wait for CLK_PERIOD/4;
                    finish;
                end if;
			end if;
			
			read_latency_valid_counter(READ_LATENCY_TB downto 1) <= read_latency_valid_counter(READ_LATENCY_TB-1 downto 0);
            read_latency_valid_counter(0) <= '0';
			data_in_fifo_prev2 := data_in_fifo_prev;
			if (pending_fifo_op = READ_FIFO) then
				--read
				READ_ENABLE_TB  <= '1';
				WRITE_ENABLE_TB <= '0';
				SRST_TB <= '0';
				if (data_in_fifo_prev /= 0) then
					data_in_fifo_prev := data_in_fifo_prev - 1;
					read_latency_valid_counter(0) <= '1';
				else
					read_latency_valid_counter(0) <= '0';
				end if;
			elsif (pending_fifo_op = WRITE_FIFO) then
				--write
				READ_ENABLE_TB  <= '0';
				WRITE_ENABLE_TB <= '1';
				SRST_TB <= '0';
				if (data_in_fifo_prev /= DEPTH_TB) then
					data_in_fifo_prev := data_in_fifo_prev + 1;
					DATA_IN_TB <= std_logic_vector(to_unsigned(write_num, WIDTH_TB));
				end if;
			else
				--reset
				SRST_TB <= '1';
				data_in_fifo_prev := 0;
				read_latency_valid_counter <= (others => '0');
			end if;
            pending_fifo_op_sig    <= pending_fifo_op;
	        write_num_sig          <= write_num;
	        next_read_num_sig      <= next_read_num;
	        data_in_fifo_prev_sig  <= data_in_fifo_prev;
			data_in_fifo_prev2_sig <= data_in_fifo_prev2;
		end loop;

		report "RNG TEST PASSED";
        wait for CLK_PERIOD/4;
		finish;
    
	end process;


end Behavioral;