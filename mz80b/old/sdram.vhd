--
-- sdram.vhd
--
-- SDRAM access module with self refresh and multi ports
-- for MZ-80C/80B on FPGA
--
-- Nibbles Lab. 2007-2014
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sdram is
	port (
		reset			: in std_logic;								-- Reset
		RSTOUT		: out std_logic;								-- Reset After Init. SDRAM
		CLOCK_50		: in std_logic;								-- Clock(50MHz)
		PCLK			: out std_logic;								-- NiosII Clock(20MHz)
		-- RAM access(port-A:Z80 bus)
		AA				: in std_logic_vector(22 downto 0);		-- Address
		DAI			: in std_logic_vector(7 downto 0);		-- Data Input(16bit)
		DAO			: out std_logic_vector(7 downto 0);		-- Data Output(16bit)
		CSA			: in std_logic;								-- Chip Select
		WEA			: in std_logic;								-- Write Enable
		PGA			: in std_logic;								-- Purge Cache
		--BEA			: in std_logic_vector(1 downto 0);		-- Byte Enable
		-- RAM access(port-B:Avalon bus bridge)
		AB				: in std_logic_vector(20 downto 0);		-- Address
		DBI			: in std_logic_vector(31 downto 0);		-- Data Input(32bit)
		DBO			: out std_logic_vector(31 downto 0);	-- Data Output(32bit)
		CSB			: in std_logic;								-- Chip Select
		WEB			: in std_logic;								-- Write Enable
		BEB			: in std_logic_vector(3 downto 0);		-- Byte Enable
		WQB			: out std_logic;								-- CPU Wait
		-- RAM access(port-C:Reserve)
		AC				: in std_logic_vector(21 downto 0);		-- Address
		DCI			: in std_logic_vector(15 downto 0);		-- Data Input(16bit)
		DCO			: out std_logic_vector(15 downto 0);	-- Data Output(16bit)
		CSC			: in std_logic;								-- Chip Select
		WEC			: in std_logic;								-- Write Enable
		BEC			: in std_logic_vector(1 downto 0);		-- Byte Enable
		-- RAM access(port-D:FD Buffer Access port)
		AD				: in std_logic_vector(22 downto 0);		-- Address
		DDI			: in std_logic_vector(7 downto 0);		-- Data Input(16bit)
		DDO			: out std_logic_vector(7 downto 0);	-- Data Output(16bit)
		CSD			: in std_logic;								-- Chip Select
		WED			: in std_logic;								-- Write Enable
		--BED			: in std_logic_vector(1 downto 0);		-- Byte Enable
		-- RAM access(port-E:Graphics Video Memory)
		AE				: in std_logic_vector(20 downto 0);		-- Address
		DEI			: in std_logic_vector(31 downto 0);		-- Data Input(32bit)
		DEO			: out std_logic_vector(31 downto 0);	-- Data Output(32bit)
		CSE			: in std_logic;								-- Chip Select
		WEE			: in std_logic;								-- Write Enable
		BEE			: in std_logic_vector(3 downto 0);		-- Byte Enable
		-- SDRAM signal
		MA				: out std_logic_vector(11 downto 0);	-- Address
		MBA0			: out std_logic;								-- Bank Address 0
		MBA1			: out std_logic;								-- Bank Address 1
		MDI			: in std_logic_vector(15 downto 0);		-- Data Input(16bit)
		MDO			: out std_logic_vector(15 downto 0);	-- Data Output(16bit)
		MDOE			: out std_logic;								-- Data Output Enable
		MLDQ			: out std_logic;								-- Lower Data Mask
		MUDQ			: out std_logic;								-- Upper Data Mask
		MCAS			: out std_logic;								-- Column Address Strobe
		MRAS			: out std_logic;								-- Raw Address Strobe
		MCS			: out std_logic;								-- Chip Select
		MWE			: out std_logic;								-- Write Enable
		MCKE			: out std_logic;								-- Clock Enable
		MCLK			: out std_logic								-- SDRAM Clock
	);
