----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/10/2022 04:44:27 PM
-- Design Name: 
-- Module Name: Data_Path - DataPath_Arch
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

entity Data_Path is
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
end Data_Path;

architecture DataPath_Arch of Data_Path is
    signal A,B          : std_logic_vector(7 downto 0);
    signal Bus1         : std_logic_vector(7 downto 0);
    signal Bus2         : std_logic_vector(7 downto 0);
    signal PC           : std_logic_vector(7 downto 0);
    signal ALU_Result   : std_logic_vector(7 downto 0);
    signal MAR          : std_logic_vector(7 downto 0);
    signal PC_uns       : unsigned(7 downto 0);
    signal NZVC         : std_logic_vector(3 downto 0);
    
begin

--MUXes
    MUX_BUS1 : process(Bus1_Sel,PC,A,B)
    begin
        case(Bus1_Sel) is 
            when "00" => Bus1 <= PC;
            when "01" => Bus1 <= A;
            when "10" => Bus1 <= B;
            when others => Bus1 <= x"00";
        end case; 
    end process;    

    MUX_BUS2 : process(Bus2_Sel,ALU_Result,Bus1,from_Memory)
    begin
        case(Bus2_Sel) is 
            when "00" => Bus2 <= ALU_Result;
            when "01" => Bus2 <= Bus1;
            when "10" => Bus2 <= from_Memory;
            when others => Bus2 <= x"00";
        end case; 
    end process; 
    
    Address <= MAR;
    to_Memory <= Bus1;    
-- ALU Process --------------------------------------------------
    ALU_PROCESS : process(A,B,ALU_Sel)
         variable Sum_uns : unsigned(8 downto 0);
    begin
