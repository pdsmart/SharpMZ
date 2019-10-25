--
-- mz80b.vhd
--
-- SHARP MZ-80B/2000 compatible logic, top module
-- for Altera DE0
--
-- Nibbles Lab. 2013-2014
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mz80b is
  port(
		--------------------				Clock Input					 	----------------------	 
		CLOCK_50		: in std_logic;								--	50 MHz
		CLOCK_50_2	: in std_logic;								--	50 MHz
		--------------------				Push Button						----------------------------
		BUTTON		: in std_logic_vector(2 downto 0);		--	Pushbutton[2:0]
		--------------------				DPDT Switch						----------------------------
		SW				: in std_logic_vector(9 downto 0);		--	Toggle Switch[9:0]
		--------------------				7-SEG Dispaly					----------------------------
		HEX0_D		: out std_logic_vector(6 downto 0);		--	Seven Segment Digit 0
		HEX0_DP		: out std_logic;								--	Seven Segment Digit DP 0
		HEX1_D		: out std_logic_vector(6 downto 0);		--	Seven Segment Digit 1
		HEX1_DP		: out std_logic;								--	Seven Segment Digit DP 1
		HEX2_D		: out std_logic_vector(6 downto 0);		--	Seven Segment Digit 2
		HEX2_DP		: out std_logic;								--	Seven Segment Digit DP 2
		HEX3_D		: out std_logic_vector(6 downto 0);		--	Seven Segment Digit 3
		HEX3_DP		: out std_logic;								--	Seven Segment Digit DP 3
		--------------------						LED						----------------------------
		LEDG			: out std_logic_vector(9 downto 0);		--	LED Green[9:0]
		--------------------						UART						----------------------------
		UART_TXD		: out std_logic;								--	UART Transmitter
		UART_RXD		: in std_logic;								--	UART Receiver
		UART_CTS		: in std_logic;								--	UART Clear To Send
		UART_RTS		: out std_logic;								--	UART Request To Send
		--------------------				SDRAM Interface				----------------------------
		DRAM_DQ		: inout std_logic_vector(15 downto 0);	--	SDRAM Data bus 16 Bits
		DRAM_ADDR	: out std_logic_vector(12 downto 0);	--	SDRAM Address bus 13 Bits
		DRAM_LDQM	: out std_logic;								--	SDRAM Low-byte Data Mask 
		DRAM_UDQM	: out std_logic;								--	SDRAM High-byte Data Mask
		DRAM_WE_N	: out std_logic;								--	SDRAM Write Enable
		DRAM_CAS_N	: out std_logic;								--	SDRAM Column Address Strobe
		DRAM_RAS_N	: out std_logic;								--	SDRAM Row Address Strobe
		DRAM_CS_N	: out std_logic;								--	SDRAM Chip Select
		DRAM_BA_0	: out std_logic;								--	SDRAM Bank Address 0
		DRAM_BA_1	: out std_logic;								--	SDRAM Bank Address 1
		DRAM_CLK		: out std_logic;								--	SDRAM Clock
		DRAM_CKE		: out std_logic;								--	SDRAM Clock Enable
		--------------------				Flash Interface				----------------------------
		FL_DQ			: inout std_logic_vector(15 downto 0);	--	FLASH Data bus 16 Bits
--		FL_DQ15_AM1	: out std_logic;								--	FLASH Data bus Bit 15 or Address A-1
		FL_ADDR		: out std_logic_vector(21 downto 0);	--	FLASH Address bus 22 Bits
		FL_WE_N		: out std_logic;								--	FLASH Write Enable
		FL_RST_N		: out std_logic;								--	FLASH Reset
		FL_OE_N		: out std_logic;								--	FLASH Output Enable
		FL_CE_N		: out std_logic;								--	FLASH Chip Enable
		FL_WP_N		: out std_logic;								--	FLASH Hardware Write Protect
		FL_BYTE_N	: out std_logic;								--	FLASH Selects 8/16-bit mode
		FL_RY			: out std_logic;								--	FLASH Ready/Busy
		--------------------				LCD Module 16X2				----------------------------
		LCD_BLON		: out std_logic;								--	LCD Back Light ON/OFF
		LCD_RW		: out std_logic;								--	LCD Read/Write Select, 0 = Write, 1 = Read
		LCD_EN		: out std_logic;								--	LCD Enable
		LCD_RS		: out std_logic;								--	LCD Command/Data Select, 0 = Command, 1 = Data
		LCD_DATA		: out std_logic_vector(7 downto 0);		--	LCD Data bus 8 bits
		--------------------				SD_Card Interface				----------------------------
		SD_DAT0		: inout std_logic;							--	SD Card Data 0 (DO)
		SD_DAT3		: inout std_logic;							--	SD Card Data 3 (CS)
		SD_CMD		: out std_logic;								--	SD Card Command Signal (DI)
		SD_CLK		: out std_logic;								--	SD Card Clock (SCLK)
		SD_WP_N		: in std_logic;								--	SD Card Write Protect
		--------------------						PS2						----------------------------
		PS2_KBDAT	: in std_logic;								--	PS2 Keyboard Data
		PS2_KBCLK	: in std_logic;								--	PS2 Keyboard Clock
		PS2_MSDAT	: in std_logic;								--	PS2 Mouse Data
		PS2_MSCLK	: in std_logic;								--	PS2 Mouse Clock
		--------------------						VGA						----------------------------
		VGA_HS		: out std_logic;								--	VGA H_SYNC
		VGA_VS		: out std_logic;								--	VGA V_SYNC
		VGA_R			: out std_logic_vector(3 downto 0);   	--	VGA Red[3:0]
		VGA_G			: out std_logic_vector(3 downto 0);	 	--	VGA Green[3:0]
		VGA_B			: out std_logic_vector(3 downto 0);  	--	VGA Blue[3:0]
		--------------------						GPIO						------------------------------
		GPIO0_CLKIN	: in std_logic_vector(1 downto 0);		--	GPIO Connection 0 Clock In Bus
		GPIO0_CLKOUT: out std_logic_vector(1 downto 0);		--	GPIO Connection 0 Clock Out Bus
		GPIO0_D		: out std_logic_vector(31 downto 0);	--	GPIO Connection 0 Data Bus
		GPIO1_CLKIN	: in std_logic_vector(1 downto 0);		--	GPIO Connection 1 Clock In Bus
		GPIO1_CLKOUT: out std_logic_vector(1 downto 0);		--	GPIO Connection 1 Clock Out Bus
		GPIO1_D		: inout std_logic_vector(31 downto 0)	--	GPIO Connection 1 Data Bus
  );