end sdram;

architecture rtl of sdram is

signal A : std_logic_vector(21 downto 0);
signal RA : std_logic_vector(21 downto 0);
signal RD : std_logic_vector(21 downto 0);
--signal DI : std_logic_vector(15 downto 0);
signal WCNT : std_logic_vector(2 downto 0);
signal CNT200 : std_logic;
signal CNT3 : std_logic_vector(2 downto 0);
--signal BUF    : std_logic_vector(7 downto 0);
signal CSMA   : std_logic;			-- Masked
signal CSMD   : std_logic;			-- Masked
signal PGAi   : std_logic;			-- Purge Flag
signal PGDi   : std_logic;			-- Purge Flag
signal CSAi   : std_logic;
signal CSAii  : std_logic_vector(3 downto 0);
signal CSBi   : std_logic;
signal CSBii  : std_logic_vector(3 downto 0);
signal CSCi   : std_logic;
signal CSCii  : std_logic_vector(3 downto 0);
signal CSDi   : std_logic;
signal CSDii  : std_logic_vector(3 downto 0);
signal CSDiii : std_logic_vector(3 downto 0);
signal CSEi   : std_logic;
signal CSEii  : std_logic_vector(3 downto 0);
signal REFCNT : std_logic_vector(10 downto 0);
signal PA : std_logic;
signal PB : std_logic;
signal PC : std_logic;
signal PD : std_logic;
signal PE : std_logic;
signal WB : std_logic;
signal DAIR : std_logic_vector(15 downto 0);
signal DAOR : std_logic_vector(15 downto 0);
signal DBIR : std_logic_vector(31 downto 0);
signal DCIR : std_logic_vector(15 downto 0);
signal DDIR : std_logic_vector(15 downto 0);
signal DDOR : std_logic_vector(15 downto 0);
signal DEIR : std_logic_vector(31 downto 0);
signal WAITB : std_logic;
signal RDEN : std_logic;
signal WREN : std_logic;
signal UBEN : std_logic;
signal LBEN : std_logic;
signal UBEN2 : std_logic;
signal LBEN2 : std_logic;
signal RWAIT : std_logic;
signal MEMCLK : std_logic;
signal SCLK : std_logic;
--
-- State Machine
--
signal CUR : std_logic_vector(5 downto 0);						-- Current Status
signal NXT : std_logic_vector(5 downto 0);						-- Next Status
constant IWAIT  : std_logic_vector(5 downto 0) := "000000";	-- 200us Wait
constant IPALL  : std_logic_vector(5 downto 0) := "000001";	-- All Bank Precharge
constant IDLY1  : std_logic_vector(5 downto 0) := "000010";	-- Initial Delay 1
constant IRFSH  : std_logic_vector(5 downto 0) := "000011";	-- Auto Refresh
constant IDLY2  : std_logic_vector(5 downto 0) := "000100";	-- Initial Delay 2
constant IDLY3  : std_logic_vector(5 downto 0) := "000101";	-- Initial Delay 3
constant IDLY4  : std_logic_vector(5 downto 0) := "000110";	-- Initial Delay 4
constant IDLY5  : std_logic_vector(5 downto 0) := "000111";	-- Initial Delay 5
constant IDLY6  : std_logic_vector(5 downto 0) := "001000";	-- Initial Delay 6
constant IMODE  : std_logic_vector(5 downto 0) := "001001";	-- Mode Register Setting
constant RACT   : std_logic_vector(5 downto 0) := "001010";	-- Read Activate
constant RDLY1  : std_logic_vector(5 downto 0) := "001011";	-- Read Delay 1
constant READ   : std_logic_vector(5 downto 0) := "001100";	-- Read
constant READ2  : std_logic_vector(5 downto 0) := "001101";	-- Read 2nd word
constant RDLY2  : std_logic_vector(5 downto 0) := "001110";	-- Read Delay 2
constant RDLY3  : std_logic_vector(5 downto 0) := "001111";	-- Read Delay 3
constant RPRE   : std_logic_vector(5 downto 0) := "010000";	-- Precharge
constant RDLY4  : std_logic_vector(5 downto 0) := "010001";	-- Read Delay 4
constant HALT   : std_logic_vector(5 downto 0) := "010010";	--	Waiting
constant WACT   : std_logic_vector(5 downto 0) := "010011";	-- Write Activate
constant WDLY1  : std_logic_vector(5 downto 0) := "010100";	-- Write Delay 1
constant WRIT   : std_logic_vector(5 downto 0) := "010101";	-- Write
constant WRIT2  : std_logic_vector(5 downto 0) := "010110";	-- Write 2nd word
constant WDLY2  : std_logic_vector(5 downto 0) := "010111";	-- Write Delay 2
constant WDLY3  : std_logic_vector(5 downto 0) := "011000";	-- Write Delay 3
constant WPRE   : std_logic_vector(5 downto 0) := "011001";	-- Precharge
constant FRFSH  : std_logic_vector(5 downto 0) := "011010";	-- Auto Refresh
constant FDLY1  : std_logic_vector(5 downto 0) := "011011";	-- Refresh Delay 1
constant FDLY2  : std_logic_vector(5 downto 0) := "011100";	-- Refresh Delay 2
constant FDLY3  : std_logic_vector(5 downto 0) := "011101";	-- Refresh Delay 3
constant FDLY4  : std_logic_vector(5 downto 0) := "011110";	-- Refresh Delay 4
--
-- Components
--
component pll100
	PORT
	(
		inclk0	: IN STD_LOGIC  := '0';
		c0			: OUT STD_LOGIC ;
		c1			: OUT STD_LOGIC ;
		c2			: OUT STD_LOGIC ;
		c3			: OUT STD_LOGIC 
	);
