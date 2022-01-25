----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/10/2022 01:29:07 PM
-- Design Name: 
-- Module Name: CPU - CPU_Arch
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU is
    port(Clock,Reset        : in std_logic;
         from_Memory        : in std_logic_vector(7 downto 0);
         Address            : out std_logic_vector(7 downto 0);
         to_Memory          : out std_logic_vector(7 downto 0);  
         Write              : out std_logic);    
end CPU;

architecture CPU_Arch of CPU is
--Control_Unit
--Constant Declarations
    constant LDA_IMM,LDA_DIR    : std_logic_vector(8 downto 0) := x"00";
    constant STA_DIR            : std_logic_vector(8 downto 0) := x"00";   
    constant ADD_AB             : std_logic_vector(8 downto 0) := x"00";  
    constant BRA                : std_logic_vector(8 downto 0) := x"00";
    constant BEQ                : std_logic_vector(8 downto 0) := x"00";           
--Signal Declarations
    signal IR_Load      : std_logic;
    signal IR           : std_logic_vector(7 downto 0);
    signal MAR_Load     : std_logic;
    signal PC_Load      : std_logic;
    signal PC_Inc       : std_logic;
    signal A_Load       : std_logic;
    signal B_Load       : std_logic;
    signal ALU_Sel      : std_logic_vector(2 downto 0);
    signal CCR_Result   : std_logic_vector(3 downto 0);
    signal CCR_Load     : std_logic;
    signal Bus2_Sel     : std_logic_vector(1 downto 0);
    signal Bus1_Sel     : std_logic_vector(1 downto 0);
--Component Declaration
    component Control_Unit
        port(Clock,Reset        : in std_logic;
             IR                 : in std_logic_vector(7 downto 0);
             CCR_Result         : in std_logic_vector(3 downto 0);
             IR_Load            : out std_logic;
             MAR_Load           : out std_logic;
             PC_Load            : out std_logic;
             PC_Inc             : out std_logic;
             A_Load             : out std_logic;
             B_Load             : out std_logic;
             ALU_Sel            : out std_logic_vector(2 downto 0);
             CCR_Load           : out std_logic;
             Bus2_Sel           : out std_logic_vector(1 downto 0);
             Bus1_Sel           : out std_logic_vector(1 downto 0);
             Write              : out std_logic);
    end component;
----------------------------------------------------------------------
--Data_Path-----------------------------------------------------------
--Signal Declarations
    
    
    signal A,B          : std_logic_vector(7 downto 0);
    signal Bus1         : std_logic_vector(7 downto 0);
    signal Bus2         : std_logic_vector(7 downto 0);
    signal PC           : std_logic_vector(7 downto 0);
    signal ALU_Result   : std_logic_vector(7 downto 0);
    signal MAR          : std_logic_vector(7 downto 0);
    signal PC_uns       : unsigned;
--Component Declaration
    component Data_Path
        port(Clock,Reset    : in std_logic;
             IR_Load        : in std_logic;
             MAR_Load       : in std_logic;
             PC_Load        : in std_logic;
             PC_Inc         : in std_logic;
             A_Load         : in std_logic;
             B_Load         : in std_logic;
             ALU_Sel        : in std_logic_vector(2 downto 0);
             CCR_Load       : in std_logic;
             Bus2_Sel       : in std_logic_vector(1 downto 0);
             Bus1_Sel       : in std_logic_vector(1 downto 0);
             from_Memory    : in std_logic_vector(7 downto 0);
             IR             : out std_logic_vector(7 downto 0);
             CCR_Result     : out std_logic_vector(3 downto 0);
             to_Memory      : out std_logic_vector(7 downto 0);
             Address        : out std_logic_vector(7 downto 0));
    end component;
----------------------------------------------------------------------    
begin

--Instantiation
    U1 : Data_Path port map(Clock,Reset,IR_Load,MAR_Load,PC_Load,PC_Inc,
                            A_Load,B_Load,ALU_Sel,CCR_Load,Bus2_Sel,Bus1_Sel,
                            from_Memory,IR,CCR_Result,to_Memory,Address);

    U2 : Control_Unit port map(Clock,Reset,IR,CCR_Result,IR_Load,
                                MAR_Load,PC_Load,PC_Inc,A_Load,B_Load,
                                ALU_Sel,CCR_Load,Bus2_Sel,Bus1_Sel,Write);
end CPU_Arch;
