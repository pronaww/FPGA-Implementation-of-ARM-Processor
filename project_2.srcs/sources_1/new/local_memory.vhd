library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_signed.ALL;
use std.textio.all;

entity local_memory is
 port (
           addra : in STD_LOGIC_VECTOR ( 31 downto 0 ); -- Address to be read from/ to be written at
           clk : in STD_LOGIC; --clock for memory -- writing is clock based
           dina : in STD_LOGIC_VECTOR ( 31 downto 0 ); -- write data
           douta : out STD_LOGIC_VECTOR ( 31 downto 0 ); -- read data
           ena : in STD_LOGIC; -- MR
           reset : in STD_LOGIC; -- reset
           wea : in STD_LOGIC_VECTOR ( 3 downto 0 ); -- write enable for 4 of the bytes right to left
           addr : in STD_LOGIC_VECTOR ( 9 downto 0 );
           memout : out STD_LOGIC_VECTOR ( 31 downto 0 )
         );
end local_memory;

architecture Behavioral of local_memory is

--signal zero : std_logic_vector(31 downto 0);
--type arr_mem is array (1500 downto 0) of std_logic_vector(31 downto 0); --15 registers with 32 bit space each
--signal memory_file : arr_mem;


type RamType is array (0 to 2048) of bit_vector(31 downto 0);

	impure function InitRamFromFile(RamFileName : in string) return RamType is
		FILE RamFile : text is in RamFileName;
		variable RamFileLine : line;
		variable RAM : RamType;
	begin
	
	for I in RamType'range loop
		readline(RamFile, RamFileLine);
		read(RamFileLine, RAM(I));
	end loop;
	
	return RAM;
	
	end function;

signal RAM : RamType := InitRamFromFile("rams_init_file.data");

begin

--zero <= "00000000000000000000000000000000";

--douta <= to_stdlogicvector(memory_file(to_integer(unsigned(addra)))) when ena = '1'; --reading from reg file
douta <= to_stdlogicvector(RAM(to_integer(unsigned("00" & addra (31 downto 2))))) when ena = '1'; --reading from reg file

--process (reset, clk)
--begin
--    if 
--end process;

memout <= to_stdlogicvector(RAM(to_integer(unsigned("00" & addr (9 downto 0)))));

process (clk)
begin
        
    if rising_edge(clk) and clk = '1' and ena = '1' and reset /= '1'  then
        if wea(0) = '1' then
            RAM(to_integer(unsigned("00" & addra (31 downto 2))))(7 downto 0) <= to_bitvector(dina(7 downto 0)); --reading from reg file
        end if;
        if wea(1) = '1' then
            RAM(to_integer(unsigned("00" & addra (31 downto 2))))(15 downto 8) <= to_bitvector(dina(15 downto 8)); --reading from reg file
        end if;
        if wea(2) = '1' then
            RAM(to_integer(unsigned("00" & addra (31 downto 2))))(23 downto 16) <= to_bitvector(dina(23 downto 16)); --reading from reg file
        end if;
        if wea(3) = '1' then
            RAM(to_integer(unsigned("00" & addra (31 downto 2))))(31 downto 24) <= to_bitvector(dina(31 downto 24)); --reading from reg file
        end if;   
    end if;
end process;
end Behavioral;
