library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.ALL;

entity MainCtrl is
    Port ( 
     clk, reset, p : IN STD_LOGIC:='0';
     PW : out STD_LOGIC:='0';
     IorD : out STD_LOGIC:='0';
     MR : out STD_LOGIC:='0';
     MW : out STD_LOGIC:='0';
     IW : out STD_LOGIC:='0';
     DW : out STD_LOGIC:='0';
     M2R : out STD_LOGIC_VECTOR (1 DOWNTO 0):="00";
     Rsrc : out STD_LOGIC:='0';
     RW, Mult_wad, Asrc1 : out STD_LOGIC:='0';
     AW : out STD_LOGIC:='0';
     BW : out STD_LOGIC:='0';
     XW,MW_mult,SCW,Mult_true : out STD_LOGIC:='0';
     immediate_true : out STD_LOGIC:='0';	
     type_of_dt_ins: out STD_LOGIC_VECTOR(2 DOWNTO 0);
     Asrc2, byte_offset : out STD_LOGIC_VECTOR(1 DOWNTO 0):="00";
     SW : out STD_LOGIC:='0';
     --opc : out STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
     Fset_mult, Fset : out STD_LOGIC:='0';
     ReW : out STD_LOGIC:='0';
     state_out : out STD_LOGIC_VECTOR(3 DOWNTO 0);
     i_reg : in STD_LOGIC_VECTOR(31 downto 0);
     res_reg_LAST_TWO: IN STD_LOGIC_Vector(1 DOWNTO 0)
     );
end MainCtrl;

architecture BehavioralMainCtrl of MainCtrl is
signal state, prev_state: std_logic_vector (3 downto 0);
signal check_1, check_2, check_3, check_4, check_5, check_6, check_7, check_8, check_9, check_10 : std_logic;
signal transition_bits: std_logic_vector(8 downto 0);
signal zero: std_logic_vector(31 downto 0);
begin

zero <= "00000000000000000000000000000000";

state_out <= state;

transition_bits <= i_reg (27 downto 24) & i_reg(20) & i_reg(7 downto 4);

check_1 <= '1' when (transition_bits(0) = '1' and transition_bits(3) = '0' and transition_bits(8 downto 6)="000") else '0';
check_2 <= '1' when (transition_bits(0) = '0' and transition_bits(8 downto 6)="000") else '0';
check_3 <= '1' when transition_bits(8 downto 6)="001" else '0';
check_4 <= '1' when (transition_bits(3 downto 0) = "1001" and transition_bits(8 downto 6)="000") else '0';
check_5 <= '1' when (transition_bits(0) = '1' and transition_bits(4 downto 3) = "01" and transition_bits(8 downto 6)="000") else '0';
check_6 <= '1' when (transition_bits(0) = '1' and transition_bits(4 downto 3) = "11" and transition_bits(8 downto 6)="000") else '0';
check_7 <= '1' when (transition_bits(4) = '0'and transition_bits(8 downto 7)="01") else '0';
check_8 <= '1' when (transition_bits(4) = '1'and transition_bits(8 downto 7)="01") else '0';
check_9 <= '1' when (transition_bits(5) = '0'and transition_bits(8 downto 7)="10") else '0';
check_10 <= '1' when (transition_bits(5) = '1'and transition_bits(8 downto 7)="10") else '0';

process(state)
begin
    case state is
        when "0000" => PW <= '1';
        when "1101" => PW <= p;
        when others => PW <= '0';
    end case;
end process;

--with state select
--PW <= '1' when "0000",-- else
--       p  when "1101",-- else
--      '0' when others;
       
IorD <= '1' when (state = "1001") or (state = "1010") else
        '0';
        
MR <= '1' when (state = "1001") or (state = "1010") or (state = "0000" ) else -- or (state = "1111" ) else
      '0';       
       
MW <= p when state = "1001"  else
      '0';  
                       
IW <= '1' when state = "0000" else
      '0';       
       
       
DW <= '1' when state = "1010" else --or (state = "1110" and prev_state = "1010") else
              '0';

M2R <= "01" when state = "1011" else
       "10" when state = "1100" else    
       "00" ;
       
Rsrc <= '1' when state = "1000" else
         '0'; 

Mult_wad <= '0' when (state = "0110") or (state = "1011")  else
            '1'; 

process(clk)
begin
    case state is
        when "0110" => if i_reg(24 downto 23) /= "10" then RW <= p; end if;
        when "1011" => RW <= p;
        when "1100" => RW <= p;
        when others => RW <= '0';
    end case;
end process;
--RW <= p when (state = "0110" and i_reg(24 downto 23) /= "10")or (state = "1011") or (state = "1100") else
--         '0'; 
        
AW <= '1' when state = "0001" or state = "0100" else
         '0';        
                             
