----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.09.2024 15:12:33
-- Design Name: 
-- Module Name: mux4x1_4bit - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux4x1 is
    Port (
        inp1 : in STD_LOGIC_VECTOR (7 downto 0);
        inp2 : in STD_LOGIC_VECTOR (7 downto 0);
        inp3 : in STD_LOGIC_VECTOR (7 downto 0);
        inp4 : in STD_LOGIC_VECTOR (7 downto 0);
        Sel : in STD_LOGIC_VECTOR (1 downto 0);
        output : out STD_LOGIC_VECTOR (7 downto 0)
    );
end mux4x1;

architecture Behavioral of mux4x1 is

begin
    multiplexer_proc : process (Sel)
    begin
        if Sel = "00" then
            output <= inp1;
        elsif Sel = "01" then
            output <= inp2;
        elsif Sel = "10" then
            output <= inp3;
        else
            output <= inp4;
        end if;
    end process;
end Behavioral;
