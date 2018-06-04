----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2018 01:45:08 PM
-- Design Name: 
-- Module Name: Actrl - Behavioral
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

entity Actrl is
  Port (
    i_reg : in std_logic_vector(31 downto 0);
    state: in std_logic_vector(3 downto 0);
    op_code: out std_logic_vector(3 downto 0)
    );
end Actrl;

architecture BehavioralActrl of Actrl is

begin

op_code <= "0100" when (state = "0000") or (state = "1101") or (state = "1000" and i_reg(23) = '1') else
        "0010" when (state = "1000" and i_reg(23) = '0') else
        "0110" when (state = "1000" and i_reg(23) = '1') else
        i_reg (24 downto 21) when ((state  = "0101") and ((i_reg(25) /= '0') or (i_reg(7 downto 4) /= "1001"))) else
        "1101" when ((state  = "0101") and ((i_reg(25) = '0') and (i_reg(7 downto 4) = "1001")) and i_reg(21) = '0') else
        "0100" when ((state  = "0101") and ((i_reg(25) = '0') and (i_reg(7 downto 4) = "1001")) and i_reg(21) = '1');
end BehavioralActrl;