-- Addition ----------------------------------------------------------
        if(ALU_Sel = "000") then        
        -- Sum Calculation -----------------------
            Sum_uns := unsigned('0' & A) + unsigned('0' & B);
            ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));    
        -- Negative Flag (N) ---------------------
            NZVC(3) <= Sum_uns(7);     
        -- Zero Flag (Z) -------------------------
            if(Sum_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';
            else
                NZVC(2) <= '0';
            end if;
        -- Overflow Flag (V) ---------------------
            if((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or 
               (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
                NZVC(1) <= '1';
            else 
                NZVC(1) <= '0';
            end if;
        -- Carry Flag (C) ------------------------
             NZVC(0) <= Sum_uns(8);
-- Subtraction -------------------------------------------------------------     
         elsif(ALU_Sel = "001") then        
        -- Sum Calculation -----------------------
            Sum_uns := unsigned('0' & A) - unsigned('0' & B);
            ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));    
        -- Negative Flag (N) ---------------------
            NZVC(3) <= Sum_uns(7);     
        -- Zero Flag (Z) -------------------------
            if(Sum_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';
            else
                NZVC(2) <= '0';
            end if;
        -- Overflow Flag (V) ---------------------
            if((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or 
               (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
                NZVC(1) <= '1';
            else 
                NZVC(1) <= '0';
            end if;
        -- Carry Flag (C) ------------------------
             NZVC(0) <= Sum_uns(8);
-- A AND B -------------------------------------------------------------     
         elsif(ALU_Sel = "010") then        
        -- Sum Calculation -----------------------
            Sum_uns := unsigned('0' & A) AND unsigned('0' & B);
            ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));    
        -- Negative Flag (N) ---------------------
            NZVC(3) <= Sum_uns(7);     
        -- Zero Flag (Z) -------------------------
            if(Sum_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';
            else
                NZVC(2) <= '0';
            end if;
        -- Overflow Flag (V) ---------------------
            if((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or 
               (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
                NZVC(1) <= '1';
            else 
                NZVC(1) <= '0';
            end if;
        -- Carry Flag (C) ------------------------
             NZVC(0) <= Sum_uns(8);

-------------------------------------------------------------------------    
-- A OR B -------------------------------------------------------------     
         elsif(ALU_Sel = "011") then        
        -- Sum Calculation -----------------------
            Sum_uns := unsigned('0' & A) OR unsigned('0' & B);
            ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));    
        -- Negative Flag (N) ---------------------
            NZVC(3) <= Sum_uns(7);     
        -- Zero Flag (Z) -------------------------
            if(Sum_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';
            else
                NZVC(2) <= '0';
            end if;
        -- Overflow Flag (V) ---------------------
            if((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or 
               (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
                NZVC(1) <= '1';
            else 
                NZVC(1) <= '0';
            end if;
        -- Carry Flag (C) ------------------------
             NZVC(0) <= Sum_uns(8);
-- A INCREMENT -------------------------------------------------------------     
         elsif(ALU_Sel = "100") then        
        -- Sum Calculation -----------------------
            Sum_uns := unsigned('0' & A) + 1;
            ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));    
        -- Negative Flag (N) ---------------------
            NZVC(3) <= Sum_uns(7);     
        -- Zero Flag (Z) -------------------------
            if(Sum_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';
            else
                NZVC(2) <= '0';
            end if;
        -- Overflow Flag (V) ---------------------
            if((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or 
               (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
                NZVC(1) <= '1';
            else 
                NZVC(1) <= '0';
            end if;
        -- Carry Flag (C) ------------------------
             NZVC(0) <= Sum_uns(8);
-- B INCREMENT -------------------------------------------------------------     
         elsif(ALU_Sel = "101") then        
        -- Sum Calculation -----------------------
            Sum_uns := unsigned('0' & B) + 1;
            ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));    
        -- Negative Flag (N) ---------------------
            NZVC(3) <= Sum_uns(7);     
        -- Zero Flag (Z) -------------------------
            if(Sum_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';
            else
                NZVC(2) <= '0';
            end if;
        -- Overflow Flag (V) ---------------------
            if((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or 
               (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
                NZVC(1) <= '1';
            else 
                NZVC(1) <= '0';
            end if;
        -- Carry Flag (C) ------------------------
             NZVC(0) <= Sum_uns(8);
         else
             NZVC <= "0000";
         end if;          
 end process;
--Registers
    INSTRUCTION_REG : process(Clock,Reset)
    begin
        if(Reset = '0') then
            IR <= x"00";
        elsif(rising_edge(Clock)) then
            if(IR_Load = '1') then
                IR <= Bus2;
            end if;
        end if;
    end process;
    
    MEMORY_ADDRESS_REG : process(Clock,Reset)
    begin
        if(Reset = '0') then
            MAR <= x"00";
        elsif(rising_edge(Clock)) then
            if(MAR_Load = '1') then
                MAR <= Bus2;
            end if;
        end if;
    end process;
    
    A_REG : process(Clock,Reset)
    begin
        if(Reset = '0') then
            A <= x"00";
        elsif(rising_edge(Clock)) then
            if(A_Load = '1') then
                A <= Bus2;
            end if;
        end if;
    end process;
    
    B_REG : process(Clock,Reset)
    begin
        if(Reset = '0') then
            B <= x"00";
        elsif(rising_edge(Clock)) then
            if(B_Load = '1') then
                B <= Bus2;
            end if;
        end if;
    end process;
    
--Program Counter
    PROGRAM_COUNTER : process(Clock,Reset)
    begin
        if(Reset = '0') then
            PC_uns <= x"00";
        elsif(rising_edge(Clock)) then
            if(PC_Load = '1') then
                PC_uns <= unsigned(Bus2);
            elsif(PC_Inc = '1') then
                PC_uns <= PC_uns + 1;
            end if;
        end if;
    end process;
    
    PC <= std_logic_vector(PC_uns);

-- Condition Code Register
    CONDITION_CODE_REG : process(Clock,Reset)
    begin
        if(Reset = '0') then
            CCR_Result <= "0000";
        elsif(rising_edge(Clock)) then
            if(CCR_Load = '1') then
                CCR_Result <= NZVC;
            end if;
        end if;
    end process;  
      
end DataPath_Arch;