end mz80b;

architecture rtl of mz80b is

--
-- Z80
--
signal ZADR : std_logic_vector(22 downto 0);
signal ZDI : std_logic_vector(7 downto 0);
signal ZDO : std_logic_vector(7 downto 0);
signal ZCS_x : std_logic;
signal ZWR_x : std_logic;
signal ZPG_x : std_logic;
--
-- NiosII
--
signal RRST_x : std_logic;								-- NiosII Reset
signal RCLK : std_logic;								-- NiosII Clock
signal RADR : std_logic_vector(15 downto 0);		-- NiosII Address Bus
signal RCS_x : std_logic;								-- NiosII Read Signal
signal RWE_x : std_logic;								-- NiosII Write Signal
signal RDI : std_logic_vector(7 downto 0);		-- NiosII Data Bus(in)
signal RDO : std_logic_vector(7 downto 0);		-- NiosII Data Bus(out)
signal INTL : std_logic;								-- Interrupt Line
signal MADR : std_logic_vector(20 downto 0);		-- Address
signal MDI : std_logic_vector(31 downto 0);		-- Data Input(32bit)
signal MDO : std_logic_vector(31 downto 0);		-- Data Output(32bit)
signal MCS_x : std_logic;								-- Chip Select
signal MWE_x : std_logic;								-- Write Enable
signal MBEN_x : std_logic_vector(3 downto 0);	-- Byte Enable
signal MWRQ_x : std_logic;								-- CPU Wait
--
-- Clock, Reset
--
signal PCLK : std_logic;
signal URST : std_logic;
signal MRST : std_logic;
signal ARST : std_logic;
--
-- FD Buffer
--
signal BCS_x : std_logic;								-- RAM Request
signal BADR : std_logic_vector(22 downto 0);		-- RAM Address
signal BWR_x : std_logic;				 				-- RAM Write Signal
signal BDI : std_logic_vector(7 downto 0);		-- Data Bus Input from RAM
signal BDO : std_logic_vector(7 downto 0);		-- Data Bus Output to RAM
--
-- GRAM
--
signal GADR : std_logic_vector(20 downto 0);
signal GCS_x : std_logic;
signal GWR_x : std_logic;
signal GBE_x : std_logic_vector(3 downto 0);
signal GDI : std_logic_vector(31 downto 0);
signal GDO : std_logic_vector(31 downto 0);
--
-- SDRAM
--
signal SDRAMDO : std_logic_vector(15 downto 0);
signal SDRAMDOE : std_logic;
--
-- MMC/SD CARD
--
signal SD_CS : std_logic;
signal SD_DEN : std_logic_vector(1 downto 0);
signal SD_DO : std_logic;
--
-- Flash Memory
--
signal FL_ADDR0 : std_logic_vector(21 downto 0);
signal FL_WE_Ni : std_logic_vector(0 downto 0);
signal FL_OE_Ni : std_logic_vector(0 downto 0);
signal FL_CE_Ni : std_logic_vector(0 downto 0);
--
-- Misc
--
signal T_LEDG : std_logic_vector(9 downto 0);
--signal ZLEDG : std_logic_vector(9 downto 0);
signal CNT1 : std_logic_vector(24 downto 0);
signal CNT2 : std_logic_vector(24 downto 0);