BW<= '1' when state = "0001" or state = "1000" else
         '0';
                                     
XW <= '1' when state = "0010" else
         '0'; 

MW_mult <= '1' when state = "0100" else
           '0';          
         
SCW <= '1' when state = "0011" else
          '0'; 
                  
SW <= '1' when (state = "0011") or (state = "0111" )else
        '0'; 
        
Mult_true <= '1' when state = "0010" else
                '0'; 

immediate_true <= i_reg(25) when state = "0011" else
                '0'; 
 
type_of_dt_ins <=   "000" when (i_reg(27 downto 26) = "01" ) and i_reg(20) = '1'  else
                    "001" when (i_reg(27 downto 26) = "00" ) and i_reg(20) = '1'  and  i_reg(7 downto 4) = "1001"  else
                    "010" when (i_reg(27 downto 26) = "00" ) and i_reg(20) = '1'  and i_reg(7 downto 4) = "1011"  else
                    "011" when (i_reg(27 downto 26) = "00" ) and i_reg(20) = '1'  and  i_reg(7 downto 4) = "1101"  else
                    "100" when (i_reg(27 downto 26) = "00" ) and i_reg(20) = '1'  and i_reg(7 downto 4) = "1111"  else
                    "101" when (i_reg(27 downto 26) = "01" ) and i_reg(20) = '0'  else
                    "110" when (i_reg(27 downto 26) = "00" ) and i_reg(20) = '0'  and  i_reg(7 downto 4) = "1001"  else
                    "111" when (i_reg(27 downto 26) = "00" ) and i_reg(20) = '0'  and i_reg(7 downto 4) = "1011" ;
                                   
-- ldr 000 -- ldrb 001 -- ldrh 010 -- ldrsb 011 -- ldrsh 100 -- str 101 -- strb 110 -- strh 111
 
                
Asrc1 <= '1' when (state = "0101") or (state = "1000") else
                '0'; 
                
Asrc2 <= "01" when state = "0000" else
          "00" when prev_state = "0011" or state = "1000" else
          "10" when prev_state = "0100" else 
          "11";              

byte_offset <= res_reg_LAST_TWO when state = "1001" else
               "00" ; 

--opc <= "0100" when state = ("0000" or "1101") or (state = "1000" and i_reg(23) = '1') else
--        "0010" when (state = "1000" and i_reg(23) = '0') else
--        "0110" when (state = "1000" and i_reg(23) = '1') else
--        i_reg (24 downto 21) when (state  = "0101") ;
        
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
               
Fset_mult <= p when state = "0100" else 
            '0';               

Fset <= p when state = "0101" and (i_reg(24 downto 23) = "10" or i_reg(20) = '1')  else 
            '0';    
            
ReW <= '1' when (state = "0101")  or (state = "1000") else 
                        '0';                
            
process(clk)
begin
    if(reset = '1') then
            prev_state <= "0000";
    elsif rising_edge(clk) then-- and reset /= '1' then 
        prev_state <= state;
    end if;
end process;    
            
process(clk)
begin

    if(reset = '1') then
            state <= "0000";
    elsif rising_edge(clk) then-- and reset /= '1' then 
        case state is
--            when "1111" =>
--                if i_reg /= zero or i_reg /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" then
--                state <= "0000";
--                end if;
            when "0000" =>
                state <= "0001";
             when "0001" =>
                if (check_1 or check_2 or check_3 or check_4)= '1' then 
                    state<="0010";
                elsif (check_5 or check_6 or check_7 or check_8 )= '1' then 
                    state <= "0111";
                elsif check_9 = '1' then 
                    state <= "1101";
                else state <= "1100";
                 end if;
            when "0010" =>
                 if (check_1 or check_2 or check_3 )= '1' then 
                     state<="0011";
                  else state <= "0100";
                  end if;     
            when "0011" =>
                  state<= "0101";
             when "0100" =>
                  state <= "0101";
             when "0101" =>
                  state <= "0110";
             when "0110" =>
                  state <= "0000";
             when "0111" =>
                    state <= "1000";
              when "1000" =>
                   if (check_5 or check_7)= '1' then 
                       state<="1001";
                    else state <= "1010";
                    end if;
               when "1001" =>
                   state <= "0000";
                when "1010" =>
                      state <= "1011";
                when "1011"   =>
                        state <= "0000";
                 when "1100" =>
                        state <= "1101";
--                 when "1110" =>
--                        if( check_6 or check_8 )='1' then 
--                        state <= "1011";
--                         end if;
                when others => --1101
                        state <= "0000";
                                  
               end case;
      end if;     

--    if reset = '1' then
--        state<= "0000";
--        prev_state<= "0000";
--    end if;
    
--    if falling_edge(reset) then
--        state <= "0000";
--        prev_state<= "0000";
--    end if;

end process;
end BehavioralMainCtrl;