end component;

begin

	--
	-- Instantiation
	--
	RCKGEN0 : pll100 PORT MAP (
		inclk0	=> CLOCK_50,	-- Master Clock (50MHz) ... input
		c0	 => MEMCLK,				-- SDRAM Controler Clock (100MHz) ... internal use
		c1	 => MCLK,				-- SDRAM Clock (100MHz:-60deg) ... output
		c2	 => PCLK,				-- Nios II Clock (20MHz) ... output
		c3	 => SCLK					-- Slow Clock (31.25kHz) ... internal use/output
	);

	--
	-- Seqence control
	--
	process( reset, MEMCLK ) begin
		if reset='0' then
			CUR<=IWAIT;			-- Start at Initial-Waiting(200us)
		elsif MEMCLK'event and MEMCLK='1' then
			CUR<=NXT;			-- Move to Next State
		end if;
	end process;

	--
	-- Arbitoration and Data Output
	--
	process( reset, MEMCLK ) begin
		if reset='0' then
			CSAi<='0';
			CSBi<='0';
			CSCi<='0';
			CSDi<='0';
			CSEi<='0';
			CSAii<=(others=>'1');
			CSBii<=(others=>'1');
			CSCii<=(others=>'1');
			CSDii<=(others=>'1');
			CSEii<=(others=>'1');
			PA<='0';
			PB<='0';
			PC<='0';
			PD<='0';
			PE<='0';
			WAITB<='1';
