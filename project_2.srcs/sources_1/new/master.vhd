library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity master is

  Port ( clk, reset, memorreg : in std_logic;
         addr : in std_logic_vector(9 downto 0);
         segread : out std_logic_vector(31 downto 0);
         state_out : out std_logic_vector(3 downto 0)
        );

end master;

architecture Behavioral of master is
signal Asrc1, PW,IorD, MR, MW, IW, DW, Rsrc, RW, XW, AW, BW, Mult_wad, immediate_true ,SW,MW_mult, SCW, ACW, Mult_true, Fset, Fset_mult, ReW, p : std_logic;
signal ir_out, signals : std_logic_vector(31 downto 0);
signal Asrc2, byte_offset, M2R, res_reg_LAST_TWO : std_logic_vector(1 downto 0);    
signal type_of_dt_ins : std_logic_vector(2 downto 0);    
signal flags_master, optype, state : std_logic_vector(3 downto 0);    

begin
signals <= "0000000000000000"&PW&IorD& MR& MW& IW& DW& Rsrc& RW& XW& AW& BW& Mult_wad& immediate_true &SW&MW_mult& Mult_true;
state_out<= state;
DataPathInstantiate: ENTITY WORK.DataPath(BehaviouralDataPath)
        Port Map ( 
           clk, reset, Asrc1, --: in std_logic;
           ir_out,-- : out std_logic_vector(31 downto 0);
           PW,IorD, MR, MW, IW, DW, Rsrc, RW, XW, AW, BW, Mult_wad, immediate_true ,SW,MW_mult, SCW, ACW, Mult_true, -- : in std_logic; --SW = Shift Write --MW_mult = Mult Write --SCW = Shift Carry Write, -- ACW = ALU Carry Write --Mult_true for selecting reg A
           Asrc2, byte_offset, M2R, -- : in std_logic_vector(1 downto 0);    
           Fset, Fset_mult, --: in std_logic;
           optype,  --: in std_logic_vector(3 downto 0);
           type_of_dt_ins, --: in std_logic_vector(2 downto 0);
           ReW, --: in std_logic;
           flags_master, --: OUT std_logic_vector(3 downto 0) 
           res_reg_LAST_TWO,
           addr,
           memorreg,
           segread
        );

MainCtrlIns: ENTITY WORK.MainCtrl(BehavioralMainCtrl)
        Port Map (  clk, reset, p,--t : IN STD_LOGIC:='0';
                     PW, -- : out STD_LOGIC:='0';
                     IorD, -- : out STD_LOGIC:='0';
                     MR, -- : out STD_LOGIC:='0';
                     MW, -- : out STD_LOGIC:='0';
                     IW, -- : out STD_LOGIC:='0';
                     DW, -- : out STD_LOGIC:='0';
                     M2R, -- : out STD_LOGIC_VECTOR (1 DOWNTO 0):="00";
                     Rsrc, -- : out STD_LOGIC:='0';
                     RW, Mult_wad, Asrc1, -- : out STD_LOGIC:='0';
                     AW, -- : out STD_LOGIC:='0';
                     BW, -- : out STD_LOGIC:='0';
                     XW,MW_mult,SCW,Mult_true, -- : out STD_LOGIC:='0';
                     immediate_true, -- : out STD_LOGIC:='0';	
                     type_of_dt_ins, --: out STD_LOGIC_VECTOR(2 DOWNTO 0);
                     Asrc2, byte_offset, -- : out STD_LOGIC_VECTOR(1 DOWNTO 0):="00";
                     SW, -- : out STD_LOGIC:='0';
                     --optype, -- : out STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
                     Fset_mult, Fset, -- : out STD_LOGIC:='0';
                     ReW, -- : out STD_LOGIC:='0';
                     state, -- : in STD_LOGIC_VECTOR(3 DOWNTO 0);
                     ir_out, -- : in STD_LOGIC_VECTOR(31 downto 0);
                     res_reg_LAST_TWO --: IN STD_LOGIC_Vector(1 DOWNTO 0)
                     );

BCtrlIns: ENTITY WORK.BCtrl(BehavioralBctrl)
        Port Map (
                 ir_out(31 downto 28), flags_master,--: in std_logic_vector(3 downto 0);
                 p--: out std_logic
                  );
                  
ACtrlIns: ENTITY WORK.ACtrl(BehavioralActrl)
        Port Map (
                  i_reg => ir_out(31 downto 0),
                  state => state,
                  op_code => optype
                  );
end Behavioral;
