library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplier is
  Port (
    op1, op2 : in std_logic_vector(31 downto 0);
    --op1 is Rm (3-0), op2 is Rs (11-8)
    output : out std_logic_vector(31 downto 0);
    --output is Rd(19-16)
    flags : out std_logic_vector(3 downto 2)
    --flags are common between ALU and mult
    );
end Multiplier;

architecture BehaviouralMultiplier of Multiplier is
signal output_big : std_logic_vector(63 downto 0); -- Since overflow may happen, first a 64 bit output is calculated
signal zero : std_logic_vector(31 downto 0);
signal c_32, c_31 : std_logic; -- carry of last bit and 32nd bit

begin

    output_big <= std_logic_vector(signed(op1) * signed(op2));
    output <= output_big(31 downto 0);

zero <= "00000000000000000000000000000000";
             
c_31 <= op1(31) xor op2(31) xor output_big(31);
c_32 <= (op1(31) and op2(31)) or (op2(31) and c_31) or (op1(31) and c_31);

flags(3) <=  output_big(31);
flags(2) <= '1' when output_big = zero & zero else '0';
--flags(1) <= c_32;
--flags(0) <= c_31 xor c_32;
--flags order is NZCV
end architecture BehaviouralMultiplier;