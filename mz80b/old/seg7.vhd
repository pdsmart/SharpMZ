--
-- 7seg.vhd
--
-- 4-digit 7-segment LED decorder
-- for MZ-80B on FPGA
--
-- Nibbles Lab. 2013
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity seg7 is
	Port (
		-- 7-SEG Dispaly
		HEX0_D  : out std_logic_vector(6 downto 0);	--	Seven Segment Digit 0
		HEX0_DP : out std_logic;							--	Seven Segment Digit DP 0
		HEX1_D  : out std_logic_vector(6 downto 0);	--	Seven Segment Digit 1
		HEX1_DP : out std_logic;							--	Seven Segment Digit DP 1
		HEX2_D  : out std_logic_vector(6 downto 0);	--	Seven Segment Digit 2
		HEX2_DP : out std_logic;							--	Seven Segment Digit DP 2
		HEX3_D  : out std_logic_vector(6 downto 0);	--	Seven Segment Digit 3
		HEX3_DP : out std_logic;							--	Seven Segment Digit DP 3
		-- Status Signal
		MZMODE  : in std_logic;								-- Hardware Mode
																	-- "0" .. MZ-80B
																	-- "1" .. MZ-2000
		DMODE   : in std_logic;								-- Display Mode
																	-- "0" .. Green
																	-- "1" .. Color
		SCLK	  : in std_logic;
		APSS	  : in std_logic;
		FF		  : in std_logic;
		REW	  : in std_logic;
		NUMEN	  : in std_logic;
		NUMBER  : in std_logic_vector(15 downto 0)
	);
end seg7;

architecture RTL of seg7 is

signal TCNT : std_logic_vector(2 downto 0) := "000";
signal DCNT : std_logic_vector(12 downto 0) := "0000000000000";

