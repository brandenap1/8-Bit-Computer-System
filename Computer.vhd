----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/09/2022 04:40:58 PM
-- Design Name: 
-- Module Name: Computer - Computer_Arch
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Computer is
    port(Clock,Reset        : in std_logic;
         Address            : in std_logic_vector(7 downto 0); 
         Write              : in std_logic;
         Port_in_00         : in std_logic_vector(7 downto 0);
         Port_in_01         : in std_logic_vector(7 downto 0);
         Port_in_02         : in std_logic_vector(7 downto 0);
         Port_in_03         : in std_logic_vector(7 downto 0);
         Port_in_04         : in std_logic_vector(7 downto 0);
         Port_in_05         : in std_logic_vector(7 downto 0);
         Port_in_06         : in std_logic_vector(7 downto 0);
         Port_in_07         : in std_logic_vector(7 downto 0);
         Port_in_08         : in std_logic_vector(7 downto 0);
         Port_in_09         : in std_logic_vector(7 downto 0);
         Port_in_10         : in std_logic_vector(7 downto 0);
         Port_in_11         : in std_logic_vector(7 downto 0);
         Port_in_12         : in std_logic_vector(7 downto 0);
         Port_in_13         : in std_logic_vector(7 downto 0);
         Port_in_14         : in std_logic_vector(7 downto 0);
         Port_in_15         : in std_logic_vector(7 downto 0));
end Computer;

architecture Computer_Arch of Computer is
--CPU-----------------------------------------------------------------------
--Signal Declarations
    signal from_Memory,to_Memory        : std_logic_vector(7 downto 0);
--Component Declaration'
    component CPU
        port(Clock,Reset        : in std_logic;
             from_Memory        : in std_logic_vector(7 downto 0);
             Address            : out std_logic_vector(7 downto 0);
             to_Memory          : out std_logic_vector(7 downto 0);  
             Write              : out std_logic);
    end component;
----------------------------------------------------------------------------
--Memory--------------------------------------------------------------------
--Signal Declarations

--Component Declaration
    component Memory
    port(Clock,Reset        : in std_logic;
         Address            : in std_logic_vector(7 downto 0); 
         Write              : in std_logic;
         Data_in            : in std_logic_vector(7 downto 0);
         Port_in_00         : in std_logic_vector(7 downto 0);
         Port_in_01         : in std_logic_vector(7 downto 0);
         Port_in_02         : in std_logic_vector(7 downto 0);
         Port_in_03         : in std_logic_vector(7 downto 0);
         Port_in_04         : in std_logic_vector(7 downto 0);
         Port_in_05         : in std_logic_vector(7 downto 0);
         Port_in_06         : in std_logic_vector(7 downto 0);
         Port_in_07         : in std_logic_vector(7 downto 0);
         Port_in_08         : in std_logic_vector(7 downto 0);
         Port_in_09         : in std_logic_vector(7 downto 0);
         Port_in_10         : in std_logic_vector(7 downto 0);
         Port_in_11         : in std_logic_vector(7 downto 0);
         Port_in_12         : in std_logic_vector(7 downto 0);
         Port_in_13         : in std_logic_vector(7 downto 0);
         Port_in_14         : in std_logic_vector(7 downto 0);
         Port_in_15         : in std_logic_vector(7 downto 0);
         Data_out           : out std_logic_vector(7 downto 0));
    end component;
             
----------------------------------------------------------------------------
begin

--Instantiation
    U1 : CPU port map(Clock,Reset,from_Memory,Address,to_Memory,Write);
    
    
    U2 : Memory port map(Clock,Reset,Address,Write,to_Memory,
                         Port_in_00,Port_in_01,Port_in_02,Port_in_03,
                         Port_in_04,Port_in_05,Port_in_06,Port_in_07,
                         Port_in_08,Port_in_09,Port_in_10,Port_in_11,
                         Port_in_12,Port_in_13,Port_in_14,Port_in_15,
                         from_Memory);          
    
end Computer_Arch;
