----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2024 01:46:35 PM
-- Design Name: 
-- Module Name: xor_operation - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity xor_operation is
    Port (
        inp1 : in STD_LOGIC_VECTOR (7 downto 0);
        inp2 : in STD_LOGIC_VECTOR (7 downto 0);
        output : out STD_LOGIC_VECTOR (7 downto 0)
    );
end xor_operation;

architecture Behavioral of xor_operation is

begin
    output <= inp1 xor inp2;

end Behavioral;
