library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.ALL;
    -- 0000 = AND
    -- 0001 = EOR
    -- 0010 = SUB
    -- 0011 = RSB
    -- 0100 = ADD
    -- 0101 = ADC
    -- 0110 = SBC
    -- 0111 = RSC
    -- 1000 = TST
    -- 1001 = TEQ
    -- 1010 = CMP
    -- 1011 = CMN
    -- 1100 = ORR
    -- 1101 = MOV
    -- 1110 = BIC
    -- 1111 = MVN

entity ALU is
 Port (
   op1, op2 : in std_logic_vector(31 downto 0);
   carry_in : in std_logic;
   optype : in std_logic_vector(3 downto 0);   
   --NZCV
   flags : out std_logic_vector(3 downto 0);
   output : out std_logic_vector(31 downto 0)
   );
end ALU;

architecture BehaviouralOfALU of ALU is
signal zero : std_logic_vector(31 downto 0);
signal output_signal : std_logic_vector(31 downto 0);
signal c_32, c_32_add, c_31, c_32_sub, c_32_rsb : std_logic; --For flag setting : carry 31 and 32
begin

zero <= "00000000000000000000000000000000";

with optype select
           output_signal <= op1 and op2 when "0000", -- 0000 = AND
                     op1 xor op2 when "0001",     -- 0001 = EOR
                     op1 - op2 when "0010",      -- 0010 = SUB
                     op2 - op1 when "0011",    -- 0011 = RSB
                     op1 + op2 when "0100",    -- 0100 = ADD
                     op1 + op2 + carry_in when "0101",    -- 0101 = ADC
                     op1 - op2 + carry_in - 1 when "0110" ,    -- 0110 = SBC
                     op2 - op1 + carry_in - 1  when "0111",    -- 0111 = RSC
                     op1 and op2 when "1000",    -- 1000 = TST
                     op1 xor op2 when "1001" ,    -- 1001 = TEQ
                     op1 - op2 when "1010",    -- 1010 = CMP
                     op1 + op2 when "1011",    -- 1011 = CMN
                     op1 or op2 when "1100",    -- 1100 = ORR
                     op2 when "1101",    -- 1101 = MOV
                     op1 and not op2 when "1110",    -- 1110 = BIC
                     not op2 when others;    -- 1111 = MVN
             
c_31 <= op1(31) xor op2(31) xor output_signal(31);
c_32_add <= (op1(31) and op2(31)) or (op2(31) and c_31) or (op1(31) and c_31);
c_32_sub <= (not op1(31) and op2(31)) or (op2(31) and c_31) or (not op1(31) and c_31);
c_32_rsb <= (not op2(31) and op1(31)) or (op1(31) and c_31) or (not op2(31) and c_31);


c_32 <= c_32_add when (optype = "0101" or optype = "1011" or optype = "0100") else
        not c_32_sub when (optype = "0010" or optype = "0110" or optype = "1010") else
        not c_32_rsb when (optype = "0011" or optype = "0111") else
        '0';--carry_in;

flags(3) <=  output_signal(31);
flags(2) <= '1' when output_signal = zero else '0';
flags(1) <= c_32;
flags(0) <= (c_31 XOR c_32_add) WHEN ((optype = "0100" OR optype = "0101" OR optype = "1011")) ELSE
            (c_31 XOR c_32_sub) WHEN ((optype = "0010" OR optype = "0110" OR optype = "1010")) ELSE
            (c_31 XOR c_32_rsb) WHEN ((optype = "0011" OR optype = "0111"));                

--Flags:NZCV
output <= output_signal(31 downto 0);

end BehaviouralOfALU;