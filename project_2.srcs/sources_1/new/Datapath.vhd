library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.ALL;

entity DataPath is
--datamemory
    Port (
    clk, reset, Asrc1 : in std_logic;
    ir_out: out std_logic_vector(31 downto 0);
    PW,IorD, MR, MW, IW, DW, Rsrc, RW, XW, AW, BW, Mult_wad, immediate_true ,SW,MW_mult, SCW, ACW, Mult_true : in std_logic; --SW = Shift Write --MW_mult = Mult Write --SCW = Shift Carry Write, -- ACW = ALU Carry Write --Mult_true for selecting reg A
    Asrc2, byte_offset, M2R : in std_logic_vector(1 downto 0);    
    Fset, Fset_mult : in std_logic;
    optype  : in std_logic_vector(3 downto 0);
    type_of_dt_ins : in std_logic_vector(2 downto 0);
    ReW : in std_logic;
    flags : OUT std_logic_vector(3 downto 0);
    res_reg_LAST_TWO: OUT std_logic_vector(1 downto 0);
    addr : in std_logic_vector(9 downto 0);
    memorreg : in std_logic;
    segread : out std_logic_vector(31 downto 0)
        
    );
end DataPath;

architecture BehaviouralDataPath of DataPath is
signal shift_type : std_logic_vector(1 downto 0);
signal flags_mult : std_logic_vector(3 downto 2);
signal shift_amount: std_logic_vector(4 downto 0);
signal carry_in_ALU, shifter_carry, carry_in_Shift, shift_carry_reg, reset2: std_logic;
signal ir_reg, pc_reg, zero, four, x_reg, a_reg, b_reg, d_reg, d_reg_temp, res, pc, shift_reg, mult_reg, pc_from_regFile: std_logic_vector(31 downto 0);
signal regread,memout, wd, rd1,rd2, ad_mem, wd_mem, rd_mem, op1, op2, output_ALU,op1_MULT, op2_MULT, output_MULT, op1_Shift, output_shift, in_proc, in_memory,  out_proc, out_memory : std_logic_vector(31 downto 0);
signal regaddr, flags_reg_datapath, rad1, rad2, wad, flags_sig, wr_enable, wr_send: std_logic_vector(3 downto 0);
signal extender_s2: std_logic_vector(5 downto 0);
signal N,Z,C,V: std_logic;
begin
res_reg_LAST_TWO <= res(1 downto 0);
wr_send <= (wr_enable and (MW&MW&MW&MW));
FLAGS <= N&Z&C&V;--FLAGS_REG_datapath;
zero <= "00000000000000000000000000000000";
four <= "00000000000000000000000000000100";

--
regaddr <= addr(3 downto 0);
with memorreg select
segread <= regread when '1', --regread
           memout when others;
--
EX: extender_s2 <= zero(31 downto 26) when ir_reg(23) = '0' else 
				not(zero(31 downto 26));

ir_out <= ir_reg;

Register_File_Instantiate: ENTITY WORK.Register_File(BehaviouralRegister_File)
        Port Map (clk, reset, RW, wd, pc, rad1, rad2, wad, rd1, rd2, regaddr, regread);

    rad1 <= ir_reg(19 downto 16) when Mult_true = '0' and MW_mult /='1'else
            ir_reg (15 downto 12) when Mult_true = '0' and MW_mult = '1'else
            ir_reg(11 downto 8);
    
with Rsrc select rad2 <=
                ir_reg(3 downto 0) when '0',
                ir_reg(15 downto 12) when others;
    
    
    
    wad <= ir_reg(19 downto 16) when Mult_wad = '0' and ((ir_reg(25) = '0') and (ir_reg(7 downto 4) = "1001")) else
           ir_reg(15 downto 12) when Mult_wad = '0' else
           "1110";
    
    wd <= res when M2R = "00" else
          d_reg when M2R = "01" else
          PC;



SHIFTER_INS: ENTITY WORK.Shifter(BehaviouralShifter)
		Port Map(op1_Shift, shift_amount, shift_type, carry_in_Shift, output_shift, shifter_carry);
		-- 00 LSL-- 01 LSR-- 10 ASR-- 11 ROR


op1_Shift <=  zero(31 downto 12) & ir_reg(11 downto 0) when ir_reg(27 downto 25) = "010" else
              b_reg when ir_reg(27 downto 25) = "011" else
              b_reg when ir_reg(25) = '0' else
			  zero(31 downto 8) & ir_reg(7 downto 0) when ir_reg(25) = '1';
			  
			  --ensure that ir_reg(3 downto 0) is loaded in rd2

shift_amount <= "00000" when ir_reg(27 downto 25) = "010" else
                ir_reg (11 downto 7) when ir_reg(4) = '0' and ir_reg(27 downto 25) = "011" else
                x_reg(4 downto 0) when ir_reg(4) = '1' and ir_reg(25) = '0' and ir_reg(7) = '0' else
				ir_reg (11 downto 7) when ((ir_reg(4) = '0') and (ir_reg(25) = '0')) else
				ir_reg (11 downto 8) & zero(0) when ir_reg(25) = '1' ;
                
               
shift_type   <= ir_reg(7 downto 6) when ir_reg(25) = '0' else
				"11";

