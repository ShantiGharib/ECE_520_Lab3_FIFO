----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/19/2026 09:54:35 AM
-- Design Name: 
-- Module Name: functions - Behavioral
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
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package functions is
    function ceil_log2(number : positive) return integer;
    function max(numberA : positive; numberB : positive) return integer;
end package;

package body functions is
    function ceil_log2(number : positive) return integer is
        variable num : integer := 1;
        variable ans : integer := 0;
    begin
        while (num < number) loop
            num := num * 2;
            ans := ans + 1;
        end loop;
        return ans;
    end function;

    function max(numberA : positive; numberB : positive) return integer is
        variable ans : positive;
    begin
        if (numberA >= numberB) then
            ans := numberA;
        else
            ans := numberB;
        end if;
        return ans;
    end function;
    
end package body;
