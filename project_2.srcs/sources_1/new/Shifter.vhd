library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Shifter is
    Port (
        op1 : in std_logic_vector(31 downto 0); --The 32 bit operand to be shifted
        shift_amount : in std_logic_vector(4 downto 0); 
        --Maximum 5 bits of shifting alowed (0-32 spaces of shift), IN CASE OF REGISTERS WITH GREATER THAN 32 AS VALUE: Conactenate/ 32
        shift_type : in std_logic_vector(1 downto 0); 
        -- 00 LSL -- 01 LSR -- 10 ASR -- 11 ROR
        carry_in: in std_logic;
        output : out std_logic_vector(31 downto 0);
        shifter_carry : out std_logic
        );
end Shifter;

architecture BehaviouralShifter of Shifter is
signal shift_int : integer; --integer of shift_amount
signal zero, one : std_logic_vector(31 downto 0);
signal pos1, pos2, pos: std_logic_vector(31 downto 0); 

begin

zero <= "00000000000000000000000000000000";
one <= not zero;

shift_int <= to_integer(unsigned(shift_amount)); 



output <=   to_stdlogicvector(to_bitvector(op1) sll shift_int) when shift_type =  "00" else -- LSL
            to_stdlogicvector(to_bitvector(op1) srl shift_int) when shift_type=  "01" else --LSR
            to_stdlogicvector(to_bitvector(op1) sra shift_int) when shift_type = "10" else --ASR
            to_stdlogicvector(to_bitvector(op1) ror shift_int) when shift_type = "11"; --ROR

shifter_carry<= carry_in when shift_int = 0 else
                op1(31 - shift_int + 1) when shift_type = "00" else
                op1(shift_int - 1) when shift_int > 0;
    
end architecture BehaviouralShifter;