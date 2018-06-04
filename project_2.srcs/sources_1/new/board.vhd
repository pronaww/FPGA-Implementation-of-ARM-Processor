----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.04.2018 09:25:23
-- Design Name: 
-- Module Name: board - Behavioral
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.ALL;

entity clk10Hz is
    port( clk : in std_logic;
          reset : in std_logic;
          clk_out : out std_logic
          --timed : out integer range 0 to 500
        );
end clk10Hz;

architecture counter of clk10Hz is
    signal temp: std_logic;
    signal c: std_logic_vector(26 downto 0) := "000000000000000000000000000";
    signal counter: integer range 0 to 500000; --49999999
    --signal timer: integer range 0 to 500 := 0;
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
--            if reset = '1' then c <= "000000000000000000000000000";
--            else c <= c + 1;
            c <= c+1;
--            end if;
        end if;
    end process;
    
--timed <= timer;
clk_out <= c(26);
end counter;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity board is
  Port (
        clk,reset : in std_logic;
        memOrReg : in std_logic;
        read_switches : in std_logic_vector(9 downto 0);
        leds : out std_logic_vector(15 downto 0);
        cathode : out std_logic_vector(6 downto 0);
        anode : out std_logic_vector(3 downto 0);
        firstOrLast : in std_logic
        );
end board;

architecture Behavioral of board is
SIGNAL clk_slow : STD_LOGIC;
signal leds_32 : std_logic_vector(31 downto 0);
signal addr : std_logic_vector(9 downto 0);
signal state : std_logic_vector(3 downto 0);
begin
timer: entity work.clk10hz(counter)
       port map(clk, reset, clk_slow);

addr <= read_switches;
with firstOrLast select
leds <= leds_32(31 downto 16) when '1',
        leds_32(15 downto 0) when others;
        
processor: entity work.master(Behavioral)
    Port map(CLK_slow, reset, memOrReg, addr, leds_32, state);


anode <= "1110";

process(clk_slow)
begin
    if clk_slow = '1' and clk_slow'event then
    case state is
    when "0000" => cathode <= "0000001"; -- "0"     
    when "0001" => cathode <= "1001111"; -- "1" 
    when "0010" => cathode <= "0010010"; -- "2" 
    when "0011" => cathode <= "0000110"; -- "3" 
    when "0100" => cathode <= "1001100"; -- "4" 
    when "0101" => cathode <= "0100100"; -- "5" 
    when "0110" => cathode <= "0100000"; -- "6" 
    when "0111" => cathode <= "0001111"; -- "7" 
    when "1000" => cathode <= "0000000"; -- "8"     
    when "1001" => cathode <= "0000100"; -- "9" 
    when "1010" => cathode <= "0000010"; -- a
    when "1011" => cathode <= "1100000"; -- b
    when "1100" => cathode <= "0110001"; -- C
    when "1101" => cathode <= "1000010"; -- d
    when "1110" => cathode <= "0110000"; -- E
    when others => cathode <= "0111000"; -- F
    end case;
    end if;
end process;


end Behavioral;