begin

	HEX3_D<= "1111111" when APSS='0' and NUMEN='0' and MZMODE='0' else							-- " "
				"0100100" when APSS='0' and NUMEN='0' and MZMODE='1' else							-- "2"
				"1000000" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"0" else		-- "0"
				"1111001" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"1" else		-- "1"
				"0100100" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"2" else		-- "2"
				"0110000" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"3" else		-- "3"
				"0011001" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"4" else		-- "4"
				"0010010" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"5" else		-- "5"
				"0000010" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"6" else		-- "6"
				"1011000" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"7" else		-- "7"
				"0000000" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"8" else		-- "8"
				"0010000" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"9" else		-- "9"
				"0001000" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"a" else		-- "A"
				"0000011" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"b" else		-- "b"
				"1000110" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"c" else		-- "C"
				"0100001" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"d" else		-- "d"
				"0000110" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"e" else		-- "E"
				"0001110" when APSS='0' and NUMEN='1' and NUMBER(15 downto 12)=X"f" else		-- "F"
				"1000111" when APSS='1' and TCNT="010" else		-- "["
				"1100110" when APSS='1' and TCNT="011" else		-- "["
				"1010110" when APSS='1' and TCNT="100" else		-- "["
				"1001110" when APSS='1' and TCNT="101" else		-- "["
				"1000110" when APSS='1' else		-- "["
				"1111111";
	HEX3_DP<='1';

	HEX2_D<= "0000000" when APSS='0' and NUMEN='0' and MZMODE='0' else							-- "8"
				"1000000" when APSS='0' and NUMEN='0' and MZMODE='1' and DMODE='0' else		-- "0"
				"0100100" when APSS='0' and NUMEN='0' and MZMODE='1' and DMODE='1' else		-- "2"
				"1000000" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"0" else		-- "0"
				"1111001" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"1" else		-- "1"
				"0100100" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"2" else		-- "2"
				"0110000" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"3" else		-- "3"
				"0011001" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"4" else		-- "4"
				"0010010" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"5" else		-- "5"
				"0000010" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"6" else		-- "6"
				"1011000" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"7" else		-- "7"
				"0000000" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"8" else		-- "8"
				"0010000" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"9" else		-- "9"
				"0001000" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"a" else		-- "A"
				"0000011" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"b" else		-- "b"
				"1000110" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"c" else		-- "C"
				"0100001" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"d" else		-- "d"
				"0000110" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"e" else		-- "E"
				"0001110" when APSS='0' and NUMEN='1' and NUMBER(11 downto 8)=X"f" else		-- "F"
				"1111110" when APSS='1' and TCNT="110" else		-- "~"
				"1110111" when APSS='1' and TCNT="001" else		-- "_"
				"1110110" when APSS='1' else		-- "="
				"1111111";
	HEX2_DP<='1';

	HEX1_D<= "1000000" when APSS='0' and NUMEN='0' else												-- "0"
				"1000000" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"0" else		-- "0"
				"1111001" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"1" else		-- "1"
				"0100100" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"2" else		-- "2"
				"0110000" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"3" else		-- "3"
				"0011001" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"4" else		-- "4"
				"0010010" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"5" else		-- "5"
				"0000010" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"6" else		-- "6"
				"1011000" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"7" else		-- "7"
				"0000000" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"8" else		-- "8"
				"0010000" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"9" else		-- "9"
				"0001000" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"a" else		-- "A"
				"0000011" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"b" else		-- "b"
				"1000110" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"c" else		-- "C"
				"0100001" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"d" else		-- "d"
				"0000110" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"e" else		-- "E"
				"0001110" when APSS='0' and NUMEN='1' and NUMBER(7 downto 4)=X"f" else		-- "F"
				"1111110" when APSS='1' and TCNT="001" else		-- "~"
				"1110111" when APSS='1' and TCNT="110" else		-- "_"
				"1110110" when APSS='1' else		-- "="
				"1111111";
	HEX1_DP<='1';

	HEX0_D<= "0000011" when APSS='0' and NUMEN='0' and MZMODE='0' else							-- "b"
				"1000000" when APSS='0' and NUMEN='0' and MZMODE='1' else							-- "0"
				"1000000" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"0" else		-- "0"
				"1111001" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"1" else		-- "1"
				"0100100" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"2" else		-- "2"
				"0110000" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"3" else		-- "3"
				"0011001" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"4" else		-- "4"
				"0010010" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"5" else		-- "5"
				"0000010" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"6" else		-- "6"
				"1011000" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"7" else		-- "7"
				"0000000" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"8" else		-- "8"
				"0010000" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"9" else		-- "9"
				"0001000" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"a" else		-- "A"
				"0000011" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"b" else		-- "b"
				"1000110" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"c" else		-- "C"
				"0100001" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"d" else		-- "d"
				"0000110" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"e" else		-- "E"
				"0001110" when APSS='0' and NUMEN='1' and NUMBER(3 downto 0)=X"f" else		-- "F"
				"1111000" when APSS='1' and TCNT="010" else
				"1110100" when APSS='1' and TCNT="011" else
				"1110010" when APSS='1' and TCNT="100" else
				"1110001" when APSS='1' and TCNT="101" else
				"1110000" when APSS='1' else		-- "]"
				"1111111";
	HEX0_DP<='0' when NUMEN='0' and DMODE='1' else '1';

	process( SCLK ) begin
		if SCLK'event and SCLK='1' then
			if DCNT="0011100010000" then
				DCNT<=(others=>'0');
				if FF=REW then
					TCNT<="000";
				elsif FF='1' and REW='0' then
					if TCNT="110" then
						TCNT<="001";
					else
						TCNT<=TCNT+'1';
					end if;
				elsif REW='1' and FF='0' then
					if TCNT(2 downto 1)="00" then
						TCNT<="110";
					else
						TCNT<=TCNT-'1';
					end if;
				end if;
			else
				DCNT<=DCNT+'1';
			end if;
		end if;
	end process;

end RTL;