--
-- Components
--
component mz80b_core
	port(
		-- Z80 Memory Bus
		ZADR			: out std_logic_vector(22 downto 0);
		ZDI			: in std_logic_vector(7 downto 0);
		ZDO			: out std_logic_vector(7 downto 0);
		ZCS_x			: out std_logic;
		ZWR_x			: out std_logic;
		ZPG_x	  		: out std_logic;
		-- NiosII Access
		RRST_x		: in std_logic;								-- NiosII Reset
		RCLK			: in std_logic;								-- NiosII Clock
		RADR			: in std_logic_vector(15 downto 0);		-- NiosII Address Bus
		RCS_x			: in std_logic;								-- NiosII Read Signal
		RWE_x			: in std_logic;								-- NiosII Write Signal
		RDI			: in std_logic_vector(7 downto 0);		-- NiosII Data Bus(in)
		RDO			: out std_logic_vector(7 downto 0);		-- NiosII Data Bus(out)
		INTL			: out std_logic;								-- Interrupt Line
		-- Graphic VRAM Access
		GCS_x			: out std_logic;								-- GRAM Request
		GADR			: out std_logic_vector(20 downto 0);	-- GRAM Address
		GWR_x			: out std_logic;				 				-- GRAM Write Signal
		GBE_x			: out std_logic_vector(3 downto 0);		-- GRAM Byte Enable
		GDI			: in std_logic_vector(31 downto 0);		-- Data Bus Input from GRAM
		GDO			: out std_logic_vector(31 downto 0);	-- Data Bus Output to GRAM
		-- FD Buffer RAM I/F
		BCS_x 		: out std_logic;								-- RAM Request
		BADR 		 	: out std_logic_vector(22 downto 0);	-- RAM Address
		BWR_x 		: out std_logic;				 				-- RAM Write Signal
		BDI			: in std_logic_vector(7 downto 0);		-- Data Bus Input from RAM
		BDO			: out std_logic_vector(7 downto 0);		-- Data Bus Output to RAM
		-- Resets
		URST_x		: out std_logic;							-- Universal Reset
		MRST_x		: in std_logic;							-- Reset after SDRAM init.
		ARST_x		: out std_logic;							-- All Reset
		-- Clock Input	 
		CLOCK_50		: in std_logic;							--	50 MHz
		-- Push Button
		BUTTON		: in std_logic_vector(2 downto 0);	--	Pushbutton[2:0]
		-- Switch
		SW				: in std_logic_vector(9 downto 0);	--	Toggle Switch[9:0]
		-- 7-SEG Dispaly
		HEX0_D		: out std_logic_vector(6 downto 0);	--	Seven Segment Digit 0
		HEX0_DP		: out std_logic;							--	Seven Segment Digit DP 0
		HEX1_D		: out std_logic_vector(6 downto 0);	--	Seven Segment Digit 1
		HEX1_DP		: out std_logic;							--	Seven Segment Digit DP 1
		HEX2_D		: out std_logic_vector(6 downto 0);	--	Seven Segment Digit 2
		HEX2_DP		: out std_logic;							--	Seven Segment Digit DP 2
		HEX3_D		: out std_logic_vector(6 downto 0);	--	Seven Segment Digit 3
		HEX3_DP		: out std_logic;							--	Seven Segment Digit DP 3
		-- LED
		LEDG			: out std_logic_vector(9 downto 0);		--	LED Green[9:0]
		-- PS2
		PS2_KBDAT	: in std_logic;						--	PS2 Keyboard Data
		PS2_KBCLK	: in std_logic;						--	PS2 Keyboard Clock
		-- VGA
		VGA_HS		: out std_logic;							--	VGA H_SYNC
		VGA_VS		: out std_logic;							--	VGA V_SYNC
		VGA_R			: out std_logic_vector(3 downto 0); --	VGA Red[3:0]
		VGA_G			: out std_logic_vector(3 downto 0);	--	VGA Green[3:0]
		VGA_B			: out std_logic_vector(3 downto 0);  	--	VGA Blue[3:0]
		-- GPIO
		GPIO0_CLKIN	: in std_logic_vector(1 downto 0);		--	GPIO Connection 0 Clock In Bus
		GPIO0_CLKOUT: out std_logic_vector(1 downto 0);		--	GPIO Connection 0 Clock Out Bus
		GPIO0_D		: out std_logic_vector(31 downto 0);	--	GPIO Connection 0 Data Bus
		GPIO1_CLKIN	: in std_logic_vector(1 downto 0);		--	GPIO Connection 1 Clock In Bus
		GPIO1_CLKOUT: out std_logic_vector(1 downto 0);		--	GPIO Connection 1 Clock Out Bus
		GPIO1_D		: inout std_logic_vector(31 downto 0)	--	GPIO Connection 1 Data Bus
	);
