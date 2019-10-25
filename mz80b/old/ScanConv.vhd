--
-- ScanConv.vhd
--
-- Up Scan Converter (15.6kHz->VGA)
-- for MZ-80B on FPGA
--
-- Nibbles Lab. 2013
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ScanConv is
	Port (
		CK16M : in STD_LOGIC;		-- MZ Dot Clock
		CK25M : in STD_LOGIC;		-- VGA Dot Clock
		RI    : in STD_LOGIC;		-- Red Input
		GI    : in STD_LOGIC;		-- Green Input
		BI    : in STD_LOGIC;		-- Blue Input
		HSI   : in STD_LOGIC;		-- H-Sync Input(MZ,15.6kHz)
		RO    : out STD_LOGIC;		-- Red Output
		GO    : out STD_LOGIC;		-- Green Output
		BO    : out STD_LOGIC;		-- Blue Output
		HSO   : out STD_LOGIC);		-- H-Sync Output(VGA, 31kHz)
end ScanConv;

architecture RTL of ScanConv is

--
-- Signals
--
signal CTR12M5 : std_logic_vector(10 downto 0);		-- 
--signal CLK12M5 : std_logic;								-- Divider for VGA Sync Signal
signal TS : std_logic_vector(9 downto 0);				-- Half of Horizontal
signal OCTR : std_logic_vector(9 downto 0);			-- Buffer Output Pointer
signal ICTR : std_logic_vector(9 downto 0);			-- Buffer Input Pointer
signal Hi : std_logic_vector(5 downto 0);				-- Shift Register for H-Sync Detect(VGA)
signal Si : std_logic_vector(5 downto 0);				-- Shift Register for H-Sync Detect(15.6kHz)
signal DO : std_logic_vector(2 downto 0);

--
-- Components
--
component linebuf
	PORT
	(
		data			: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		rdaddress	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		rdclock		: IN STD_LOGIC ;
		wraddress	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		wrclock		: IN STD_LOGIC  := '1';
		wren			: IN STD_LOGIC  := '0';
		q				: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
end component;

begin

	--
	-- Instantiation
	--
	SBUF : linebuf PORT MAP (
		data	 		=> RI&GI&BI,		-- Input RGB
		rdaddress	=> OCTR,				-- Buffer Output Counter
		rdclock	 	=> CK25M,			-- Dot Clock(VGA)
		wraddress	=> ICTR,				-- Buffer Input Counter
		wrclock	 	=> CK16M,			-- Dot Clock(15.6kHz)
		wren	 		=> '1',				-- Write only
		q	 			=> DO					-- Output RGB
	);

	--
	-- Buffer Input
	--
	process( CK16M ) begin
		if CK16M'event and CK16M='1' then

			-- Filtering HSI
			Si<=Si(4 downto 0)&HSI;

			-- Counter start
			if Si="111000" then
				ICTR<="1110000100";	-- X"3B8";
			else
				ICTR<=ICTR+'1';
			end if;

		end if;
	end process;

	--
	-- Buffer and Signal Output
	--
	process( CK25M ) begin
		if CK25M'event and CK25M='1' then

			-- Filtering HSI
			Hi<=Hi(4 downto 0)&HSI;

			-- Detect HSYNC
			if Hi="111000" then
				CTR12M5<=(others=>'0');
				TS<=CTR12M5(10 downto 1);	-- Half of Horizontal
				OCTR<=(others=>'0');
			elsif OCTR=TS then
				OCTR<=(others=>'0');
				CTR12M5<=CTR12M5+'1';
			else
				OCTR<=OCTR+'1';
				CTR12M5<=CTR12M5+'1';
			end if;

			-- Horizontal Sync genarate
			if OCTR=0 then
				HSO<='0';
			elsif OCTR=96 then
				HSO<='1';
			end if;

		end if;
	end process;

	--
	-- Output
	--
	RO<=DO(2);
	GO<=DO(1);
	BO<=DO(0);

end RTL;

