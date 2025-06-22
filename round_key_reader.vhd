----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/07/2024 04:13:05 PM
-- Design Name: 
-- Module Name: round_key_reader - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity round_key_reader is
    Port (
       clk      : in  std_logic;
       addr     : in  std_logic_vector(7 downto 0);
       dout     : out std_logic_vector(7 downto 0)
    );
end round_key_reader;

architecture Behavioral of round_key_reader is
    component blk_mem_gen_0
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
    
    signal new_addr : std_logic_vector(7 downto 0);
    
begin

    new_addr <= std_logic_vector(
        to_unsigned(
            (9 - (to_integer(unsigned(addr)) / 16)) * 16 + (to_integer(unsigned(addr)) mod 16),8));

    bram_inst : blk_mem_gen_0
        port map (
            clka  => clk,               
            ena   => '1',                
            wea   => "0",  
            addra => new_addr,              
            dina  => dina_const,                
            douta => dout               
        );


end Behavioral;