end component;

component mz80b_de0
	port (
		spi_cs_export            : out   std_logic;                                        -- export
		cfi_tcm_address_out      : out   std_logic_vector(21 downto 0);                    -- tcm_address_out
		cfi_tcm_read_n_out       : out   std_logic_vector(0 downto 0);                     -- tcm_read_n_out
		cfi_tcm_write_n_out      : out   std_logic_vector(0 downto 0);                     -- tcm_write_n_out
		cfi_tcm_data_out         : inout std_logic_vector(15 downto 0) := (others => 'X'); -- tcm_data_out
		cfi_tcm_chipselect_n_out : out   std_logic_vector(0 downto 0);                     -- tcm_chipselect_n_out
		spi_MISO                 : in    std_logic                     := 'X';             -- MISO
		spi_MOSI                 : out   std_logic;                                        -- MOSI
		spi_SCLK                 : out   std_logic;                                        -- SCLK
		spi_SS_n                 : out   std_logic_vector(1 downto 0);                     -- SS_n
		uart_rxd                 : in    std_logic                     := 'X';             -- rxd
		uart_txd                 : out   std_logic;                                        -- txd
		uart_cts_n               : in    std_logic                     := 'X';             -- cts_n
		uart_rts_n               : out   std_logic;                                        -- rts_n
		clkin_clk                : in    std_logic                     := 'X';             -- clk
		mem_address              : out   std_logic_vector(20 downto 0);                    -- address
		mem_readdata             : in    std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
		mem_writedata            : out   std_logic_vector(31 downto 0);                    -- writedata
		mem_byteenable_n         : out   std_logic_vector(3 downto 0);                     -- byteenable_n
		mem_chipselect_n         : out   std_logic;                                        -- chipselect_n
		mem_write_n              : out   std_logic;                                        -- write_n
		mem_waitrequest_n        : in    std_logic                     := 'X';             -- waitrequest_n
		mem_reset_reset_n        : out   std_logic;                                        -- reset_n
		reset_reset_n            : in    std_logic                     := 'X';             -- reset_n
		reg_address              : out   std_logic_vector(15 downto 0);                    -- address
		reg_readdata             : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- readdata
		reg_writedata            : out   std_logic_vector(7 downto 0);                     -- writedata
		reg_chipselect_n         : out   std_logic;                                        -- chipselect_n
		reg_write_n              : out   std_logic;                                        -- write_n
		reg_reset_reset_n        : out   std_logic;                                        -- reset_n
		intc_export              : in    std_logic                     := 'X'              -- export
	);
