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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo_tb is
--  Port ( );
end fifo_tb;

architecture Behavioral of fifo_tb is
    constant CLK_PERIOD : time := 20 ns;
    --------------generics----
    constant WIDTH_TB : integer := 0; --don't forget to assign real values
    constant DEPTH_TB : integer := 0; --don't forget to assign real values
    constant ALMOST_EMPTY_THRESHOLD_TB : integer := 0; --don't forget to assign real values
    constant ALMOST_FULL_THRESHOLD_TB : integer := 0; --don't forget to assign real values
    constant READ_LATENCY_TB : integer := 0; --don't forget to assign real values 
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
    ----------------------
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




end Behavioral;
