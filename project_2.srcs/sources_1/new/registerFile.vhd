library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_signed.ALL;

entity Register_File is
  Port (
    clk, reset, wr_enable : in std_logic;
    --clk is used for synchronous write, reset initiates all registers to 0, wr_enable is RW
    data, pc : in std_logic_vector(31 downto 0);
    --data is wite_data, pc is a copy of r15. r15 is updated synchronously with pc at each clock cycle
    rd1, rd2, wr : in std_logic_vector(3 downto 0);
    --registers for 2 read ports and 1 write port
    ot1, ot2 : out std_logic_vector(31 downto 0);
    --data after reading from rd1, rd2
    addr : in std_logic_vector(3 downto 0);
    regread : out std_logic_vector(31 downto 0)
    );
end Register_File;

architecture BehaviouralRegister_File of Register_File is
signal zero : std_logic_vector(31 downto 0);
type arr is array (15 downto 0) of std_logic_vector(31 downto 0); --15 registers with 32 bit space each
signal register_array : arr;
begin

zero <= "00000000000000000000000000000000";

regread <= register_array(to_integer(unsigned(addr)));

ot1 <= register_array(to_integer(unsigned(rd1))); --reading from reg file
ot2 <= register_array(to_integer(unsigned(rd2))); --reading from reg file

process(clk, reset)
begin
    if reset = '1' then --initialisation of registers
        for i in 0 to 14 loop
            register_array(i) <= zero;
        end loop;
    elsif rising_edge(clk) then      
--        if wr /= "1111" then
--        end if;
        if wr_enable = '1' and to_integer(unsigned(wr)) /= 15 then
            register_array(to_integer(unsigned(wr))) <= data;
        else
            if wr_enable = '1' then
                register_array(to_integer(unsigned(wr))) <= data;
            else            
                register_array(15) <= pc;
            end if; --pc update synchronous at every clock cycle
        end if; 
    end if;
    
  --  pc_out <= register_array(15);
    
end process;

end architecture BehaviouralRegister_File;