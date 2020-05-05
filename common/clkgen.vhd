---------------------------------------------------------------------------------------------------------
--
-- Name:            clkgen.vhd
-- Created:         July 2018
-- Author(s):       Philip Smart
-- Description:     A programmable Clock Generate module using division.
--                  
--                  This module is the heart of the emulator, providing all required frequencies
--                  from a given input clock (ie. DE10 Nano 50MHz).
--
--                  Based on input control signals from the MCTRL block, it changes the core frequencies
--                  according to requirements and adjusts delays (such as memory) accordingly.
--
--                  The module also has debugging logic to create debug frequencies (in the FPGA, static
--                  is quite possible). The debug frequencies can range from CPU down to 1/10 Hz.
--
--                  Note: Generally on FPGA's you try to minimise clocks generated by division, this is
--                  due to following:-
--                    o The fpga may need to have the routing to bring a clock signal from a register
--                      output into a clock net.
--                    o Clock nets are a limited resource, some fpga's can clock flip flops off normal
--                      nets but doing this is likely to affect timing behaviour.
--                    o You may need to add constraints to tell the timing analyser the clock details in
--                      order to get proper timing behaviour/analysis.
--                    o There may be substantial phase-skew between the original clock and the generated
--                      clock.
--                    o To ensure the clock is clean it should come directly from a register output, not
--                      from combinatorial logic.
--
--                  This module has been written with the above in mind and on the Cyclone SE it works fine.
--                  Basically it uses Clock Enables on the Master clock to minimise skew. Only core frequencies
--                  that cannot be clock enabled remain.
--                  
-- Credits:         
-- Copyright:       (c) 2018 Philip Smart <philip.smart@net2net.org>
--
-- History:         July 2018   - Initial module written.
--                  October 2018- Updated and seperated so that debug code can be removed at compile time.
--
---------------------------------------------------------------------------------------------------------
-- This source file is free software: you can redistribute it and-or modify
-- it under the terms of the GNU General Public License as published
-- by the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This source file is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http:--www.gnu.org-licenses->.
---------------------------------------------------------------------------------------------------------

package clkgen_pkg is

    -- Clock bus, various clocks on a single bus construct.
    --
    subtype  CLKBUS_WIDTH is integer range 7 downto 0;

    -- Indexes to the various clocks on the bus.
    --
    constant CKMASTER               : integer := 0;
    constant CKSOUND                : integer := 1;                      -- Sound clock.
    constant CKRTC                  : integer := 2;                      -- RTC clock.
    constant CKENVIDEO              : integer := 3;                      -- Video clock enable.
    constant CKVIDEO                : integer := 4;                      -- Video clock.
    constant CKENCPU                : integer := 5;                      -- CPU clock enable.
    constant CKENLEDS               : integer := 6;                      -- LEDS display clock enable.
    constant CKENPERIPH             : integer := 7;                      -- Peripheral clock enable.
end clkgen_pkg;

library IEEE;
library pkgs;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use pkgs.config_pkg.all;
use pkgs.clkgen_pkg.all;
use pkgs.mctrl_pkg.all;

entity clkgen is
    Port (
        RST                        : in  std_logic;                      -- Reset

        -- Clocks
        CKBASE                     : in  std_logic;                      -- Base system main clock.
        CLKBUS                     : out std_logic_vector(CLKBUS_WIDTH); -- Clock signals created by this module.

        -- Different operations modes.
        CONFIG                     : in  std_logic_vector(CONFIG_WIDTH);    

        -- Debug modes.
        DEBUG                      : in std_logic_vector(DEBUG_WIDTH)
    );
end clkgen;

architecture RTL of clkgen is

