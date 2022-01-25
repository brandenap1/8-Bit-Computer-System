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

entity Control_Unit is
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
end entity;

architecture ControlUnit_Arch of Control_Unit is
--Constant Declarations (Instruction Codes)
    constant LDA_IMM            : std_logic_vector(7 downto 0) := x"86";        -- Load Register A w/ Immediate Addressing
    constant LDA_DIR            : std_logic_vector(7 downto 0) := x"87";        -- Load Register A w/ Direct Addressing
    constant STA_DIR            : std_logic_vector(7 downto 0) := x"96";        -- Store Register A to memory (RAM or I/O)
    constant LDB_IMM            : std_logic_vector(7 downto 0) := x"88";        -- Load Register B w/ Immediate Addressing
    constant LDB_DIR            : std_logic_vector(7 downto 0) := x"89";        -- Load Register B w/ Direct Addressing
    constant STB_DIR            : std_logic_vector(7 downto 0) := x"97";        -- Store Register B to memory (RAM or I/O)
    constant BRA                : std_logic_vector(7 downto 0) := x"20";        -- Branch Always
    constant BEQ                : std_logic_vector(7 downto 0) := x"21";        --Branch if equal to 0
    constant ADD_AB             : std_logic_vector(7 downto 0) := x"42";        -- A <= A + B
    constant SUB_AB             : std_logic_vector(7 downto 0) := x"43";        -- A <= A - B
    constant AND_AB             : std_logic_vector(7 downto 0) := x"44";        -- A <= A and B   
    constant OR_AB              : std_logic_vector(7 downto 0) := x"45";        -- A <= A or B
    constant INCA               : std_logic_vector(7 downto 0) := x"46";        -- A <= A + 1
    constant INCB               : std_logic_vector(7 downto 0) := x"47";        -- B <= B + 1
    constant DECA               : std_logic_vector(7 downto 0) := x"48";        -- A <= A -1
    constant DECB               : std_logic_vector(7 downto 0) := x"49";        -- B <= B - 1 
--Signal Declarations
    type State_Type is (S_FETCH_0,S_FETCH_1,S_FETCH_2,                  --Op code fetch state                     
                        S_DECODE_3,                                     --Op code Decode state
                        S_LDA_IMM_4,S_LDA_IMM_5,S_LDA_IMM_6,
                        S_LDA_DIR_4,S_LDA_DIR_5,S_LDA_DIR_6,S_LDA_DIR_7,S_LDA_DIR_8,
                        S_STA_DIR_4,S_STA_DIR_5,S_STA_DIR_6,S_STA_DIR_7,
                        S_LDB_IMM_4,S_LDB_IMM_5,S_LDB_IMM_6,
                        S_LDB_DIR_4,S_LDB_DIR_5,S_LDB_DIR_6,S_LDB_DIR_7,S_LDB_DIR_8,
                        S_STB_DIR_4,S_STB_DIR_5,S_STB_DIR_6,S_STB_DIR_7,
                        S_ADD_AB_4,
                        S_BRA_4,S_BRA_5,S_BRA_6,
                        S_BEQ_4,S_BEQ_5,S_BEQ_6,S_BEQ_7);
    signal current_state,next_state     : State_Type;
    
    signal A                : std_logic_vector(7 downto 0);
    signal B                : std_logic_vector(7 downto 0);
    signal Result           : std_logic_vector(7 downto 0);
begin


