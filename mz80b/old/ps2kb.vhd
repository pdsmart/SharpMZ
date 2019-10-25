--
-- ps2kb.vhd
--
-- PS/2 Keyboard Interface module
-- for MZ-700 on FPGA
--
-- Nibbles Lab. 2005
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ps2kb is
    Port ( RST : in std_logic;
    		 KCLK : in std_logic;
    		 PS2CK : in std_logic;
           PS2DT : in std_logic;
           DTEN : out std_logic;
           DATA : out std_logic_vector(7 downto 0));
end ps2kb;

architecture Behavioral of ps2kb is

--
-- PS/2 recieve data
--
signal KEYDT : std_logic_vector(10 downto 0);
signal CKDT : std_logic_vector(3 downto 0);
--
-- Parity
--
signal PARITY : std_logic;

begin

	--
	-- PS/2 recieve
	--
	process( RST, KCLK ) begin
		if RST='0' then
			KEYDT<=(others=>'1');
			DATA<=(others=>'0');
			DTEN<='0';
		elsif KCLK'event and KCLK='1' then
			CKDT<=CKDT(2 downto 0)&PS2CK;
			if CKDT="0011" then
				KEYDT<=PS2DT&KEYDT(10 downto 1);
			end if;
			if KEYDT(0)='0' and KEYDT(10)='1' and KEYDT(9)=not PARITY then
				DTEN<='1';
				DATA<=KEYDT(8 downto 1);
				KEYDT<=(others=>'1');
			else
				DTEN<='0';
			end if;
		end if;
	end process;

	process( KEYDT(9 downto 2) )
		variable TEMP : std_logic;
	begin
		TEMP:='0';
		for I in 1 to 8 loop
			TEMP:=TEMP xor KEYDT(I);
		end loop;
		PARITY<=TEMP;
	end process;

end Behavioral;
