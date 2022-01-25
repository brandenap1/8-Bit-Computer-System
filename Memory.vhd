----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/09/2022 04:51:39 PM
-- Design Name: 
-- Module Name: Memory - Memory_Arch
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Memory is
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
         Port_out_00        : out std_logic_vector(7 downto 0);
         Port_out_01        : out std_logic_vector(7 downto 0);
         Port_out_02        : out std_logic_vector(7 downto 0);
         Port_out_03        : out std_logic_vector(7 downto 0);
         Port_out_04        : out std_logic_vector(7 downto 0);
         Port_out_05        : out std_logic_vector(7 downto 0);
         Port_out_06        : out std_logic_vector(7 downto 0);
         Port_out_07        : out std_logic_vector(7 downto 0);
         Port_out_08        : out std_logic_vector(7 downto 0);
         Port_out_09        : out std_logic_vector(7 downto 0);
         Port_out_10        : out std_logic_vector(7 downto 0);
         Port_out_11        : out std_logic_vector(7 downto 0);
         Port_out_12        : out std_logic_vector(7 downto 0);
         Port_out_13        : out std_logic_vector(7 downto 0);
         Port_out_14        : out std_logic_vector(7 downto 0);
         Port_out_15        : out std_logic_vector(7 downto 0);
         Data_out           : out std_logic_vector(7 downto 0));
end entity;

architecture Memory_Arch of Memory is
--Constant Declarations
    constant LDA_IMM      : std_logic_vector(7 downto 0) := x"86";
    constant LDA_DIR      : std_logic_vector(7 downto 0) := x"87";
    constant LDB_IMM      : std_logic_vector(7 downto 0) := x"88";
    constant LDB_DIR      : std_logic_vector(7 downto 0) := x"89";
    constant STA_DIR      : std_logic_vector(7 downto 0) := x"96";
    constant STB_DIR      : std_logic_vector(7 downto 0) := x"97";
    constant ADD_AB       : std_logic_vector(7 downto 0) := x"42";
    constant SUB_AB       : std_logic_vector(7 downto 0) := x"43";
    constant AND_AB       : std_logic_vector(7 downto 0) := x"44";
    constant OR_AB        : std_logic_vector(7 downto 0) := x"45";
    constant INCA         : std_logic_vector(7 downto 0) := x"46";
    constant INCB         : std_logic_vector(7 downto 0) := x"47";
    constant DECA         : std_logic_vector(7 downto 0) := x"48";
    constant DECB         : std_logic_vector(7 downto 0) := x"49";
    constant BRA          : std_logic_vector(7 downto 0) := x"20";
    constant BMI          : std_logic_vector(7 downto 0) := x"21";
    constant BPL          : std_logic_vector(7 downto 0) := x"22";
    constant BEQ          : std_logic_vector(7 downto 0) := x"23";
    constant BNE          : std_logic_vector(7 downto 0) := x"24";
    constant BVS          : std_logic_vector(7 downto 0) := x"25";
    constant BVC          : std_logic_vector(7 downto 0) := x"26";
    constant BCS          : std_logic_vector(7 downto 0) := x"27";
    constant BCC          : std_logic_vector(7 downto 0) := x"28";
--Signal Declarations (Ports)
--ROM----------------------------------------------------------
--Signal Declarations
    signal ROM_EN       : std_logic;
    signal RW_EN        : std_logic;
    signal Data_ROM     : std_logic_vector(7 downto 0);
    type ROM_Type is array(0 to 127) of std_logic_vector(7 downto 0);
    
    constant ROM : Rom_Type := (0       => LDA_IMM,
                                1       => x"AA",
                                2       => STA_DIR,
                                3       => x"E0",
                                4       => BRA,
                                5       => x"00",
                                others  => x"00");
---------------------------------------------------------------
--R/W----------------------------------------------------------
--Signal Declarations
    type RW_Type is array (128 to 223) of std_logic_vector(7 downto 0);
    signal RW : RW_Type;
    signal Data_RW      : std_logic_vector(7 downto 0);
---------------------------------------------------------------
begin

--ROM
    ENABLE_ROM : process(Address)
    begin
        if((to_integer(unsigned(Address)) >= 0) AND
           (to_integer(unsigned(Address)) <= 127)) then
            ROM_EN <= '1';
        else
            ROM_EN <= '0'; 
        end if;
    end process;

    MEMORY : process(Clock)
    begin
        if(rising_edge(Clock)) then
            if(ROM_EN = '1') then
                Data_ROM <= ROM(to_integer(unsigned(Address)));
            end if;
        end if;
    end process;