--Control Unit (FSM)   

    MEMORY : process(Clock,Reset)
    begin
        if(Reset = '0') then
            current_state <= S_FETCH_0;
        elsif(rising_edge(Clock)) then
            current_state <= next_state;
        end if;
    end process;
    
    NXT_STATE : process(current_state,IR,CCR_Result)
    begin
        case(current_state) is 
            when S_FETCH_0      => next_state <= S_FETCH_1;
            when S_FETCH_1      => next_state <= S_FETCH_2;
            when S_FETCH_2      => next_state <= S_DECODE_3;
            when S_DECODE_3     => if(IR = LDA_IMM) then
                                       next_state <= S_LDA_IMM_4;
                                   elsif(IR = LDB_IMM) then
                                       next_state <= S_LDB_IMM_4;
                                   elsif(IR = LDA_DIR) then
                                       next_state <= S_LDA_DIR_4;
                                   elsif(IR = LDB_DIR) then
                                       next_state <= S_LDB_DIR_4;                                      
                                   elsif(IR = STA_DIR) then
                                       next_state <= S_STA_DIR_4;
                                   elsif(IR = STB_DIR) then
                                       next_state <= S_STB_DIR_4;                                       
                                   elsif(IR = ADD_AB) then
                                       next_state <= S_ADD_AB_4;
                                   elsif(IR = BRA) then
                                       next_state <= S_BRA_4;
                                   elsif(IR = BEQ and CCR_Result(2) = '1') then
                                       next_state <= S_BEQ_4;
                                   elsif(IR = BEQ and CCR_Result(2) = '0') then
                                       next_state <= S_BEQ_7;
                                   end if;
            when S_LDA_IMM_4    => next_state <= S_LDA_IMM_5;
            when S_LDA_IMM_5    => next_state <= S_LDA_IMM_6;
            when S_LDA_IMM_6    => next_state <= S_FETCH_0;
            when S_LDA_DIR_4    => next_state <= S_LDA_DIR_5;
            when S_LDA_DIR_5    => next_state <= S_LDA_DIR_6;
            when S_LDA_DIR_6    => next_state <= S_LDA_DIR_7;
            when S_LDA_DIR_7    => next_state <= S_LDA_DIR_8;
            when S_LDA_DIR_8    => next_state <= S_FETCH_0;
            when S_STA_DIR_4    => next_state <= S_STA_DIR_5;
            when S_STA_DIR_5    => next_state <= S_STA_DIR_6;
            when S_STA_DIR_6    => next_state <= S_STA_DIR_7;
            when S_STA_DIR_7    => next_state <= S_FETCH_0;
            when S_LDB_IMM_4    => next_state <= S_LDB_IMM_5;
            when S_LDB_IMM_5    => next_state <= S_LDB_IMM_6;
            when S_LDB_IMM_6    => next_state <= S_FETCH_0;
            when S_LDB_DIR_4    => next_state <= S_LDB_DIR_5;
            when S_LDB_DIR_5    => next_state <= S_LDB_DIR_6;
            when S_LDB_DIR_6    => next_state <= S_LDB_DIR_7;
            when S_LDB_DIR_7    => next_state <= S_LDB_DIR_8;
            when S_LDB_DIR_8    => next_state <= S_FETCH_0;
            when S_STB_DIR_4    => next_state <= S_STB_DIR_5;
            when S_STB_DIR_5    => next_state <= S_STB_DIR_6;
            when S_STB_DIR_6    => next_state <= S_STB_DIR_7;
            when S_STB_DIR_7    => next_state <= S_FETCH_0;
            when S_ADD_AB_4     => next_state <= S_FETCH_0;
            when S_BRA_4        => next_state <= S_BRA_5;
            when S_BRA_5        => next_state <= S_BRA_6;
            when S_BRA_6        => next_state <= S_FETCH_0;
            when S_BEQ_4        => next_state <= S_BEQ_5;
            when S_BEQ_5        => next_state <= S_BEQ_6;
            when S_BEQ_6        => next_state <= S_FETCH_0; 
            when S_BEQ_7        => next_state <= S_FETCH_0;     
            when others         => next_state <= S_FETCH_0;
        end case;
    end process;
    
    
    OUTPUT : process(current_state)
    begin
        case(current_state) is
        
-- Fetch State ----------------------------------------------------------------------------------------
            when S_FETCH_0 =>   IR_Load     <= '0';
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "01";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';
            when S_FETCH_1 =>   IR_Load     <= '0';     -- Increment Program Counter (Op_Code for next state)
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '1';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';
            when S_FETCH_2 =>   IR_Load     <= '1';     -- Put Op_Code into IR
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';
------------------------------------------------------------------------------------------------------
-- Decode State --------------------------------------------------------------------------------------                            
            when S_DECODE_3 =>  IR_Load     <= '0';     -- No outputs, machine is decoding IR 
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';  
-------------------------------------------------------------------------------------------------------
-- LDA Immediate --------------------------------------------------------------------------------------
            when S_LDA_IMM_4 => IR_Load     <= '0';     -- Put Program Counter into MAR (Address)
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "01";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';  
            when S_LDA_IMM_5 => IR_Load     <= '0';     -- Increment Program Counter (Op_Code for next state)
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '1';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_LDA_IMM_6 => IR_Load     <= '0';     -- Operand is available, latch to A
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '1';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
-------------------------------------------------------------------------------------------------------
-- LDA Direct -----------------------------------------------------------------------------------------
            when S_LDA_DIR_4 => IR_Load     <= '0';     -- Put Program Counter onto MAR (Address)
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "01";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';  
            when S_LDA_DIR_5 => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '1';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_LDA_DIR_6 => IR_Load     <= '0';     -- Put Operand into MAR
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';
            when S_LDA_DIR_7 => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';  
            when S_LDA_DIR_8 => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '1';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
