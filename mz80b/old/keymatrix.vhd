--
-- keymatrix.vhd
--
-- Convert from PS/2 key-matrix to MZ-80B/2000 key-matrix module
-- for MZ-80B on FPGA
--
-- Nibbles Lab. 2005-2014
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity keymatrix is
	Port (
		-- i8255/PIO
		ZRST_x : in std_logic;
		STROBE : in std_logic_vector(3 downto 0);
		STALL	 : in std_logic;
		KDATA	 : out std_logic_vector(7 downto 0);
		-- PS/2 Keyboard Data
		KCLK  : in std_logic;								-- Key controller base clock
		KBEN  : in std_logic;								-- PS/2 Keyboard Data Valid
		KBDT  : in std_logic_vector(7 downto 0);		-- PS/2 Keyboard Data
		-- for Debug
		LDDAT : out std_logic_vector(7 downto 0);
		-- Avalon Bus
		RRST_x : in std_logic;								-- NiosII Reset
		RCLK	 : in std_logic;								-- NiosII Clock
		RADR	 : in std_logic_vector(15 downto 0);	-- NiosII Address Bus
		RCS_x	 : in std_logic;								-- NiosII Read Signal
		RWE_x	 : in std_logic;								-- NiosII Write Signal
		RDI	 : in std_logic_vector(7 downto 0);		-- NiosII Data Bus(in)
		RDO	 : out std_logic_vector(7 downto 0)		-- NiosII Data Bus(out)
	);
end keymatrix;

architecture Behavioral of keymatrix is

--
-- prefix flag
--
signal FLGF0 : std_logic;
signal FLGE0 : std_logic;
--
-- MZ-series matrix registers
--
signal SCAN00 : std_logic_vector(7 downto 0);
signal SCAN01 : std_logic_vector(7 downto 0);
signal SCAN02 : std_logic_vector(7 downto 0);
signal SCAN03 : std_logic_vector(7 downto 0);
signal SCAN04 : std_logic_vector(7 downto 0);
signal SCAN05 : std_logic_vector(7 downto 0);
signal SCAN06 : std_logic_vector(7 downto 0);
signal SCAN07 : std_logic_vector(7 downto 0);
signal SCAN08 : std_logic_vector(7 downto 0);
signal SCAN09 : std_logic_vector(7 downto 0);
signal SCAN10 : std_logic_vector(7 downto 0);
signal SCAN11 : std_logic_vector(7 downto 0);
signal SCAN12 : std_logic_vector(7 downto 0);
signal SCAN13 : std_logic_vector(7 downto 0);
signal SCAN14 : std_logic_vector(7 downto 0);
signal SCANLL : std_logic_vector(7 downto 0);
--
-- Key code exchange table
--
signal MTEN : std_logic_vector(3 downto 0);
signal MTDT : std_logic_vector(7 downto 0);
signal F_KBDT : std_logic_vector(7 downto 0);
--
-- Backdoor Access
--
signal RWEN : std_logic;
signal RCSK_x : std_logic;

--
-- Components
--
component dpram1kr
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdclock		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wrclock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC  := '0';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
end component;

begin

	--
	-- Instantiation
	--
	MAP0 : dpram1kr PORT MAP (
		data	 => RDI,
		rdaddress	 => F_KBDT,
		rdclock	 => KCLK,
		wraddress	 => RADR(7 downto 0),
		wrclock	 => RCLK,
		wren	 => RWEN,
		q	 => MTDT
	);

	--
	-- Convert
	--
	process( ZRST_x, KCLK ) begin
		if ZRST_x='0' then
			SCAN00<=(others=>'0');
			SCAN01<=(others=>'0');
			SCAN02<=(others=>'0');
			SCAN03<=(others=>'0');
			SCAN04<=(others=>'0');
			SCAN05<=(others=>'0');
			SCAN06<=(others=>'0');
			SCAN07<=(others=>'0');
			SCAN08<=(others=>'0');
			SCAN09<=(others=>'0');
			SCAN10<=(others=>'0');
			SCAN11<=(others=>'0');
			SCAN12<=(others=>'0');
			SCAN13<=(others=>'0');
			SCAN14<=(others=>'0');
			FLGF0<='0';
			FLGE0<='0';
			MTEN<=(others=>'0');
			F_KBDT<=(others=>'1');
		elsif KCLK'event and KCLK='1' then
			MTEN<=MTEN(2 downto 0)&KBEN;
			if KBEN='1' then
				case KBDT is
					when X"AA" => F_KBDT<=X"EF";
					when X"F0" => FLGF0<='1'; F_KBDT<=X"EF";
					when X"E0" => FLGE0<='1'; F_KBDT<=X"EF";
					when others =>  F_KBDT(6 downto 0)<=KBDT(6 downto 0); F_KBDT(7)<=FLGE0 or KBDT(7); FLGE0<='0';
				end case;
			end if;

			if MTEN(3)='1' then
				case MTDT(7 downto 4) is								 
					when "0000" => SCAN00(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "0001" => SCAN01(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "0010" => SCAN02(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "0011" => SCAN03(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "0100" => SCAN04(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "0101" => SCAN05(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "0110" => SCAN06(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "0111" => SCAN07(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "1000" => SCAN08(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "1001" => SCAN09(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "1010" => SCAN10(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "1011" => SCAN11(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "1100" => SCAN12(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "1101" => SCAN13(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
					when "1110" => SCAN14(conv_integer(MTDT(2 downto 0)))<=not FLGF0;
					when others => SCAN14(conv_integer(MTDT(2 downto 0)))<=not FLGF0; FLGF0<='0';
				end case;
			end if;
		end if;
	end process;

	STROBE_L : for I in 0 to 7 generate
		SCANLL(I)<=SCAN00(I) or SCAN01(I) or SCAN02(I) or SCAN03(I) or SCAN04(I)
				  or SCAN05(I) or SCAN06(I) or SCAN07(I) or SCAN08(I) or SCAN09(I)
				  or SCAN10(I) or SCAN11(I) or SCAN12(I) or SCAN13(I) or SCAN14(I);
	end generate STROBE_L;

	--
	-- response from key access
	--
	KDATA<=(not SCANLL) when STALL='0' else
			 (not SCAN00) when STROBE="0000" else
			 (not SCAN01) when STROBE="0001" else
			 (not SCAN02) when STROBE="0010" else
			 (not SCAN03) when STROBE="0011" else
			 (not SCAN04) when STROBE="0100" else
			 (not SCAN05) when STROBE="0101" else
			 (not SCAN06) when STROBE="0110" else
			 (not SCAN07) when STROBE="0111" else
			 (not SCAN08) when STROBE="1000" else
			 (not SCAN09) when STROBE="1001" else
			 (not SCAN10) when STROBE="1010" else
			 (not SCAN11) when STROBE="1011" else
			 (not SCAN12) when STROBE="1100" else
			 (not SCAN13) when STROBE="1101" else (others=>'1');

	--
	-- NiosII access
	--
	RCSK_x<='0' when RADR(15 downto 8)="11000000" else '1';
	RWEN<=not(RWE_x or RCSK_x);
	RDO<=(others=>'0');

end Behavioral;
