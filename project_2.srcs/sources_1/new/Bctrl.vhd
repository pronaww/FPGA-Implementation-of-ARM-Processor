----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2018 01:47:50 PM
-- Design Name: 
-- Module Name: Bctrl - Behavioral
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

entity Bctrl is
  Port ( 
    ins, flags_set: in std_logic_vector(3 downto 0);
    p: out std_logic
    );
end Bctrl;

architecture BehavioralBctrl of Bctrl is
signal Z, C, N, V: std_logic;
begin
N<= flags_set(3);
Z<= flags_set(2);
C<= flags_set(1);
V<= flags_set(0);

with ins select p<=
    Z when "0000",
    not Z when "0001",
    C when "0010",
    not C when "0011",
    N when "0100",
    not N when "0101",
    V when "0110",
    not V when "0111",
    C and(not Z) when "1000",
    not (C and(not Z)) when "1001",
    n XNOR v when "1010",
    not (n XNOR v) when "1011",
    (n XNOR v) AND (not Z) when "1100",
    not ((n XNOR v) AND (not Z)) when "1101",
    '1' when "1110",
    '0' when others;
    

end BehavioralBctrl;
