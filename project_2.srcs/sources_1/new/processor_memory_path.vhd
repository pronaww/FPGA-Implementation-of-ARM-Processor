library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.ALL;

entity Processor_Memory_Path is
  Port (
    in_proc, in_memory : in std_logic_vector(31 downto 0);
    --in_proc is the input register 'res' that has the final result from processing
    --in_memory is the input that is read from the rd_mem port
    type_of_dt_ins : in std_logic_vector(2 downto 0);
    --Control signal coming from controller, telling the type of DT Instruction
    byte_offset : in std_logic_vector(1 downto 0);
    --Control signal coming from controller, for byte offset while storing 
    out_proc, out_memory: out std_logic_vector(31 downto 0);
    --out_proc is the output that is stored in d_reg after making changes to in_mem
    --out_memory is the output after changing in_proc to be stored in the memory 
    wr_enable : out std_logic_vector (3 downto 0)
    );
end Processor_Memory_Path;

-- ldr 000 -- ldrb 001 -- ldrh 010 -- ldrsb 011 -- ldrsh 100 -- str 101 -- strb 110 -- strh 111

architecture BehaviouralProcessor_Memory_Path of Processor_Memory_Path is
signal zero, one, pos1 : std_logic_vector(31 downto 0);
signal sign_bit : std_logic;
--pos1 is being used for sign extension in case of ldr instruction
begin

zero <= "00000000000000000000000000000000";
one <= not zero;
sign_bit <= in_memory(7) when byte_offset = "00" else
            in_memory(15) when byte_offset = "01" else
            in_memory(23) when byte_offset = "10" else
            in_memory(31) when byte_offset = "11";
                       
pos1 <= one when sign_bit = '1' else zero;

--out_proc <= in_memory;
out_proc <= in_memory when type_of_dt_ins <= "000"  and byte_offset <= "00"  else --ldr 0 offset
            zero(31 downto 8) & in_memory(7 downto 0) when type_of_dt_ins <= "001"  and byte_offset <= "00" else --ldrb0
            zero(31 downto 8) & in_memory(15 downto 8) when type_of_dt_ins <= "001"  and byte_offset <= "01" else --ldrb1
            zero(31 downto 8) & in_memory(23 downto 16) when type_of_dt_ins <= "001"  and byte_offset <= "10" else --ldrb2
            zero(31 downto 8) & in_memory(31 downto 24) when type_of_dt_ins <= "001"  and byte_offset <= "11" else --ldrb3
            zero(31 downto 16) & in_memory(15 downto 0) when  type_of_dt_ins <= "010"  and byte_offset(1) <= '0' else --ldrh0
            zero(31 downto 16) & in_memory(31 downto 16) when  type_of_dt_ins <= "010"  and byte_offset(1) <= '1' else --ldrh1
            pos1(31 downto 8) & in_memory(7 downto 0) when type_of_dt_ins <= "011"  and byte_offset <= "00" else --ldrsb0
            pos1(31 downto 8) & in_memory(15 downto 8) when type_of_dt_ins <= "011"  and byte_offset <= "01" else --ldrsb1
            pos1(31 downto 8) & in_memory(23 downto 16) when type_of_dt_ins <= "011"  and byte_offset <= "10" else --ldrsb2
            pos1(31 downto 8) & in_memory(31 downto 24) when type_of_dt_ins <= "011"  and byte_offset <= "11" else --ldrsb3
            pos1(31 downto 16) & in_memory(15 downto 0) when type_of_dt_ins <= "100"  and byte_offset(1) <= '0'  else --ldrsh0
            pos1(31 downto 16) & in_memory(31 downto 16) when type_of_dt_ins <= "100"  and byte_offset(1) <= '1'  else --ldrsh1
            in_memory(15 downto 0) & in_memory(31 downto 16) ;--when type_of_dt_ins <= "000"  and byte_offset <= "10"; --ldr 2 offset

with type_of_dt_ins select
    out_memory <= in_proc(7 downto 0) & in_proc(7 downto 0) & in_proc(7 downto 0) & in_proc(7 downto 0) when "110",
                  -- strb
                  -- here we copy the last byte into all four byte segments of the word. Later byte offset decides which one is written in the memory.
                  in_proc(15 downto 0) & in_proc(15 downto 0) when "111", --strh
                  in_proc when others; --str

wr_enable <=  	  "0001" when type_of_dt_ins <= "110"  and byte_offset <= "00"  else --strb, 0 offset
                  "0010" when type_of_dt_ins <= "100"  and byte_offset <= "01"  else --strb, 1 offset
                  "0100" when type_of_dt_ins <= "100"  and byte_offset <= "10"  else --strb, 2 offset
                  "1000" when type_of_dt_ins <= "100"  and byte_offset <= "11"  else --strb, 3 offset
                  "0011" when type_of_dt_ins <= "111"  and byte_offset <= "00"  else --strh, 0 offset
                  "1100" when type_of_dt_ins <= "111"  and byte_offset <= "01"  else --strb, 1 offset
                  "1111" when type_of_dt_ins <= "101"  and byte_offset <= "00"  else --str
                  "0000" ; -- dont store anaything

                  
end architecture BehaviouralProcessor_Memory_Path;