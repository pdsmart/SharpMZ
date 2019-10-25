	component pll is
		port (
			clk_clk           : in  std_logic := 'X'; -- clk
			pll_0_outclk1_clk : out std_logic;        -- clk
			pll_0_outclk2_clk : out std_logic;        -- clk
			pll_0_outclk3_clk : out std_logic;        -- clk
			pll_0_outclk4_clk : out std_logic;        -- clk
			pll_0_outclk5_clk : out std_logic;        -- clk
			pll_0_outclk6_clk : out std_logic;        -- clk
			pll_0_refclk_clk  : in  std_logic := 'X'; -- clk
			pll_0_reset_reset : in  std_logic := 'X'; -- reset
			pll_1_outclk0_clk : out std_logic;        -- clk
			pll_1_outclk1_clk : out std_logic;        -- clk
			pll_1_outclk2_clk : out std_logic;        -- clk
			pll_1_outclk3_clk : out std_logic;        -- clk
			pll_1_outclk4_clk : out std_logic;        -- clk
			pll_1_reset_reset : in  std_logic := 'X'; -- reset
			pll_2_outclk0_clk : out std_logic;        -- clk
			pll_2_outclk1_clk : out std_logic;        -- clk
			pll_2_outclk2_clk : out std_logic;        -- clk
			pll_2_outclk3_clk : out std_logic;        -- clk
			pll_2_reset_reset : in  std_logic := 'X'; -- reset
			reset_reset_n     : in  std_logic := 'X'  -- reset_n
		);
	end component pll;

	u0 : component pll
		port map (
			clk_clk           => CONNECTED_TO_clk_clk,           --           clk.clk
			pll_0_outclk1_clk => CONNECTED_TO_pll_0_outclk1_clk, -- pll_0_outclk1.clk
			pll_0_outclk2_clk => CONNECTED_TO_pll_0_outclk2_clk, -- pll_0_outclk2.clk
			pll_0_outclk3_clk => CONNECTED_TO_pll_0_outclk3_clk, -- pll_0_outclk3.clk
			pll_0_outclk4_clk => CONNECTED_TO_pll_0_outclk4_clk, -- pll_0_outclk4.clk
			pll_0_outclk5_clk => CONNECTED_TO_pll_0_outclk5_clk, -- pll_0_outclk5.clk
			pll_0_outclk6_clk => CONNECTED_TO_pll_0_outclk6_clk, -- pll_0_outclk6.clk
			pll_0_refclk_clk  => CONNECTED_TO_pll_0_refclk_clk,  --  pll_0_refclk.clk
			pll_0_reset_reset => CONNECTED_TO_pll_0_reset_reset, --   pll_0_reset.reset
			pll_1_outclk0_clk => CONNECTED_TO_pll_1_outclk0_clk, -- pll_1_outclk0.clk
			pll_1_outclk1_clk => CONNECTED_TO_pll_1_outclk1_clk, -- pll_1_outclk1.clk
			pll_1_outclk2_clk => CONNECTED_TO_pll_1_outclk2_clk, -- pll_1_outclk2.clk
			pll_1_outclk3_clk => CONNECTED_TO_pll_1_outclk3_clk, -- pll_1_outclk3.clk
			pll_1_outclk4_clk => CONNECTED_TO_pll_1_outclk4_clk, -- pll_1_outclk4.clk
			pll_1_reset_reset => CONNECTED_TO_pll_1_reset_reset, --   pll_1_reset.reset
			pll_2_outclk0_clk => CONNECTED_TO_pll_2_outclk0_clk, -- pll_2_outclk0.clk
			pll_2_outclk1_clk => CONNECTED_TO_pll_2_outclk1_clk, -- pll_2_outclk1.clk
			pll_2_outclk2_clk => CONNECTED_TO_pll_2_outclk2_clk, -- pll_2_outclk2.clk
			pll_2_outclk3_clk => CONNECTED_TO_pll_2_outclk3_clk, -- pll_2_outclk3.clk
			pll_2_reset_reset => CONNECTED_TO_pll_2_reset_reset, --   pll_2_reset.reset
			reset_reset_n     => CONNECTED_TO_reset_reset_n      --         reset.reset_n
		);

