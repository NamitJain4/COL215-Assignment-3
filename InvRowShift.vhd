-- VHDL implementation of AES
-- Copyright (C) 2019  Hosein Hadipour

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;

entity inv_shift_rows is
	port (
		input : in std_logic_vector(31 downto 0);
		inp_row: in std_logic_vector(1 downto 0);
		outpt : out std_logic_vector(31 downto 0)
	);
end inv_shift_rows;

architecture rtl of inv_shift_rows is
	component mux4x1
	   Port (
            inp1 : in STD_LOGIC_VECTOR (7 downto 0);
            inp2 : in STD_LOGIC_VECTOR (7 downto 0);
            inp3 : in STD_LOGIC_VECTOR (7 downto 0);
            inp4 : in STD_LOGIC_VECTOR (7 downto 0);
            Sel : in STD_LOGIC_VECTOR (1 downto 0);
            output : out STD_LOGIC_VECTOR (7 downto 0)
        );
	end component;
begin
    first_byte : mux4x1 port map (
        inp1 => input (7 downto 0),
        inp2 => input (15 downto 8),
        inp3 => input (23 downto 16),
        inp4 => input (31 downto 24),
        Sel => inp_row,
        output => outpt (7 downto 0)
    );
    second_byte : mux4x1 port map (
        inp1 => input (15 downto 8),
        inp2 => input (23 downto 16),
        inp3 => input (31 downto 24),
        inp4 => input (7 downto 0),
        Sel => inp_row,
        output => outpt (15 downto 8)
    );
    third_byte : mux4x1 port map (
        inp1 => input (23 downto 16),
        inp2 => input (31 downto 24),
        inp3 => input (7 downto 0),
        inp4 => input (15 downto 8),
        Sel => inp_row,
        output => outpt (23 downto 16)
    );
    fourth_byte : mux4x1 port map (
        inp1 => input (31 downto 24),
        inp2 => input (7 downto 0),
        inp3 => input (15 downto 8),
        inp4 => input (23 downto 16),
        Sel => inp_row,
        output => outpt (31 downto 24)
    );
     
     
end architecture rtl;