--R/W
    ENABLE_RW : process(Address)
    begin
        if((to_integer(unsigned(Address)) >= 128) AND
           (to_integer(unsigned(Address)) <= 223)) then
            RW_EN <= '1';
        else
            RW_EN <= '0'; 
        end if;
    end process;   

    MEMORY_RW : process(Clock)
    begin
        if(rising_edge(Clock)) then
            if(RW_EN = '1' AND Write = '1') then
                RW(to_integer(unsigned(Address))) <= Data_in;
            elsif(RW_EN = '1' and Write = '0') then
                Data_RW <= RW(to_integer(unsigned(Address)));
            end if;
        end if;
    end process;
    
    
--Output Ports

--Output Port 0 (Address : x"E0")
    U0 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_00 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E0" and Write = '1') then
                Port_Out_00 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 1 (Address : x"E1")
    U1 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_01 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E1" and Write = '1') then
                Port_Out_01 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 2 (Address : x"E2")
    U2 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_02 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E2" and Write = '1') then
                Port_Out_02 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 3 (Address : x"E3")
    U3 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_03 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E3" and Write = '1') then
                Port_Out_03 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 4 (Address : x"E4")
    U4 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_04 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E4" and Write = '1') then
                Port_Out_04 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 5 (Address : x"E5")
    U5 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_05 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E5" and Write = '1') then
                Port_Out_05 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 6 (Address : x"E6")
    U6 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_06 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E6" and Write = '1') then
                Port_Out_06 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 7 (Address : x"E7")
    U7 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_07 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E7" and Write = '1') then
                Port_Out_07 <= Data_in;
            end if;
        end if;
    end process; 

--Output Port 8 (Address : x"E0")
    U8 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_08 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E8" and Write = '1') then
                Port_Out_08 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 9 (Address : x"E1")
    U9 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_09 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"E9" and Write = '1') then
                Port_Out_09 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 10 (Address : x"EA")
    U10 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_10 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"EA" and Write = '1') then
                Port_Out_10 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 11 (Address : x"EB")
    U11 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_11 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"EB" and Write = '1') then
                Port_Out_11 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 12 (Address : x"EC")
    U12 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_12 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"EC" and Write = '1') then
                Port_Out_12 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 13 (Address : x"ED")
    U13 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_13 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"ED" and Write = '1') then
                Port_Out_13 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 14 (Address : x"EE")
    U14 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_14 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"EE" and Write = '1') then
                Port_Out_14 <= Data_in;
            end if;
        end if;
    end process;
--Output Port 15 (Address : x"EF")
    U15 : process(Clock,Reset)     
    begin
        if(Reset = '0') then
            Port_Out_15 <= x"00";
        elsif(rising_edge(Clock)) then
            if(Address = x"EF" and Write = '1') then
                Port_Out_15 <= Data_in;
            end if;
        end if;
    end process;
    
 
--MUX for Output Data
    MUX1 : process(Address,Data_ROM,Data_RW,Port_in_00,Port_in_01,  
                   Port_in_02,Port_in_03,Port_in_04,Port_in_05,
                   Port_in_06,Port_in_07,Port_in_08,Port_in_09,
                   Port_in_10,Port_in_11,Port_in_12,Port_in_13,
                   Port_in_14,Port_in_15)
    begin
        if((to_integer(unsigned(Address)) >= 0) AND
           (to_integer(unsigned(Address)) <= 127)) then
               Data_Out <= Data_ROM;
        elsif((to_integer(unsigned(Address)) >= 128) AND
           (to_integer(unsigned(Address)) <= 223)) then
               Data_Out <= Data_RW;
        elsif(Address = x"F0") then Data_Out <= Port_in_00;
        elsif(Address = x"F1") then Data_Out <= Port_in_01;
        elsif(Address = x"F2") then Data_Out <= Port_in_02;
        elsif(Address = x"F3") then Data_Out <= Port_in_03;
        elsif(Address = x"F4") then Data_Out <= Port_in_04;
        elsif(Address = x"F5") then Data_Out <= Port_in_05;
        elsif(Address = x"F6") then Data_Out <= Port_in_06;
        elsif(Address = x"F7") then Data_Out <= Port_in_07;
        elsif(Address = x"F8") then Data_Out <= Port_in_08;
        elsif(Address = x"F9") then Data_Out <= Port_in_09;
        elsif(Address = x"FA") then Data_Out <= Port_in_10;
        elsif(Address = x"FB") then Data_Out <= Port_in_11;
        elsif(Address = x"FC") then Data_Out <= Port_in_12;
        elsif(Address = x"FD") then Data_Out <= Port_in_13;
        elsif(Address = x"FE") then Data_Out <= Port_in_14;
        elsif(Address = x"FF") then Data_Out <= Port_in_15;
        else
            Data_Out <= x"00";
        end if; 
    end process;
end Memory_Arch;
