
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MicrocodeStore is
Port (  Address : in STD_LOGIC_VECTOR (7 downto 0);
        CLK    : in    std_logic;
        PCWriteCond, PCWrite, IorD, MemRead, MemWrite, MemtoReg, IRWrite, RegDst, RegWrite, MDRWEn, AWEn, BWEn,  ALUOutWEn: out std_logic; 
        PCSource, ALUSrcA, ALUSrcB : out std_logic_vector(1 downto 0);
        ALUOp, microFetchSel : out std_logic_vector(1 downto 0)); 
end MicrocodeStore;

architecture Behavioral of MicrocodeStore is

type memType is array(0 to 2**21) of std_logic_vector(22 downto 0);

--set everything to zero
signal memory: memType:= (others=> "00000000000000000000000" ); 
signal temp: std_logic_vector (22 downto 0);

attribute ram_style: string;
attribute ram_style of memory : signal is "distributed";
begin

     --|PCWriteCond|PCWrite|IorD|MemRead | MemWrite | MemtoReg | IRWrite | RegDst | RegWrite | ALUSrcA | ALUSrcB |MDRWEn |  AWEn |BWEn | ALUOutWEn |microfetch sel|(2)PCSource |(2)ALUOp|
memory(0)    <= "0"  & "0" & "0" & "1" &    "0" &      "0" &        "1" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "10";--Fetch(IRWrite gets a new opcode)
memory(1)    <= "0"  & "0" & "0" & "1" &    "0" &      "0" &        "1" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "11" &       "00" &      "10";--Fetch(IRWrite gets a new opcode)

--memory(1)    <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "00"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "00";--DECODE??

memory(16)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "1" & "1"   & "0" &    "01" &       "00" &      "00";--AND -ir to a/b registers
memory(17)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "1" &      "01" &    "00"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";--a/b registers to aLUOut
memory(18)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";--aluout to reg file
memory(19)   <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(32)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "1" & "1"   & "0" &    "01" &       "00" &      "00";--OR
memory(33)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";--OR
memory(34)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "1" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";
memory(35)   <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(48)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "1" & "1"   & "0" &    "01" &       "00" &      "00";--Unsigned Add Reg
memory(49)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(50)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "1" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";
memory(51)   <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(64)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "1" & "1"   & "0" &    "01" &       "00" &      "00";--XOR
memory(65)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(66)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "1" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";
memory(67)   <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(80)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "1" & "1"   & "0" &    "01" &       "00" &      "00";--Signed Add Reg
memory(81)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(82)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "1" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";
memory(83)   <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(96)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "1" & "1"   & "0" &    "01" &       "00" &      "00";--Signed Subtract Reg
memory(97)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(98)   <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "1" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";
memory(99)   <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(112)  <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "1" & "1"   & "0" &    "01" &       "00" &      "00";--Signed Subtract Reg
memory(113)  <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "1" &      "01" &    "00"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(114)  <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "1" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";
memory(115)  <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(128)  <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00"  &   "00" &    "0" &   "1" & "1"   & "0" &    "01" &       "00" &      "00";--sw -LOAD REG A WITH 0 AND B WTIH VALUE
memory(129)  <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "10"  &   "10" &    "0" &   "0" & "1"   & "1" &    "01" &       "00" &      "00";--sw -LOADS ALUOUT WITH ADDRESS
--memory(130)  <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "0"  &   "00" &    "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";--sw -LOAD B REG WITH REGFILE DATA
memory(130)  <= "0"  & "0" & "1" & "0" &    "1" &      "0" &        "0" &    "0" &    "0" &      "00"  &   "00" &    "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";--sw -STORES IN MEMORY
memory(131)  <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(144)  <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00"  &   "00" &    "0" &   "1" & "0"   & "0" &    "01" &       "00" &      "00";--lw -LOADING A REG WITH 0
memory(145)  <= "0"  & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01"  &   "10" &    "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";--lw -INTO ALUOUT
memory(146)  <= "0"  & "0" & "1" & "0" &    "0" &      "0" &        "0" &    "0" &    "1" &      "00"  &   "00" &    "1" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";--lw - ALUOUT TO MDR
memory(147)  <= "0"  & "0" & "0" & "0" &    "0" &      "1" &        "0" &    "1" &    "0" &      "00"  &   "00" &    "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";--lw - INTO REG FILE
memory(148)  <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1

