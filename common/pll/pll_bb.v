
module pll (
	clk_clk,
	pll_0_outclk1_clk,
	pll_0_outclk2_clk,
	pll_0_outclk3_clk,
	pll_0_outclk4_clk,
	pll_0_outclk5_clk,
	pll_0_outclk6_clk,
	pll_0_refclk_clk,
	pll_0_reset_reset,
	pll_1_outclk0_clk,
	pll_1_outclk1_clk,
	pll_1_outclk2_clk,
	pll_1_outclk3_clk,
	pll_1_outclk4_clk,
	pll_1_reset_reset,
	pll_2_outclk0_clk,
	pll_2_outclk1_clk,
	pll_2_outclk2_clk,
	pll_2_outclk3_clk,
	pll_2_reset_reset,
	reset_reset_n);	

	input		clk_clk;
	output		pll_0_outclk1_clk;
	output		pll_0_outclk2_clk;
	output		pll_0_outclk3_clk;
	output		pll_0_outclk4_clk;
	output		pll_0_outclk5_clk;
	output		pll_0_outclk6_clk;
	input		pll_0_refclk_clk;
	input		pll_0_reset_reset;
	output		pll_1_outclk0_clk;
	output		pll_1_outclk1_clk;
	output		pll_1_outclk2_clk;
	output		pll_1_outclk3_clk;
	output		pll_1_outclk4_clk;
	input		pll_1_reset_reset;
	output		pll_2_outclk0_clk;
	output		pll_2_outclk1_clk;
	output		pll_2_outclk2_clk;
	output		pll_2_outclk3_clk;
	input		pll_2_reset_reset;
	input		reset_reset_n;
endmodule