-------------------------------------------------------------------------------------------------------
-- ST Direct -----------------------------------------------------------------------------------------
            when S_STA_DIR_4 => IR_Load     <= '0';     -- Put A onto Bus2 (Assert Write)
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "01";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';  
            when S_STA_DIR_5 => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '1';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_STA_DIR_6 => IR_Load     <= '0';
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_STA_DIR_7 => IR_Load     <= '0';
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "01";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '1'; 
-------------------------------------------------------------------------------------------------------
-- LDB Immediate --------------------------------------------------------------------------------------
            when S_LDB_IMM_4 => IR_Load     <= '0';     -- Put Program Counter into MAR (Address)
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "01";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';  
            when S_LDB_IMM_5 => IR_Load     <= '0';     -- Increment Program Counter (Op_Code for next state)
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '1';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_LDB_IMM_6 => IR_Load     <= '0';     -- Operand is available, latch to A
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '1';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';
-------------------------------------------------------------------------------------------------------
-- LDB Direct -----------------------------------------------------------------------------------------
            when S_LDB_DIR_4 => IR_Load     <= '0';     -- Put Program Counter onto MAR (Address)
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "01";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';  
            when S_LDB_DIR_5 => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '1';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_LDB_DIR_6 => IR_Load     <= '0';     -- Put Operand into MAR
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';
            when S_LDB_DIR_7 => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';  
            when S_LDB_DIR_8 => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '1';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
-------------------------------------------------------------------------------------------------------
-- STB Direct -----------------------------------------------------------------------------------------
            when S_STB_DIR_4 => IR_Load     <= '0';     -- Put A onto Bus2 (Assert Write)
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "01";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';  
            when S_STB_DIR_5 => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '1';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_STB_DIR_6 => IR_Load     <= '0';
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_STB_DIR_7 => IR_Load     <= '0';
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "10";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '1'; 
-------------------------------------------------------------------------------------------------------
-- BRA ------------------------------------------------------------------------------------------------
            when S_BRA_4     => IR_Load     <= '0';
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "01";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';
            when S_BRA_5     => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_BRA_6     => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '1';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
-------------------------------------------------------------------------------------------------------
-- ADD_AB ---------------------------------------------------------------------------------------------
            when S_ADD_AB_4  => IR_Load     <= '0';
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '1';
                                B_Load      <= '0';
                                ALU_Sel     <= "001";   -- "ADD" "ADD" "ADD" "ADD" "ADD" "ADD" "ADD" "ADD" "ADD" "ADD" "ADD" "ADD"
                                CCR_Load    <= '1';
                                Bus1_Sel    <= "01";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
-------------------------------------------------------------------------------------------------------
-- BRA ------------------------------------------------------------------------------------------------
            when S_BEQ_4     => IR_Load     <= '0';
                                MAR_Load    <= '1';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';
            when S_BEQ_5     => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_BEQ_6     => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '1';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "10";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
            when S_BEQ_7     => IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '1';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0'; 
-------------------------------------------------------------------------------------------------------
-- Others ---------------------------------------------------------------------------------------------
            when others    =>   IR_Load     <= '0';
                                MAR_Load    <= '0';
                                PC_Load     <= '0';
                                PC_Inc      <= '0';
                                A_Load      <= '0';
                                B_Load      <= '0';
                                ALU_Sel     <= "000";
                                CCR_Load    <= '0';
                                Bus1_Sel    <= "00";    --  "00" = PC, "01" = A, "10" = B
                                Bus2_Sel    <= "00";    --  "00" = ALU, "01" = Bus1, "10" = from_Memory
                                Write       <= '0';
-------------------------------------------------------------------------------------------------------
         end case;                             
    end process;

end ControlUnit_Arch;