memory(160)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "1" & "0"   & "0" &    "01" &       "00" &      "00";--unSigned add imm
memory(161)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "1" &      "01" &    "10"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(162)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";
memory(163)  <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(176)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "1" & "0"   & "1" &    "01" &       "00" &      "00";--Signed add imm
memory(177)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "1" &      "01" &    "10"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(178)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(179)  <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "1" &    "00" &       "00" &      "01";--PC+1

 
memory(192)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "1" & "0"   & "0" &    "01" &       "00" &      "00";--Signed sub imm
memory(193)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "1" &      "01" &    "10"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(194)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";
memory(195)  <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(208)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "1" & "0"   & "0" &    "01" &       "00" &      "00";--set on less than imm
memory(209)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "1" &      "01" &    "10"  &   "0" &   "0" & "0"   & "1" &    "01" &       "00" &      "00";
memory(210)   <= "0" & "0" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01" &    "00"  &   "0" &   "0" & "0"   & "0" &    "01" &       "00" &      "00";
memory(211)  <= "0"  & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "01"  &   "0" &   "0" & "0"   & "0" &    "00" &       "00" &      "01";--PC+1


memory(224)   <= "0" & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "00" &    "00"  &   "0" &   "0" & "0"   & "0" &    "00" &       "10" &      "00";--jump

memory(240)   <= "0" & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "10"  &   "10" &    "0" &   "1" & "1"   & "1" &    "01" &       "00" &      "00";--Beq(load reg a with 0 and sign extend imm address)
memory(241)   <= "0" & "1" & "0" & "0" &    "0" &      "0" &        "0" &    "0" &    "0" &      "01"  &   "00" &    "0" &   "0" & "0"   & "0" &    "00" &       "01" &      "00";--subtract values

--subtract values

--opcode     - memory location
--0000 fetch    | 00000000 - 0
--0001 and      | 00010000 - 16
--0010 or       | 00100000 - 32
--0011 uAddReg  | 00110000 - 48
--0100 xor      | 01000000 - 64
--0101 sAddReg  | 01010000 - 80
--0110 sSubReg  | 01100000 - 96
--0111 sltReg   | 01110000 - 112

--1000 sw       | 10000000 - 128
--1001 lw       | 10010000 - 144

--1010 uAddImm  | 10100000 - 160
--1011 sAddImm  | 10110000 - 176
--1100 sSubImm  | 11000000 - 192
--1101 sltImm   | 11010000 - 208

--1110 jump     | 11100000 - 224
--1111 BEQ      | 11110000 - 240


--memory(240)  <= "0" & "1" & "111" & "0" & "01";--diplay
--memory(241)  <= "0" & "1" & "111" & "0" & "11";--diplay
--memory(242)  <= "0" & "1" & "111" & "0" & "00";--diplay


process(Address, temp)
begin
temp <= memory(conv_integer(Address));
--PCWriteCond|PCWrite|IorD|MemRead | MemWrite | MemtoReg | IRWrite | RegDst | RegWrite | ALUSrcA | ALUSrcB |MDRWEn |AWEn |BWEn | ALUOutWEn |microfetch sel|(2)PCSource |(2)ALUOp|

PCWriteCond <= temp(22);
PCWrite <= temp(21);
IorD <= temp(20);
MemRead <= temp(19);
MemWrite <= temp(18);
MemtoReg <= temp(17);
IRWrite <= temp(16);
RegDst <= temp(15);
RegWrite <= temp(14);
ALUSrcA <= temp(13 downto 12);
ALUSrcB <= temp(11 downto 10);
MDRWEn <= temp(9);
AWEn <=temp(8);
BWEn <= temp(7);
ALUOutWEN <= temp(6);
microFetchSel <=temp(5 downto 4);
PCSource <= temp(3 downto 2);
ALUOp <= temp(1 downto 0);

end process;
end Behavioral;