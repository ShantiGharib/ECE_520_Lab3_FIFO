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
	function String_TO_INT(num_string : string) return integer;

end package;

package body input_file_parse is
	function String_TO_INT(num_string : string) return integer is
		variable res : integer := 0;
		variable curr_digit : character;
	begin
		for i in 0 to num_string'length-1 loop
			res := res * 10;
			curr_digit := num_string(i);
			case curr_digit is
				when "1" => res := res + 1;
				when "2" => res := res + 2;
				when "3" => res := res + 3;
				when "4" => res := res + 4;
				when "5" => res := res + 5;
				when "6" => res := res + 6;
				when "7" => res := res + 7;
				when "8" => res := res + 8;
				when "9" => res := res + 9;
				when others => res := res;
			end case;
		end loop;
		return res;
	end function;

	procedure Next_Step_Writes_Only(file input_file : TEXT; L: inout LINE; write_number : out integer) is
	begin
		readline(input_file, L);
		read(L, write_number);
	end procedure;

    procedure Next_Step(file input_file : TEXT; L: inout LINE; IS_FIFO_READ_OP : out boolean; write_number : out integer) is
        variable read_string_var : string;
    begin
		write_number := 0;
        
		readline(input_file, L);
        read(L, read_string_var);
		if (read_string_var = "-") then
			IS_FIFO_READ_OP := true;
		else
			IS_FIFO_READ_OP := false;
			write_number := String_TO_INT(read_string_var);
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
    constant WIDTH_TB : integer := 32;
    constant DEPTH_TB : integer := 2**6;
    constant ALMOST_EMPTY_THRESHOLD_TB : integer := 6b"011001";
    constant ALMOST_FULL_THRESHOLD_TB : integer  := 6b"110110";
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
	signal read_latency_counter : std_logic_vector(READ_LATENCY_TB-1 downto 0) := (others => '0');
	signal read_latency_valid_counter : std_logic_vector(READ_LATENCY_TB-1 downto 0) := (others => '0');
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
	variable write_num : integer;
	variable next_read_num : integer;
	variable FIFO_JUST_MADE_FULL : boolean := false;
	variable data_available : integer := 0;
    begin
		while not endfile(input_file) loop
			if ((READ_ENABLE_TB = '1' and (data_available > DATA_COUNT_TB or (read_latency_valid_counter(0) = '1' and data_available = DATA_COUNT_TB)))
			or (WRITE_ENABLE_TB = '1' and (data_available < DATA_COUNT_TB or (FIFO_JUST_MADE_FULL /= '1' and data_available = DEPTH_TB and data_available = DATA_COUNT_TB))))
			then
				report "TEST FAILED: DATA_COUNT not accurate";
				finish;
			elsif (DATA_COUNT_TB = 0 and EMPTY_TB /= '1')
			then
				report "TEST FAILED: EMPTY Flag not working";
				finish;
			elsif (DATA_COUNT_TB = DEPTH_TB and FULL_TB /= '1')
			then
				report "TEST FAILED: FULL Flag not working";
				finish;
			elsif (DATA_COUNT_TB <= ALMOST_EMPTY_THRESHOLD_TB and ALMOST_EMPTY_TB /= '1')
			then
				report "TEST FAILED: ALMOST_EMPTY Flag not working";
				finish;
			elsif (DATA_COUNT_TB >= ALMOST_FULL_THRESHOLD_TB and ALMOST_FULL_TB /= '1') then
				report "TEST FAILED: ALMOST_FULL Flag not working";
				finish;
			end if;
    		
			Next_Step(input_file, L, do_fifo_read, write_num);
			
			read_latency_counter <= (read_latency_counter(READ_LATENCY_TB - 2 downto 0), READ_ENABLE_TB);
			read_latency_valid_counter(READ_LATENCY_TB-1 downto 1) <= read_latency_valid_counter(READ_LATENCY_TB-2 downto 0);
			
			if (read_latency_counter(READ_LATENCY_TB-1) = '1') then
				if (not endfile(input_file_writes_only))
				then
					Next_Step_Writes_Only(input_file_writes_only, L_writes_only, next_read_num);
				else
					report "Catastrophic file reading error has occurred. TEST SIGNIFICANTLY FAILED";
					finish;
				end if;
				if (read_latency_valid_counter(READ_LATENCY_TB-1) = '1' and (VALID_TB /= '1' or DATA_OUT_TB /= std_logic_vector(to_unsigned(next_read_num, WIDTH_TB-1 downto 0)))) then
					report "TEST FAILED: Either the FIFO storage, the Read_Latency pipeline, or both err";
					finish;
				end if;
			end if;
			
			FIFO_JUST_MADE_FULL := false;
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
					DATA_IN_TB <= std_logic_vector(to_unsigned(write_num, WIDTH_TB-1 downto 0));
				end if;
			end if;
		end loop;

		report "RNG TEST PASSED";
		finish;
    
	end process;


end Behavioral;