--			WAITD<='1';
			RDEN<='0';
			WREN<='0';
			UBEN<='1';
			LBEN<='1';
			UBEN2<='1';
			LBEN2<='1';
			PGAi<='0';
		elsif MEMCLK'event and MEMCLK='1' then
			--
			-- Sense CS
			--
			CSAii<=CSAii(2 downto 0)&CSMA;
			if CSAii(1 downto 0)="10" then
				CSAi<='1';
				DAIR<=DAI&DAI;
			end if;
			CSBii<=CSBii(2 downto 0)&CSB;
			if CSBii="1110" then
				WAITB<='0';
			end if;
			if CSBii(1 downto 0)="10" then
				CSBi<='1';
				DBIR<=DBI;
			end if;
			CSCii<=CSCii(2 downto 0)&CSC;
			if CSCii(1 downto 0)="10" then
				CSCi<='1';
				DCIR<=DCI;
			end if;
			CSDii<=CSDii(2 downto 0)&CSMD;
			if CSDii(1 downto 0)="10" then
				CSDi<='1';
				DDIR(15 downto 8)<=DDI;
			end if;
			CSEii<=CSEii(2 downto 0)&CSE;
			if CSEii(1 downto 0)="10" then
				CSEi<='1';
				DEIR<=DEI;
			end if;

			CSDiii<=CSDiii(2 downto 0)&CSD;
			if CSDiii(1 downto 0)="10" and AD(0)='0' then
				DDIR(7 downto 0)<=DDI;
			end if;

			--
			-- Select Response Port
			--
			if CUR=HALT then
				if CSAi='1' and PB='0' and PC='0' and PD='0' and PE='0' then
					PA<='1';
					RDEN<=WEA;
					WREN<=not WEA;
					UBEN<=(not AA(0)) and (not WEA);
					LBEN<=AA(0) and (not WEA);
					UBEN2<='1';
					LBEN2<='1';
				elsif CSCi='1' and PA='0' and PB='0' and PD='0' and PE='0' then
					PC<='1';
					RDEN<=WEC;
					WREN<=not WEC;
					UBEN<=BEC(1);
					LBEN<=BEC(0);
					UBEN2<='1';
					LBEN2<='1';
				elsif CSEi='1' and PA='0' and PB='0' and PC='0' and PD='0' then
					PE<='1';
					RDEN<=WEE;
					WREN<=not WEE;
					UBEN2<=BEE(3);
					LBEN2<=BEE(2);
					UBEN<=BEE(1);
					LBEN<=BEE(0);
				elsif CSDi='1' and PA='0' and PB='0' and PC='0' and PE='0' then
					PD<='1';
					RDEN<=WED;
					WREN<=not WED;
					UBEN<='0';
					LBEN<='0';
					UBEN2<='1';
					LBEN2<='1';
				elsif CSBi='1' and PA='0' and PC='0' and PD='0' and PE='0' then
					PB<='1';
					RDEN<=WEB;
					WREN<=not WEB;
					UBEN2<=BEB(3);
					LBEN2<=BEB(2);
					UBEN<=BEB(1);
					LBEN<=BEB(0);
				else
					PA<='0'; PB<='0'; PC<='0'; PD<='0'; PE<='0';
					RDEN<='0';
					WREN<='0';
					UBEN<='1';
					LBEN<='1';
					UBEN2<='1';
					LBEN2<='1';
				end if;
			end if;

			--
			-- Deselect Port
			--
			if CUR=RPRE or CUR=WPRE then
				if PA='1' then
					PA<='0';
					RDEN<='0';
					WREN<='0';
					CSAi<='0';
				end if;
				if PC='1' then
					PC<='0';
					RDEN<='0';
					WREN<='0';
					CSCi<='0';
				end if;
				if PD='1' then
					PD<='0';
					RDEN<='0';
					WREN<='0';
					CSDi<='0';
				end if;
			end if;
			if CUR=RDLY4 or CUR=WPRE then
				if PB='1' then
					PB<='0';
					RDEN<='0';
					WREN<='0';
					CSBi<='0';
					WAITB<='1';
				end if;
				if PE='1' then
					PE<='0';
					RDEN<='0';
					WREN<='0';
					CSEi<='0';
				end if;
			end if;

			--
			-- Data Output for Processor
			--
			if CUR=RPRE then		-- Ready for Data Output
				if PA='1' then
					DAOR<=MDI;
					RA<=A;
					PGAi<='1';
				elsif PB='1' then
					DBO(15 downto 0)<=MDI;
				elsif PC='1' then
					DCO<=MDI;
				elsif PD='1' then
					DDOR<=MDI;
					RD<=A;
					PGDi<='1';
				elsif PE='1' then
					DEO(15 downto 0)<=MDI;
				end if;
			end if;
			if CUR=RDLY4 then
				if PB='1' then
					DBO(31 downto 16)<=MDI;
				elsif PE='1' then
					DEO(31 downto 16)<=MDI;
				end if;
			end if;

			--
			-- Data Output for SDRAM
			--
			if CUR=WACT then
				if PA='1' then
					MDO<=DAIR;
				elsif PB='1' then
					MDO<=DBIR(15 downto 0);
				elsif PC='1' then
					MDO<=DCIR;
				elsif PD='1' then
					MDO<=DDIR;
				elsif PE='1' then
					MDO<=DEIR(15 downto 0);
				end if;
			elsif CUR=WRIT then
				if PB='1' then
					MDO<=DBIR(31 downto 16);
				elsif PE='1' then
					MDO<=DEIR(31 downto 16);
				end if;
			end if;

			--
			-- Purge Flag
			--
			if PGA='0' then
				PGAi<='0';
			end if;
		end if;
	end process;

	--
	-- Wait Control for NiosII
	--
	WQB<=CSB or WAITB;

	--
	-- Wait after Reset
	--
	process( reset, SCLK ) begin			-- SCLK=31.25kHz
		if reset='0' then
			WCNT<=(others=>'0');
			CNT200<='0';
		elsif SCLK'event and SCLK='1' then
			if WCNT="110" then
				CNT200<='1';
			else
				WCNT<=WCNT+1;
			end if;
		end if;
	end process;

	--
	-- Refresh Times Counter for Initialize (8 times)
	--
	process( reset, MEMCLK ) begin
		if reset='0' then
			CNT3<=(others=>'0');
		elsif MEMCLK'event and MEMCLK='1' then
			if CUR=IWAIT then
				CNT3<=(others=>'0');
			elsif CUR=IDLY3 then
				CNT3<=CNT3+1;
			end if;
		end if;
	end process;

	--
	-- Refresh Cycle Counter
	--
	process( reset, MEMCLK ) begin
		if reset='0' then
			REFCNT<=(others=>'0');
		elsif MEMCLK'event and MEMCLK='1' then
			if CUR=FRFSH then				-- Enter Refresh Command
				REFCNT<=(others=>'0');
			else
				REFCNT<=REFCNT+'1';
			end if;
		end if;
	end process;

	--
	-- Sequencer
	--
	process( CUR, CNT200, CNT3, REFCNT, RDEN, WREN, PA, PB, PC, PD, PE ) begin
		case CUR is
			-- Initialize
			when IWAIT =>	-- 200us Wait
				if CNT200='1' then
					NXT<=IPALL;
				else
					NXT<=IWAIT;
				end if;
			when IPALL =>	-- All Bank Precharge
				NXT<=IDLY1;
			when IDLY1 =>	-- Initial Delay 1
				NXT<=IRFSH;
			when IRFSH =>	-- Auto Refresh
				NXT<=IDLY2;
			when IDLY2 =>	-- Initial Delay 2
				NXT<=IDLY3;
			when IDLY3 =>	-- Initial Delay 2
				NXT<=IDLY4;
			when IDLY4 =>	-- Initial Delay 2
				NXT<=IDLY5;
			when IDLY5 =>	-- Initial Delay 2
				NXT<=IDLY6;
			when IDLY6 =>	-- Initial Delay 3
				if CNT3="111" then
					NXT<=IMODE;
				else
					NXT<=IDLY1;
				end if;
			when IMODE =>	-- Mode Register Setting
				NXT<=HALT;

			-- Read
			when RACT  =>	-- Read Activate
				NXT<=RDLY1;
			when RDLY1 =>	-- Read Delay 1
				NXT<=READ;
			when READ   =>	-- Read once or 1st word
				if PB='1' or PE='1' then
					NXT<=READ2;
				else
					NXT<=RDLY2;
				end if;
			when READ2|RDLY2  =>	-- Read 2nd word / Read Delay 2
				NXT<=RDLY3;
			when RDLY3 =>	-- Read Delay 3
				NXT<=RPRE;
			when RPRE =>	-- Precharge
				if PB='1' or PE='1' then
					NXT<=RDLY4;
				else
					NXT<=HALT;
				end if;
			when RDLY4 =>	-- Read Delay 4
				NXT<=HALT;

			-- Waiting
			when HALT  =>	--	Waiting
				if REFCNT>"11000000100" then	-- Over 1540 Counts
					NXT<=FRFSH;
				elsif RDEN='1' then
					NXT<=RACT;
				elsif WREN='1' then
					NXT<=WACT;
				else
					NXT<=HALT;
				end if;

			-- Write
			when WACT  =>	-- Write Activate
				NXT<=WDLY1;
			when WDLY1 =>	-- Write Delay 1
				NXT<=WRIT;
			when WRIT   =>	-- Write once or 1st word
				if PB='1' or PE='1' then
					NXT<=WRIT2;
				else
					NXT<=WDLY2;
				end if;
			when WRIT2|WDLY2  =>	-- Write 2nd word / Write Delay 2
				NXT<=WDLY3;
			when WDLY3 =>	-- Write Delay 3
				NXT<=WPRE;
			when WPRE =>	-- Precharge
				NXT<=HALT;

			-- Refresh
			when FRFSH =>	-- Auto Refresh
				NXT<=FDLY1;
			when FDLY1 =>	-- Refresh Delay 1
				NXT<=FDLY2;
			when FDLY2 =>	-- Refresh Delay 2
				NXT<=FDLY3;
			when FDLY3 =>	-- Refresh Delay 3
				NXT<=FDLY4;
			when FDLY4 =>	-- Refresh Delay 4
				NXT<=HALT;

			when others =>
				NXT<=HALT;
		end case;
	end process;

	--
	-- Command operation
	--
	-- MA(11 downto 0)
	process( CUR, A ) begin
		case CUR is
			when IMODE =>		-- Mode Register Setting
				MA<="0010" & "0" & "011" & "0" & "000";	-- w-single,CL=3,WT=0(seq),BL=1
				--MA<="0010" & "0" & "010" & "0" & "000";	-- w-single,CL=2,WT=0(seq),BL=1
				--MA<="0010" & "0" & "010" & "0" & "001";	-- w-single,CL=2,WT=0(seq),BL=2
			when RACT|WACT =>	-- Read/Write Activate
				MA<=A(19 downto 8);
			when IPALL =>		-- All Bank Precharge
				MA<="010000000000";
			when READ|WRIT =>			-- Read/Write
				--MA(11 downto 8)<="0100";	-- auto precharge
				MA(11 downto 8)<="0000";	-- manual precharge
				MA(7 downto 0)<=A(7 downto 0);
			when READ2|WRIT2 =>			-- Read/Write 2nd word
				--MA(11 downto 8)<="0100";	-- auto precharge
				MA(11 downto 8)<="0000";	-- manual precharge
				MA(7 downto 0)<=A(7 downto 1)&'1';