--
-- Selectable output Clocks
--
signal PLLLOCKED1                  : std_logic;           
signal PLLLOCKED2                  : std_logic;           
signal PLLLOCKED3                  : std_logic;           
signal CK448Mi                     : std_logic;                          -- 448MHz
signal CK112Mi                     : std_logic;                          -- 112MHz
signal CK64Mi                      : std_logic;                          -- 64MHz
signal CK56M750i                   : std_logic;                          -- 56MHz
signal CK32Mi                      : std_logic;                          -- 32MHz
signal CK31M5i                     : std_logic;                          -- 31.5MHz
signal CK28M375i                   : std_logic;                          -- 28MHz
signal CK25M175i                   : std_logic;                          -- 25.175MHz
signal CK17M734i                   : std_logic;                          -- 17.7MHz
signal CK16Mi                      : std_logic;                          -- 16MHz
signal CK14M1875i                  : std_logic;                          -- 14MHz
signal CK8M8672i                   : std_logic;                          -- 8.8MHz
signal CK8Mi                       : std_logic;                          -- 8MHz
signal CK7M709i                    : std_logic;                          -- 7MHz
signal CK4Mi                       : std_logic;                          -- 4MHz
signal CK3M546875i                 : std_logic;                          -- 3.5MHz
signal CK2Mi                       : std_logic;                          -- 2MHz
signal CK1Mi                       : std_logic;                          -- 1MHz
signal CK895Ki                     : std_logic;                          -- 895KHz Sound frequency.
signal CK100Ki                     : std_logic;                          -- Debug frequency.
signal CK31500i                    : std_logic;                          -- Clock base frequency,
signal CK31250i                    : std_logic;                          -- Clock base frequency.
signal CK15611i                    : std_logic;                          -- Clock base frequency.
signal CK10Ki                      : std_logic;                          -- 10KHz debug CPU frequency.
signal CK5Ki                       : std_logic;                          -- 5KHz debug CPU frequency.
signal CK1Ki                       : std_logic;                          -- 1KHz debug CPU frequency.
signal CK500i                      : std_logic;                          -- 500Hz debug CPU frequency.
signal CK100i                      : std_logic;                          -- 100Hz debug CPU frequency.
signal CK50i                       : std_logic;                          -- 50Hz debug CPU frequency.
signal CK10i                       : std_logic;                          -- 10Hz debug CPU frequency.
signal CK5i                        : std_logic;                          -- 5Hz debug CPU frequency.
signal CK2i                        : std_logic;                          -- 2Hz debug CPU frequency.
signal CK1i                        : std_logic;                          -- 1Hz debug CPU frequency.
signal CK0_5i                      : std_logic;                          -- 0.5Hz debug CPU frequency.
signal CK0_2i                      : std_logic;                          -- 0.2Hz debug CPU frequency.
signal CK0_1i                      : std_logic;                          -- 0.1Hz debug CPU frequency.
signal CKSOUNDi                    : std_logic;                          -- Sound clock 50/50 Duty cycle.
signal CKRTCi                      : std_logic;                          -- RTC clock 50/50 Duty cycle.
signal CKVIDEOi                    : std_logic;                          -- Video clock 50/50 Duty cycle.
--
-- Enable signals for target clocks.
--
signal CKENCPUi                    : std_logic;
signal CKENLEDSi                   : std_logic;
signal CKENVIDEOi                  : std_logic;
signal CKENPERi                    : std_logic;
--
-- Clock edge detection for creating clock enables.
--
signal CPUEDGE                     : std_logic_vector(1 downto 0);
signal LEDSEDGE                    : std_logic_vector(1 downto 0);
signal VIDEOEDGE                   : std_logic_vector(1 downto 0);
signal PEREDGE                     : std_logic_vector(1 downto 0);
    
--
-- Components
--
component pll_pll_0 is
    port (
        refclk                     : in  std_logic := 'X';               -- clk
        rst                        : in  std_logic := 'X';               -- reset
        outclk_0                   : out std_logic;                      -- clk
        outclk_1                   : out std_logic;                      -- clk
        outclk_2                   : out std_logic;                      -- clk
        outclk_3                   : out std_logic;                      -- clk
        outclk_4                   : out std_logic;                      -- clk
        outclk_5                   : out std_logic;                      -- clk
        outclk_6                   : out std_logic;                      -- clk
        outclk_7                   : out std_logic;                      -- clk
        locked                     : out std_logic                       -- export
    );
end component pll_pll_0;

