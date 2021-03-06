-- pll.vhd

-- Generated using ACDS version 17.1 593

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pll is
	port (
		clk_clk           : in  std_logic := '0'; --           clk.clk
		pll_0_outclk1_clk : out std_logic;        -- pll_0_outclk1.clk
		pll_0_outclk2_clk : out std_logic;        -- pll_0_outclk2.clk
		pll_0_outclk3_clk : out std_logic;        -- pll_0_outclk3.clk
		pll_0_outclk4_clk : out std_logic;        -- pll_0_outclk4.clk
		pll_0_outclk5_clk : out std_logic;        -- pll_0_outclk5.clk
		pll_0_outclk6_clk : out std_logic;        -- pll_0_outclk6.clk
		pll_0_refclk_clk  : in  std_logic := '0'; --  pll_0_refclk.clk
		pll_0_reset_reset : in  std_logic := '0'; --   pll_0_reset.reset
		pll_1_outclk0_clk : out std_logic;        -- pll_1_outclk0.clk
		pll_1_outclk1_clk : out std_logic;        -- pll_1_outclk1.clk
		pll_1_outclk2_clk : out std_logic;        -- pll_1_outclk2.clk
		pll_1_outclk3_clk : out std_logic;        -- pll_1_outclk3.clk
		pll_1_outclk4_clk : out std_logic;        -- pll_1_outclk4.clk
		pll_1_reset_reset : in  std_logic := '0'; --   pll_1_reset.reset
		pll_2_outclk0_clk : out std_logic;        -- pll_2_outclk0.clk
		pll_2_outclk1_clk : out std_logic;        -- pll_2_outclk1.clk
		pll_2_outclk2_clk : out std_logic;        -- pll_2_outclk2.clk
		pll_2_outclk3_clk : out std_logic;        -- pll_2_outclk3.clk
		pll_2_reset_reset : in  std_logic := '0'; --   pll_2_reset.reset
		reset_reset_n     : in  std_logic := '0'  --         reset.reset_n
	);
end entity pll;

architecture rtl of pll is
	component pll_pll_0 is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			outclk_1 : out std_logic;        -- clk
			outclk_2 : out std_logic;        -- clk
			outclk_3 : out std_logic;        -- clk
			outclk_4 : out std_logic;        -- clk
			outclk_5 : out std_logic;        -- clk
			outclk_6 : out std_logic;        -- clk
			outclk_7 : out std_logic;        -- clk
			locked   : out std_logic         -- export
		);
	end component pll_pll_0;

	component pll_pll_1 is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			outclk_1 : out std_logic;        -- clk
			outclk_2 : out std_logic;        -- clk
			outclk_3 : out std_logic;        -- clk
			outclk_4 : out std_logic;        -- clk
			locked   : out std_logic         -- export
		);
	end component pll_pll_1;

	component pll_pll_2 is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			outclk_1 : out std_logic;        -- clk
			outclk_2 : out std_logic;        -- clk
			outclk_3 : out std_logic;        -- clk
			locked   : out std_logic         -- export
		);
	end component pll_pll_2;

	signal pll_0_outclk0_clk : std_logic; -- pll_0:outclk_0 -> [pll_1:refclk, pll_2:refclk]

begin

	pll_0 : component pll_pll_0
		port map (
			refclk   => pll_0_refclk_clk,  --  refclk.clk
			rst      => pll_0_reset_reset, --   reset.reset
			outclk_0 => pll_0_outclk0_clk, -- outclk0.clk
			outclk_1 => pll_0_outclk1_clk, -- outclk1.clk
			outclk_2 => pll_0_outclk2_clk, -- outclk2.clk
			outclk_3 => pll_0_outclk3_clk, -- outclk3.clk
			outclk_4 => pll_0_outclk4_clk, -- outclk4.clk
			outclk_5 => pll_0_outclk5_clk, -- outclk5.clk
			outclk_6 => pll_0_outclk6_clk, -- outclk6.clk
			outclk_7 => open,              -- outclk7.clk
			locked   => open               -- (terminated)
		);

	pll_1 : component pll_pll_1
		port map (
			refclk   => pll_0_outclk0_clk, --  refclk.clk
			rst      => pll_1_reset_reset, --   reset.reset
			outclk_0 => pll_1_outclk0_clk, -- outclk0.clk
			outclk_1 => pll_1_outclk1_clk, -- outclk1.clk
			outclk_2 => pll_1_outclk2_clk, -- outclk2.clk
			outclk_3 => pll_1_outclk3_clk, -- outclk3.clk
			outclk_4 => pll_1_outclk4_clk, -- outclk4.clk
			locked   => open               -- (terminated)
		);

	pll_2 : component pll_pll_2
		port map (
			refclk   => pll_0_outclk0_clk, --  refclk.clk
			rst      => pll_2_reset_reset, --   reset.reset
			outclk_0 => pll_2_outclk0_clk, -- outclk0.clk
			outclk_1 => pll_2_outclk1_clk, -- outclk1.clk
			outclk_2 => pll_2_outclk2_clk, -- outclk2.clk
			outclk_3 => pll_2_outclk3_clk, -- outclk3.clk
			locked   => open               -- (terminated)
		);

end architecture rtl; -- of pll