--			when RPRE|WPRE =>			-- Select Bank Precharge
--				MA<="000000000000";
			when others =>
				MA<=(others=>'0');
		end case;
	end process;
	-- LBEN/UBEN
	process( CUR, LBEN, UBEN, LBEN2, UBEN2 ) begin
		case CUR is
			when READ2|RDLY2|WRIT =>	-- Read 2nd word/Read delay 2/Write
				MLDQ<=LBEN;
				MUDQ<=UBEN;
			when RDLY3|WRIT2 =>			-- Read delay 3/Write 2nd word
				MLDQ<=LBEN2;
				MUDQ<=UBEN2;
			when others =>
				MLDQ<='1';
				MUDQ<='1';
		end case;
	end process;
	-- MDOE
	process( CUR ) begin
		case CUR is
			when WRIT =>			-- Write
				MDOE<='1';
			when WRIT2 =>			-- Write 2nd word
				MDOE<='1';
			when others =>
				MDOE<='0';
		end case;
	end process;
	-- MWE
	process( CUR ) begin
		case CUR is
			when IMODE =>		-- Mode Register Setting
				MWE<='0';
			when IPALL =>		-- All Bank Precharge
				MWE<='0';
			when WRIT =>			-- Write
				MWE<='0';
			when WRIT2 =>			-- Write 2nd word
				MWE<='0';
			when RPRE|WPRE =>			-- Select Bank Precharge
				MWE<='0';
			when others =>
				MWE<='1';
		end case;
	end process;
	-- MCS
	process( CUR ) begin
		case CUR is
			when IMODE =>		-- Mode Register Setting
				MCS<='0';
			when RACT|WACT =>	-- Read/Write Activate
				MCS<='0';
			when IPALL =>		-- All Bank Precharge
				MCS<='0';
			when READ =>			-- Read
				MCS<='0';
			when READ2 =>			-- Read 2nd word
				MCS<='0';
			when WRIT =>			-- Write
				MCS<='0';
			when WRIT2 =>			-- Write 2nd word
				MCS<='0';
			when IRFSH|FRFSH =>		-- auto refresh
				MCS<='0';
			when RPRE|WPRE =>			-- Select Bank Precharge
				MCS<='0';
			when others =>
				MCS<='1';
		end case;
	end process;
	-- MRAS/MCAS
	process( CUR ) begin
		case CUR is
			when IMODE =>		-- Mode Register Setting
				MRAS<='0';
				MCAS<='0';
			when RACT|WACT =>	-- Read/Write Activate
				MRAS<='0';
				MCAS<='1';
			when IPALL =>		-- All Bank Precharge
				MRAS<='0';
				MCAS<='1';
			when READ =>			-- Read
				MRAS<='1';
				MCAS<='0';
			when READ2 =>			-- Read 2nd word
				MRAS<='1';
				MCAS<='0';
			when WRIT =>			-- Write
				MRAS<='1';
				MCAS<='0';
			when WRIT2 =>			-- Write 2nd word
				MRAS<='1';
				MCAS<='0';
			when IRFSH|FRFSH =>		-- auto refresh
				MRAS<='0';
				MCAS<='0';
			when RPRE|WPRE =>			-- Select Bank Precharge
				MRAS<='0';
				MCAS<='1';
			when others =>
				MRAS<='1';
				MCAS<='1';
		end case;
	end process;

	--
	-- Reset Control
	--
	process( reset, MEMCLK ) begin
		if reset='0' then
			RSTOUT<='0';
		elsif MEMCLK'event and MEMCLK='1' then
			if CUR=HALT then
				RSTOUT<='1';
			end if;
		end if;
	end process;

	--
	-- SDRAM ports(Fixed Signals)
	--
	MCKE<='1';
	MBA0<=A(20);
	MBA1<=A(21);

	--
	-- Ports select
	--
	A <=AA(22 downto 1) when PA='1' else
		 AB&'0'			  when PB='1' else
		 AC				  when PC='1' else
		 AD(22 downto 1) when PD='1' else
		 AE&'0'			  when PE='1' else (others=>'0');
	DAO<=DAOR(15 downto 8) when AA(0)='1' else DAOR(7 downto 0);
	CSMA<=(CSA or WEA) when RA=AA(22 downto 1) and PGAi='1' else CSA;
	DDO<=DDOR(15 downto 8) when AD(0)='1' else DDOR(7 downto 0);
	CSMD<=CSD when (AD(0)='0' and WED='1') or (AD(0)='1' and WED='0') else '1';
--	process(RA, AA(22 downto 1), PGAi, CSA, WEA) begin
--		if RA=AA(22 downto 1) then
--			if PGAi='0' then
--				CSMA<=CSA;
--			else
--				if WEA='0' then
--					CSMA<=CSA;
--				else
--					CSMA<='1';
--				end if;
--			end if;
--		else
--			CSMA<=CSA;
--		end if;
--	end process;

end rtl;