component pll_pll_1 is
    port (
        refclk                     : in  std_logic := 'X';               -- clk
        rst                        : in  std_logic := 'X';               -- reset
        outclk_0                   : out std_logic;                      -- clk
        outclk_1                   : out std_logic;                      -- clk
        outclk_2                   : out std_logic;                      -- clk
        outclk_3                   : out std_logic;                      -- clk
        outclk_4                   : out std_logic;                      -- clk
        locked                     : out std_logic                       -- export
    );
end component pll_pll_1;

component pll_pll_2 is
    port (
        refclk                     : in  std_logic := 'X';               -- clk
        rst                        : in  std_logic := 'X';               -- reset
        outclk_0                   : out std_logic;                      -- clk
        outclk_1                   : out std_logic;                      -- clk
        outclk_2                   : out std_logic;                      -- clk
        outclk_3                   : out std_logic;                      -- clk
        locked                     : out std_logic                       -- export
    );
end component pll_pll_2;

begin

    PLLMAIN01 : pll_pll_0
        port map (
            refclk                 => CKBASE,                            -- Reference clock
            rst                    => RST,                               -- Reset
            outclk_0               => CK448Mi,                           -- 448MHz
            outclk_1               => CK112Mi,                           -- 112MHz
            outclk_2               => CK64Mi,                            -- 64MHz
            outclk_3               => CK32Mi,                            -- 32MHz
            outclk_4               => CK16Mi,                            -- 16MHz
            outclk_5               => CK8Mi,                             -- 8MHz
            outclk_6               => CK4Mi,                             -- 4MHz
            outclk_7               => CK2Mi,                             -- 2MHz
            locked                 => PLLLOCKED1                         -- PLL locked.
        );

    PLLMAIN02 : pll_pll_1
        port map (
            refclk                 => CK448Mi,                           -- Reference clock
            rst                    => RST,                               -- Reset
            outclk_0               => CK56M750i,                         -- 56.750MHz
            outclk_1               => CK28M375i,                         -- 28.375MHz
            outclk_2               => CK14M1875i,                        -- 14.1875MHz
            outclk_3               => CK7M709i,                          -- 7.709MHz
            outclk_4               => CK3M546875i,                       -- 3.546875MHz
            locked                 => PLLLOCKED2                         -- PLL locked.
        );

    PLLMAIN03 : pll_pll_2
        port map (
            refclk                 => CK448Mi,                           -- Reference clock
            rst                    => RST,                               -- Reset
            outclk_0               => CK31M5i,                           -- 31.5MHz
            outclk_1               => CK25M175i,                         -- 25.175MHz
            outclk_2               => CK17M734i,                         -- 17.734MHz
            outclk_3               => CK8M8672i,                         -- 8.8672MHz
            locked                 => PLLLOCKED3                         -- PLL locked.
        );

    --
    -- Clock Generator - Basic divide circuit for higher end frequencies.
    --
    process (RST, PLLLOCKED1, PLLLOCKED2, PLLLOCKED3, CK2Mi) 
        --
        -- Divide by counters to create the various Clock enable signals.
        --
        variable counter1Mi        : unsigned(0 downto 0);                -- Binary divider to create 1Mi clock.
        variable counter895Ki      : unsigned(0 downto 0);                -- Binary divider to create 895Ki clock.
        variable counter100Ki      : unsigned(4 downto 0);                -- Binary divider to create 100Ki clock.
        variable counter31500i     : unsigned(5 downto 0);                -- Binary divider to create 31500i clock.
        variable counter31250i     : unsigned(5 downto 0);                -- Binary divider to create 31250i clock.
        variable counter15611i     : unsigned(6 downto 0);                -- Binary divider to create 15611i clock.
        variable counter10Ki       : unsigned(7 downto 0);                -- Binary divider to create 10Ki clock.
        variable counter5Ki        : unsigned(8 downto 0);                -- Binary divider to create 5Ki clock.
        variable counter1Ki        : unsigned(10 downto 0);               -- Binary divider to create 1Ki clock.
        variable counter500i       : unsigned(11 downto 0);               -- Binary divider to create 500i clock.
        variable counter100i       : unsigned(14 downto 0);               -- Binary divider to create 100i clock.
        variable counter50i        : unsigned(15 downto 0);               -- Binary divider to create 50i clock.
        variable counter10i        : unsigned(17 downto 0);               -- Binary divider to create 10i clock.
        variable counter5i         : unsigned(18 downto 0);               -- Binary divider to create 5i clock.
        variable counter2i         : unsigned(29 downto 0);               -- Binary divider to create 1i clock.
        variable counter1i         : unsigned(20 downto 0);               -- Binary divider to create 1i clock.
        variable counter0_5i       : unsigned(21 downto 0);               -- Binary divider to create 0_5i clock.
        variable counter0_2i       : unsigned(23 downto 0);               -- Binary divider to create 0_2i clock.
        variable counter0_1i       : unsigned(24 downto 0);               -- Binary divider to create 0_1i clock.

    begin
        if RST = '1' or PLLLOCKED1 = '0' or PLLLOCKED2 = '0' or PLLLOCKED3 = '0' then
            counter1Mi             := (others => '0');
            counter895Ki           := (others => '0');
            counter100Ki           := (others => '0');
            counter31500i          := (others => '0');
            counter31250i          := (others => '0');
            counter15611i          := (others => '0');
            counter10Ki            := (others => '0');
            counter5Ki             := (others => '0');
            counter1Ki             := (others => '0');
            counter500i            := (others => '0');
            counter100i            := (others => '0');
            counter50i             := (others => '0');
            counter10i             := (others => '0');
            counter5i              := (others => '0');
            counter2i              := (others => '0');
            counter1i              := (others => '0');
            counter0_5i            := (others => '0');
            counter0_2i            := (others => '0');
            counter0_1i            := (others => '0');
            CK1Mi                  <= '0';
            CK895Ki                <= '0';
            CK100Ki                <= '0';
            CK31500i               <= '0';
            CK31250i               <= '0';
            CK15611i               <= '0';
            CK10Ki                 <= '0';
            CK5Ki                  <= '0';
            CK1Ki                  <= '0';
            CK500i                 <= '0';
            CK100i                 <= '0';
            CK50i                  <= '0';
            CK10i                  <= '0';
            CK5i                   <= '0';
            CK2i                   <= '0';
            CK1i                   <= '0';
            CK0_5i                 <= '0';
            CK0_2i                 <= '0';
            CK0_1i                 <= '0';
            --
           -- CKSOUNDi               <= '0';
            CKRTCi                 <= '0';

        elsif rising_edge(CK2Mi) then

            -- 1000000Hz 
            if counter1Mi = 0 or counter1Mi = 1 then
                CK1Mi              <= not CK1Mi;
                if counter1Mi  = 1 then
                    counter1Mi     := (others => '0');
                else
                    counter1Mi     := counter1Mi + 1;
                end if;
            else
                counter1Mi         := counter1Mi + 1;
            end if;
            -- 895000Hz 
            if counter895Ki = 0 or counter895Ki = 1 then
                CK895Ki            <= not CK895Ki;

                if counter895Ki  = 1 then
                    counter895Ki   := (others => '0');
                else
                    counter895Ki   := counter895Ki + 1;
                end if;
            else
                counter895Ki       := counter895Ki + 1;
            end if;
            -- 100000Hz 
            if counter100Ki = 9 or counter100Ki = 19 then
                CK100Ki            <= not CK100Ki;
                if counter100Ki  = 19 then
                    counter100Ki   := (others => '0');
                else
                    counter100Ki   := counter100Ki + 1;
                end if;
            else
                counter100Ki       := counter100Ki + 1;
            end if;
            -- 31500Hz 
            if counter31500i = 30 or counter31500i = 62 then
                CK31500i           <= not CK31500i;

                if CONFIG(RTCSPEED) = "00" then
                    CKRTCi         <= not CKRTCi;
                end if;

                if counter31500i  = 62 then
                    counter31500i  := (others => '0');
                else
                    counter31500i  := counter31500i + 1;
                end if;
            else
                counter31500i      := counter31500i + 1;
            end if;
            -- 31250Hz 
            if counter31250i = 31 or counter31250i = 63 then
                CK31250i           <= not CK31250i;

                if CONFIG(RTCSPEED) = "01" then
                    CKRTCi         <= not CKRTCi;
                end if;

                if counter31250i  = 63 then
                    counter31250i  := (others => '0');
                else
                    counter31250i  := counter31250i + 1;
                end if;
            else
                counter31250i      := counter31250i + 1;
            end if;
            -- 15611Hz 
            if counter15611i = 63 or counter15611i = 127 then
                CK15611i           <= not CK15611i;

                if CONFIG(RTCSPEED) = "10" then
                    CKRTCi         <= not CKRTCi;
                end if;

                if counter15611i  = 127 then
                    counter15611i  := (others => '0');
                else
                    counter15611i  := counter15611i + 1;
                end if;
            else
                counter15611i      := counter15611i + 1;
            end if;
            -- 10000Hz 
            if counter10Ki = 99 or counter10Ki = 199 then
                CK10Ki             <= not CK10Ki;
                if counter10Ki  = 199 then
                    counter10Ki    := (others => '0');
                else
                    counter10Ki    := counter10Ki + 1;
                end if;
            else
                counter10Ki        := counter10Ki + 1;
            end if;
            -- 5000Hz 
            if counter5Ki = 199 or counter5Ki = 399 then
                CK5Ki              <= not CK5Ki;
                if counter5Ki  = 399 then
                    counter5Ki     := (others => '0');
                else
                    counter5Ki     := counter5Ki + 1;
                end if;
            else
                counter5Ki         := counter5Ki + 1;
            end if;
            -- 1000Hz 
            if counter1Ki = 999 or counter1Ki = 1999 then
                CK1Ki              <= not CK1Ki;
                if counter1Ki  = 1999 then
                    counter1Ki     := (others => '0');
                else
                    counter1Ki     := counter1Ki + 1;
                end if;
            else
                counter1Ki         := counter1Ki + 1;
            end if;
            -- 500Hz 
            if counter500i = 1999 or counter500i = 3999 then
                CK500i             <= not CK500i;
                if counter500i  = 3999 then
                    counter500i    := (others => '0');
                else
                    counter500i    := counter500i + 1;
                end if;
            else
                counter500i        := counter500i + 1;
            end if;
            -- 100Hz 
            if counter100i = 9999 or counter100i = 19999 then
                CK100i             <= not CK100i;
                if counter100i  = 19999 then
                    counter100i    := (others => '0');
                else
                    counter100i    := counter100i + 1;
                end if;
            else
                counter100i        := counter100i + 1;
            end if;
            -- 50Hz 
            if counter50i = 19999 or counter50i = 39999 then
                CK50i              <= not CK50i;
                if counter50i  = 39999 then
                    counter50i     := (others => '0');
                else
                    counter50i     := counter50i + 1;
                end if;
            else
                counter50i         := counter50i + 1;
            end if;
            -- 10Hz 
            if counter10i = 99999 or counter10i = 199999 then
                CK10i              <= not CK10i;
                if counter10i  = 199999 then
                    counter10i     := (others => '0');
                else
                    counter10i     := counter10i + 1;
                end if;
            else
                counter10i         := counter10i + 1;
            end if;
            -- 5Hz 
            if counter5i = 199999 or counter5i = 399999 then
                CK5i               <= not CK5i;
                if counter5i  = 399999 then
                    counter5i      := (others => '0');
                else
                    counter5i      := counter5i + 1;
                end if;
            else
                counter5i          := counter5i + 1;
            end if;
            -- 2Hz 
            if counter2i = 499999 or counter2i = 999999 then
                CK2i               <= not CK2i;
                if counter2i  = 999999 then
                    counter2i      := (others => '0');
                else
                    counter2i      := counter2i + 1;
                end if;
            else
                counter2i          := counter2i + 1;
            end if;
            -- 1Hz 
            if counter1i = 999999 or counter1i = 1999999 then
                CK1i               <= not CK1i;
                if counter1i  = 1999999 then
                    counter1i      := (others => '0');
                else
                    counter1i      := counter1i + 1;
                end if;
            else
                counter1i          := counter1i + 1;
            end if;
            -- 0.5Hz 
            if counter0_5i = 1999999 or counter0_5i = 3999999 then
                CK0_5i             <= not CK0_5i;
                if counter0_5i  = 3999999 then
                    counter0_5i    := (others => '0');
                else
                    counter0_5i    := counter0_5i + 1;
                end if;
            else
                counter0_5i        := counter0_5i + 1;
            end if;
            -- 0.2Hz 
            if counter0_2i = 4999999 or counter0_2i = 9999999 then
                CK0_2i             <= not CK0_2i;
                if counter0_2i  = 9999999 then
                    counter0_2i    := (others => '0');
                else
                    counter0_2i    := counter0_2i + 1;
                end if;
            else
                counter0_2i        := counter0_2i + 1;
            end if;
            -- 0.1Hz 
            if counter0_1i = 9999999 or counter0_1i = 19999999 then
                CK0_1i             <= not CK0_1i;
                if counter0_1i  = 19999999 then
                    counter0_1i    := (others => '0');
                else
                    counter0_1i    := counter0_1i + 1;
                end if;
            else
                counter0_1i        := counter0_1i + 1;
            end if;
        end if;
    end process;

    -- Process the clocks according to the user selections and assign.
    --
    process (RST, PLLLOCKED1, PLLLOCKED2, PLLLOCKED3, CK112Mi) 
    begin
        if RST = '1' or PLLLOCKED1 = '0' or PLLLOCKED2 = '0' or PLLLOCKED3 = '0' then
            CKENCPUi               <= '0';
            CKENLEDSi              <= '0';
            CKENPERi               <= '0';
            CPUEDGE                <= "00";
            LEDSEDGE               <= "00";
            VIDEOEDGE              <= "00";
            CKVIDEOi               <= '0';
            PEREDGE                <= "00";

        elsif rising_edge(CK112Mi) then

            -- Once the rising edge of the CPU clock is detected, enable the CPU Clock Enable signal
            -- which is used to enable the master clock onto the logic.
            CPUEDGE(0)             <= CPUEDGE(1);
            CKENCPUi               <= '0';
            if CPUEDGE = "10" then
                CKENCPUi           <= '1';
            end if;

            -- Once the rising edge of the LED clock is detected, enable the LED Clock Enable signal
            -- which is used to enable the master clock onto the LED logic.
            LEDSEDGE(0)            <= LEDSEDGE(1);
            CKENLEDSi              <= '0';
            if LEDSEDGE = "10" then
                CKENLEDSi          <= '1';
            end if;

            -- Once the rising edge of the Video clock is detected, enable the LED Clock Enable signal
            -- which is used to enable the master clock onto the Video logic.
            VIDEOEDGE(0)           <= VIDEOEDGE(1);
            CKENVIDEOi             <= '0';
            if VIDEOEDGE = "10" then
                CKENVIDEOi         <= '1';
            end if;

            -- Form the video frequency enable signal according to the user selection.
            --
            case CONFIG(VIDSPEED) is
                when "000" => -- 8MHz
                    VIDEOEDGE(1)   <= CK8Mi;
   
                when "001" => -- 16MHz
                    VIDEOEDGE(1)   <= CK16Mi;
  
                when "010" => -- 8.8672375MHz
                    VIDEOEDGE(1)   <= CK8M8672i;
 
                when "011" => -- 17.734475MHz
                    VIDEOEDGE(1)   <= CK17M734i;
                    
                when "100" => -- 25.175MHz - Standard VGA 640x480 mode.
                    VIDEOEDGE(1)   <= CK25M175i;

                when "101" => -- 8MHz
                    VIDEOEDGE(1)   <= CK25M175i;

                when "110" => -- 1368x768 VGA mode.
                    VIDEOEDGE(1)   <= CK31M5i;

                when "111" => -- Pixel clock for 1024x768 VGA mode. Should be 65Mhz.
                    VIDEOEDGE(1)   <= CK25M175i;
            end case;

            -- The video clock is multiplexed with the correct frequency chosen for the video
            -- mode. The actual clock is sent to the video module rather than an enable as skew
            -- is less of an issue.
            --
            case CONFIG(VIDSPEED) is
                when "000" => -- 8MHz
                    CKVIDEOi       <= CK8Mi;
   
                when "001" => -- 16MHz
                    CKVIDEOi       <= CK16Mi;
  
                when "010" => -- 8.8672375MHz
                    CKVIDEOi       <= CK8M8672i;
 
                when "011" => -- 17.734475MHz
                    CKVIDEOi       <= CK17M734i;

                when "100" => -- 25.175MHz - Standard VGA 640x480@60Hz mode.
                    CKVIDEOi       <= CK25M175i;

                when "101" => -- 25.175MHz - Standard VGA 640x480@60Hz mode.
                    CKVIDEOi       <= CK25M175i;

                when "110" => -- 640x480@75Hz mode.
                    CKVIDEOi       <= CK31M5i;

                when "111" => -- 25.175MHz - Standard VGA 640x480@60Hz mode.
                    CKVIDEOi       <= CK25M175i;
            end case;

            -- The sound clock is multiplexed with the correct frequency according to model.
            --
            case CONFIG(SNDSPEED) is
                when "01" =>
                    CKSOUNDi     <= CK895Ki;

                when "00" | "10" | "11" =>
                    CKSOUNDi     <= CK2Mi;
            end case;

            -- Once the rising edge of the Peripherals clock is detected, enable the Peripheral Clock Enable signal
            -- which is used to enable the master clock onto the Peripheral logic.
            PEREDGE(0)             <= PEREDGE(1);
            CKENPERi               <= '0';
            if PEREDGE = "10" then
                CKENPERi           <= '1';
            end if;
            
            -- If debugging has been enabled and the debug cpu frequency set to a valid value, change cpu clock accordingly.
            if DEBUG_ENABLE = 0 or DEBUG(ENABLED) = '0' or DEBUG(CPUFREQ) = "0000" then

                -- The CPU speed is configured by the CMT register and CMT state or the CPU register. Select the right
                -- frequency and form the clock by flipping on the right flip flag.
                --
                case CONFIG(CPUSPEED) is
                    when "0001" => -- 3.546875MHz
                        CPUEDGE(1) <= CK3M546875i;
                    when "0010" => -- 4MHz
                        CPUEDGE(1) <= CK4Mi;
                    when "0011" => -- 7.709MHz
                        CPUEDGE(1) <= CK7M709i;
                    when "0100" => -- 8MHz
                        CPUEDGE(1) <= CK8Mi;
                    when "0101" => -- 14.1875MHz
                        CPUEDGE(1) <= CK14M1875i;
                    when "0110" => -- 16MHz
                        CPUEDGE(1) <= CK16Mi;
                    when "0111" => -- 28.375MHz
                        CPUEDGE(1) <= CK28M375i;
                    when "1000" => -- 32MHz
                        CPUEDGE(1) <= CK32Mi;
                    when "1001" => -- 56.750MHz
                        CPUEDGE(1) <= CK56M750i;
                    when "1010" => -- 64MHz
                        CPUEDGE(1) <= CK64Mi;
    
                    -- Unallocated frequencies, use default.
                    when "0000" | "1011" | "1100" | "1101" | "1110" | "1111" => -- 2MHz
                        CPUEDGE(1) <= CK2Mi;
                end case;
            else
                case DEBUG(CPUFREQ) is
                    when "0000" => -- Use normal cpu frequency, so this choice shouldnt be selected.
                        CPUEDGE(1) <= CK2Mi;
                    when "0001" => -- 1MHz
                        CPUEDGE(1) <= CK1Mi;
                    when "0010" => -- 100KHz
                        CPUEDGE(1) <= CK100Ki;
                    when "0011" => -- 10KHz
                        CPUEDGE(1) <= CK10Ki;
                    when "0100" => -- 5KHz
                        CPUEDGE(1) <= CK5Ki;
                    when "0101" => -- 1KHz
                        CPUEDGE(1) <= CK1Ki;
                    when "0110" => -- 500Hz
                        CPUEDGE(1) <= CK500i;
                    when "0111" => -- 100Hz
                        CPUEDGE(1) <= CK100i;
                    when "1000" => -- 50Hz
                        CPUEDGE(1) <= CK50i;
                    when "1001" => -- 10Hz
                        CPUEDGE(1) <= CK10i;
                    when "1010" => -- 5Hz
                        CPUEDGE(1) <= CK5i;
                    when "1011" => -- 2Hz
                        CPUEDGE(1) <= CK2i;
                    when "1100" => -- 1Hz
                        CPUEDGE(1) <= CK1i;
                    when "1101" => -- 0.5Hz
                        CPUEDGE(1) <= CK0_5i;
                    when "1110" => -- 0.2Hz
                        CPUEDGE(1) <= CK0_2i;
                    when "1111" => -- 0.1Hz
                        CPUEDGE(1) <= CK0_1i;
                end case;
            end if;

            -- Sampling frequency of signals, typically used to drive LED outputs but could easily be read by an oscilloscope.
            --
            case DEBUG(SMPFREQ) is
                when "0000" => -- Use normal cpu frequency.
                    LEDSEDGE(1)    <= CPUEDGE(1);
                when "0001" => -- 1MHz
                    LEDSEDGE(1)    <= CK1Mi;
                when "0010" => -- 100KHz
                    LEDSEDGE(1)    <= CK100Ki;
                when "0011" => -- 10KHz
                    LEDSEDGE(1)    <= CK10Ki;
                when "0100" => -- 5KHz
                    LEDSEDGE(1)    <= CK5Ki;
                when "0101" => -- 1KHz
                    LEDSEDGE(1)    <= CK1Ki;
                when "0110" => -- 500Hz
                    LEDSEDGE(1)    <= CK500i;
                when "0111" => -- 100Hz
                    LEDSEDGE(1)    <= CK100i;
                when "1000" => -- 50Hz
                    LEDSEDGE(1)    <= CK50i;
                when "1001" => -- 10Hz
                    LEDSEDGE(1)    <= CK10i;
                when "1010" => -- 5Hz
                    LEDSEDGE(1)    <= CK5i;
                when "1011" => -- 2Hz
                    LEDSEDGE(1)    <= CK2i;
                when "1100" => -- 1Hz
                    LEDSEDGE(1)    <= CK1i;
                when "1101" => -- 0.5Hz
                    LEDSEDGE(1)    <= CK0_5i;
                when "1110" => -- 0.2Hz
                    LEDSEDGE(1)    <= CK0_2i;
                when "1111" => -- 0.1Hz
                    LEDSEDGE(1)    <= CK0_1i;
            end case;

            -- Form the RTC frequency enable signal according to the user selection.
            --
            case CONFIG(PERSPEED) is
                when "00" =>        -- 2MHz
                    PEREDGE(1)     <= CK2Mi;

                when "01" | "10" | "11" => -- 2MHz
                    PEREDGE(1)     <= CK2Mi;
            end case;

        end if;
    end process;

    -- Assign necessary clocks and enables.
    --
    CLKBUS(CKMASTER)               <= CK112Mi;
    CLKBUS(CKSOUND)                <= CKSOUNDi;                          -- Sound base clock, 50/50 duty cycle.
    CLKBUS(CKRTC)                  <= CKRTCi;                            -- RTC base clock, 50/50 duty cycle.
    CLKBUS(CKENVIDEO)              <= CKENVIDEOi;                        -- Enable signal for video base clock.
    CLKBUS(CKVIDEO)                <= CKVIDEOi;                          -- Clock signal for video base clock.
    CLKBUS(CKENCPU)                <= CKENCPUi;                          -- Enable signal for CPU base clock.
    CLKBUS(CKENLEDS)               <= CKENLEDSi;                         -- Enable signal for LEDS base clock.
    CLKBUS(CKENPERIPH)             <= CKENPERi;                          -- Enable signal for Peripheral base clock.

end RTL;
