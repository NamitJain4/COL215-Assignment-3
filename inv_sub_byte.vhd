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

entity inv_sub_byte is
	port (
	    clk : in std_logic;
		input_data : in std_logic_vector(7 downto 0);
		output_data : out std_logic_vector(7 downto 0)
	);
end inv_sub_byte;

architecture behavioral of inv_sub_byte is

    component blk_mem_gen_2
        Port (
            clka  : in  std_logic;                 
            ena   : in  std_logic;                     
            wea   : in  std_logic_vector(0 downto 0);  
            addra : in  std_logic_vector(7 downto 0);  
            dina  : in  std_logic_vector(7 downto 0); 
            douta : out std_logic_vector(7 downto 0)   
        );
    end component;
    
    constant dina_const : std_logic_vector(7 downto 0) := (others => '0');
	
begin

    bram_inst : blk_mem_gen_2
        port map (
            clka  => clk,
            ena   => '1',                
            wea   => "0",  
            addra => input_data (3 downto 0) & input_data (7 downto 4),              
            dina  => dina_const,                
            douta => output_data               
        );
	
end architecture behavioral;