carry_in_Shift <= shift_carry_reg;
                
shift_carry_reg <= shifter_carry when SCW = '1';

ALU_Instantiate: ENTITY WORK.ALU(BehaviouralOfALU)
        Port Map(op1 => op1,
                 op2 => op2,
                 carry_in => carry_in_ALU,
                 optype => optype,
                 flags => flags_sig,
                 output => output_ALU);

carry_in_ALU <= C;--flags_reg_datapath(1);

op1 <= PC when Asrc1 = '0' else
       a_reg when Asrc1 = '1' ;
       
op2 <= shift_reg when Asrc2 = "00" else
       mult_reg when Asrc2 = "10" else
       (extender_s2 & ir_reg(23 downto 0) & "00") + four when Asrc2 = "11" else
       four ;--when Asrc2 = "01";
              
Multiplier_Inst: ENTITY WORK.Multiplier(BehaviouralMultiplier)
		Port Map(op1_MULT, op2_MULT, output_MULT, flags_mult);

op1_MULT <= B_reg;
op2_MULT <= x_reg;


ad_mem <= pc when IorD = '0' else
          res;

-- out_memory is from processor memory path and is to be stored in memory
Processor_Memory_Path_Inst: ENTITY WORK.Processor_Memory_Path(BehaviouralProcessor_Memory_Path)
	Port Map(in_proc, in_memory, type_of_dt_ins, byte_offset, out_proc, out_memory, wr_enable);


--ldr/str dt_ins(3) = '1' for ldr
--"000" == word
--"001" == byte
--"010" == half word
--"011" == signed byte
--"100" == signed hald word

in_proc  <= b_reg;
d_reg_temp <= out_proc; 
--in_memory output of memory
--type of dt ins 
--Memory: ENTITY WORK.memory_in_datapath_wrapper(STRUCTURE)
--        Port Map (ad_mem, clk, wd_mem, rd_mem, MR, reset2, wr_send);
        
Memory: ENTITY WORK.local_memory(Behavioral)
                Port Map (ad_mem, clk, wd_mem, rd_mem, MR, reset2, wr_send, addr, memout);

Process(clk, reset)
begin
if(reset = '1' and reset'event) then
    reset2<= '1';
end if;
if falling_edge(clk) then
    reset2 <= '0';
end if;
end process;

wd_mem <= out_memory;
in_memory <= rd_mem;

--    flags_reg <= flags_sig when  Fset = '1' else
--                 flags_mult(3 downto 2) & flags_reg(1 downto 0) when Fset_mult = '1';
                 
ir_reg <= rd_mem when IW = '1' else ir_reg;

--process(clk)
--begin
--    if rising_edge(clk) then
--        pc <= pc_reg;
--    end if;
--end process;

--NZCV    
--flags_reg_datapath <= "0000" when reset = '1' else
--             flags_sig when Fset = '1' else
--             flags_mult(3 downto 2) & flags_reg_datapath(1 downto 0) when Fset_mult = '1' else
--             flags_reg_datapath;


N <= '0' when reset = '1' else
                          flags_sig(3) when Fset = '1' else
                          flags_mult(3) when Fset_mult = '1' else
                          N;

Z <= '0' when reset = '1' else
             flags_sig(2) when Fset = '1' else
             flags_mult(2) when Fset_mult = '1' else
             Z;

C <= '0' when reset = '1' else
             flags_sig(1) when Fset = '1' else
             C;

V <= '0';-- when reset = '1' else
         --    flags_sig(0) when Fset = '1' else
         --    V;

process(clk)
begin
    if reset = '1' then
        pc <= zero;
    elsif rising_edge(clk) then
        if PW = '1' and reset /= '1' then --and wr_send/= "1111" then
            pc <= output_ALU;  
        --elsif wr_send = "1111" and RW = '1' then 
        --    pc <= pc_from_regFile;
        elsif RW = '1' and wad = "1111" then
            pc <= res;
        end if;
    end if;
end process;    
    
    --if IW = '1' then
    --    ir_reg <= rd_mem;
    --end if;
    
    
    

a_reg <= zero when reset = '1' else
         zero when (ir_reg(27 downto 23) = "00000" and ir_reg(21) = '0' and ir_reg(7 downto 4) = "1001") and AW = '1' else
         rd1 when (ir_reg(27 downto 23) /= "00000" or ir_reg(21) /= '0' or ir_reg(7 downto 4) /= "1001") and AW = '1' else
         a_reg;

--        pc_reg <= zero when reset = '1'
--            else output_alu when PW = '1' 
--            else  res when RW = '1' and wad = "1111"
--            else pc_reg;

RES <= zero when reset = '1' else
       output_ALU when ReW = '1' else RES;    

d_reg <= zero when reset = '1' else
        d_reg_temp when DW = '1' else d_reg; 

x_reg <= rd1 when XW = '1' else x_reg;
    
b_reg <= zero when reset = '1' else
        rd2 when BW = '1' else
        b_reg;

shift_reg <= output_shift when SW = '1' else shift_reg;    

mult_reg <= output_MULT when MW_mult = '1';
    
end architecture BehaviouralDataPath;