---------------------------------------------------------------------------------------------------------
--
-- Name:            config_pkg.vhd
-- Created:         July 2018
-- Author(s):       Philip Smart
-- Description:     Sharp MZ series compilation configuration parameters.
--
-- Credits:         
-- Copyright:       (c) 2018 Philip Smart <philip.smart@net2net.org>
--
-- History:         September 2018   - Initial module written.
--                  April 2020       - Started to blend in ZPU developments after giving up on the
--                                     STORM processor (very nice but I hit a cache bug and it wasnt a
--                                     quick fix, the STORM is no longer maintained). I moved onto the
--                                     Neo430 from the same designer which is very nice but a little
--                                     underpowered for what I need in this emulator, hence settling on 
--                                     my own version of the ZPU which I can customise as necessary.
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

package config_pkg is

    constant DEBUG_ENABLE           : integer := 1;                      -- Enable debug logic,
    constant ZPU_ENABLE             : integer := 1;                      -- Enable local ZPU IO processor,
    constant NEO_ENABLE             : integer := 0;                      -- Enable local NEO430 IO processor,
    constant STORM_ENABLE           : integer := 0;                      -- Enable local STORM IO processor,

end config_pkg;