end component;

component sdram
	port (
		reset			: in std_logic;								-- Reset
		RSTOUT		: out std_logic;								-- Reset After Init. SDRAM
		CLOCK_50		: in std_logic;								-- Clock(50MHz)
		PCLK			: out std_logic;								-- CPU Clock
		-- RAM access(port-A:Z80 bus)
		AA				: in std_logic_vector(22 downto 0);		-- Address
		DAI			: in std_logic_vector(7 downto 0);		-- Data Input(16bit)
		DAO			: out std_logic_vector(7 downto 0);		-- Data Output(16bit)
		CSA			: in std_logic;								-- Chip Select
		WEA			: in std_logic;								-- Write Enable
		PGA			: in std_logic;								-- Purge Cache
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
		DDO			: out std_logic_vector(7 downto 0);		-- Data Output(16bit)
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
end component;

begin

	--
	-- Instantiation
	--
	MZ80B : mz80b_core port map(
		-- Z80 Memory Bus
		ZADR => ZADR,
		ZDI => ZDI,
		ZDO => ZDO,
		ZCS_x =>ZCS_x,
		ZWR_x => ZWR_x,
		ZPG_x => ZPG_x,
		-- NiosII Access
		RRST_x => RRST_x,						-- NiosII Reset
		RCLK => PCLK,							-- NiosII Clock
		RADR => RADR,							-- NiosII Address Bus
		RCS_x => RCS_x,						-- NiosII Read Signal
		RWE_x => RWE_x,						-- NiosII Write Signal
		RDI => RDO,								-- NiosII Data Bus(in)
		RDO => RDI,								-- NiosII Data Bus(out)
		INTL => INTL,							-- Interrupt Line
		-- Graphic VRAM Access
		GCS_x => GCS_x,						-- GRAM Request
		GADR => GADR,							-- GRAM Address
		GWR_x => GWR_x,		 				-- GRAM Write Signal
		GBE_x => GBE_x,						-- GRAM Byte Enable
		GDI => GDI,								-- Data Bus Input from GRAM
		GDO => GDO,								-- Data Bus Output to GRAM
		-- FD Buffer RAM I/F
		BCS_x => BCS_x,						-- RAM Request
		BADR => BADR,							-- RAM Address
		BWR_x => BWR_x,		 				-- RAM Write Signal
		BDI => BDI,								-- Data Bus Input from RAM
		BDO => BDO,								-- Data Bus Output to RAM
		-- Resets
		URST_x => URST,						-- Universal Reset
		MRST_x => MRST,						-- All Reset
		ARST_x => ARST,						-- All Reset
		-- Clock Input
		CLOCK_50 => CLOCK_50,				--	50 MHz
		-- Push Button
		BUTTON => BUTTON,						--	Pushbutton[2:0]
		-- Switch
		SW => SW,								--	Toggle Switch[9:0]
		-- 7-SEG Dispaly
		HEX0_D => HEX0_D,						--	Seven Segment Digit 0
		HEX0_DP => HEX0_DP,					--	Seven Segment Digit DP 0
		HEX1_D => HEX1_D,						--	Seven Segment Digit 1
		HEX1_DP => HEX1_DP,					--	Seven Segment Digit DP 1
		HEX2_D => HEX2_D,						--	Seven Segment Digit 2
		HEX2_DP => HEX2_DP,					--	Seven Segment Digit DP 2
		HEX3_D => HEX3_D,						--	Seven Segment Digit 3
		HEX3_DP => HEX3_DP,					--	Seven Segment Digit DP 3
		-- LED
		LEDG => T_LEDG,						--	LED Green[9:0]
		-- PS2
		PS2_KBDAT => PS2_KBDAT,				--	PS2 Keyboard Data
		PS2_KBCLK => PS2_KBCLK,				--	PS2 Keyboard Clock
		-- VGA
		VGA_HS => VGA_HS,						-- VGA H_SYNC
		VGA_VS => VGA_VS,						-- VGA V_SYNC
		VGA_R => VGA_R, 						-- VGA Red[3:0]
		VGA_G => VGA_G,						-- VGA Green[3:0]
		VGA_B => VGA_B,  						-- VGA Blue[3:0]
		-- GPIO
		GPIO0_CLKIN => GPIO0_CLKIN,		--	GPIO Connection 0 Clock In Bus
		GPIO0_CLKOUT => GPIO0_CLKOUT,		--	GPIO Connection 0 Clock Out Bus
		GPIO0_D => GPIO0_D,					--	GPIO Connection 0 Data Bus
		GPIO1_CLKIN => GPIO1_CLKIN,		--	GPIO Connection 1 Clock In Bus
		GPIO1_CLKOUT => GPIO1_CLKOUT,		--	GPIO Connection 1 Clock Out Bus
		GPIO1_D => GPIO1_D					--	GPIO Connection 1 Data Bus
	);

	SOPC0 : mz80b_de0 port map (
		spi_cs_export            => SD_CS,						--    spi_cs.export
		cfi_tcm_address_out      => FL_ADDR0,					--       cfi.tcm_address_out
		cfi_tcm_read_n_out       => FL_OE_Ni,					--          .tcm_read_n_out
		cfi_tcm_write_n_out      => FL_WE_Ni,					--          .tcm_write_n_out
		cfi_tcm_data_out         => FL_DQ,						--          .tcm_data_out
		cfi_tcm_chipselect_n_out => FL_CE_Ni,					--          .tcm_chipselect_n_out
		spi_MISO                 => SD_DAT0,					--       spi.MISO
		spi_MOSI                 => SD_DO,						--          .MOSI
		spi_SCLK                 => SD_CLK,						--          .SCLK
		spi_SS_n                 => SD_DEN,						--          .SS_n
		uart_rxd                 => UART_RXD,					--      uart.rxd
		uart_txd                 => UART_TXD,					--          .txd
		uart_cts_n               => UART_CTS,					--          .cts_n
		uart_rts_n               => UART_RTS,					--          .rts_n
		clkin_clk                => PCLK,						--     clkin.clk
		mem_address              => MADR,						--       mem.address
		mem_readdata             => MDI,							--          .readdata
		mem_writedata            => MDO,							--          .writedata
		mem_byteenable_n         => MBEN_x,						--          .byteenable_n
		mem_chipselect_n         => MCS_x,						--          .chipselect_n
		mem_write_n              => MWE_x,						--          .write_n
		mem_waitrequest_n        => MWRQ_x,						--          .waitrequest_n
		mem_reset_reset_n        => open,						-- mem_reset.reset_n
		reset_reset_n            => ARST,						--     reset.reset_n
		reg_address              => RADR,						--       reg.address
		reg_readdata             => RDI,							--          .readdata
		reg_writedata            => RDO,							--          .writedata
		reg_chipselect_n         => RCS_x,						--          .chipselect_n
		reg_write_n              => RWE_x,						--          .write_n
		reg_reset_reset_n        => RRST_x,						-- reg_reset.reset_n
		intc_export              => INTL							--      intc.export
	);

	DRAM0 : sdram port map (
		reset => URST,							-- Reset
		RSTOUT => MRST,						-- Reset After Init. SDRAM
		CLOCK_50 => CLOCK_50_2,				-- Clock(50MHz)
		PCLK => PCLK,							-- CPU Clock
		-- RAM access(port-A:Z80 Memory Bus)
		AA => ZADR,								-- Address
		DAI => ZDO,								-- Data Input(16bit)
		DAO => ZDI,								-- Data Output(16bit)
		CSA => ZCS_x,							-- Chip Select
		WEA => ZWR_x,							-- Write Enable
		PGA => ZPG_x,							-- Purge Cache
		-- RAM access(port-B:Avalon Bus)
		AB => MADR,								-- Address
		DBI => MDO,								-- Data Input(32bit)
		DBO => MDI,								-- Data Output(32bit)
		CSB => MCS_x,							-- Chip Select
		WEB => MWE_x,							-- Write Enable
		BEB => MBEN_x,							-- Byte Enable
		WQB => MWRQ_x,							-- CPU Wait
		-- RAM access(port-C:Reserve)
		AC => (others=>'1'),					-- Address
		DCI => (others=>'0'),				-- Data Input(16bit)
		DCO => open,							-- Data Output(16bit)
		CSC => '1',								-- Chip Select
		WEC => '1',								-- Write Enable
		BEC => "11",							-- Byte Enable
		-- RAM access(port-D:FD Buffer)
		AD => BADR,								-- Address
		DDI => BDO,								-- Data Input(16bit)
		DDO => BDI,								-- Data Output(16bit)
		CSD => BCS_x,							-- Chip Select
		WED => BWR_x,							-- Write Enable
		--BED => "00",							-- Byte Enable
		-- RAM access(port-E:Graphics Video Memory)
		AE => GADR,								-- Address
		DEI => GDO,								-- Data Input(32bit)
		DEO => GDI,								-- Data Output(32bit)
		CSE => GCS_x,							-- Chip Select
		WEE => GWR_x,							-- Write Enable
		BEE => GBE_x,							-- Byte Enable
		-- SDRAM signal
		MA => DRAM_ADDR(11 downto 0),		-- Address
		MBA0 => DRAM_BA_0,					-- Bank Address 0
		MBA1 => DRAM_BA_1,					-- Bank Address 1
		MDI => DRAM_DQ,						-- Data Input(16bit)
		MDO => SDRAMDO,						-- Data Output(16bit)
		MDOE => SDRAMDOE,						-- Data Output Enable
		MLDQ => DRAM_LDQM,					-- Lower Data Mask
		MUDQ => DRAM_UDQM,					-- Upper Data Mask
		MCAS => DRAM_CAS_N,					-- Column Address Strobe
		MRAS => DRAM_RAS_N,					-- Raw Address Strobe
		MCS => DRAM_CS_N,						-- Chip Select
		MWE => DRAM_WE_N,						-- Write Enable
		MCKE => DRAM_CKE,						-- Clock Enable
		MCLK => DRAM_CLK						-- SDRAM Clock
	);

	--
	-- MMC/SD CARD
	--
	SD_CMD<=SD_DO when SD_DEN(1)='0' else '1';
	SD_DAT3<=SD_CS;

	--
	-- SDRAM
	--
	DRAM_DQ<=SDRAMDO when SDRAMDOE='1' else (others=>'Z');

	--
	-- Flash Memory
	--
	FL_ADDR<='0'&FL_ADDR0(21 downto 1);
	FL_RST_N<='1';	--URST;
	FL_WP_N<='1';
	FL_BYTE_N<='1';
	FL_WE_N<=FL_WE_Ni(0);
	FL_OE_N<=FL_OE_Ni(0);
	FL_CE_N<=FL_CE_Ni(0);

	--
	-- Misc & Debug
	--
	LEDG<=(not SD_CS)&T_LEDG(8 downto 0);
--	LEDG<=(not SD_CS)&"000000000";
	--GPIO0_D(0)<=PS2_KBCLK;
	--GPIO0_D(1)<=PS2_KBDAT;
	--GPIO0_D(2)<=KBEN;
	--GPIO0_D(10 downto 3)<=KBDT;
	--GPIO0_D(11)<=ARST;

end rtl;
