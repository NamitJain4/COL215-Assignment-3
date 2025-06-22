----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.10.2024 14:47:34
-- Design Name: 
-- Module Name: inv_mix_cols - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inv_mix_columns is
     port(
         input_col  : in std_logic_vector(31 downto 0);  -- 4 bytes column input
         output_col : out std_logic_vector(31 downto 0)  -- 4 bytes column output
     );
end inv_mix_columns;

architecture behavioral of inv_mix_columns is

     -- Function to multiply a byte by a constant in GF(2^8)
     function gmul(a : std_logic_vector(7 downto 0); b : 
std_logic_vector(7 downto 0)) return std_logic_vector is
         variable p : std_logic_vector(7 downto 0) := (others => '0');
         variable hi_bit_set : std_logic;
         variable a_var : std_logic_vector(7 downto 0) := a;
         variable b_var : std_logic_vector(7 downto 0) := b;
     begin
         for i in 0 to 7 loop
             if b_var(0) = '1' then
                 p := p xor a_var;  -- If least significant bit of b is 1, XOR p with a
             end if;
             hi_bit_set := a_var(7);  -- Get the high bit of a
             a_var := std_logic_vector(shift_left(unsigned(a_var), 1));  -- Shift a to the left
             if hi_bit_set = '1' then
                 a_var := a_var xor "00011011";  -- GF(2^8) mod x^8 + x^4 + x^3 + x + 1
             end if;
             b_var := std_logic_vector(shift_right(unsigned(b_var), 1));  -- Shift b to the right
         end loop;
         return p;
     end function;

     signal c0, c1, c2, c3 : std_logic_vector(7 downto 0);
     signal col0, col1, col2, col3 : std_logic_vector(7 downto 0);

begin

     -- Split the input column into 4 bytes
     c0 <= input_col(31 downto 24);
     c1 <= input_col(23 downto 16);
     c2 <= input_col(15 downto 8);
     c3 <= input_col(7 downto 0);

     -- Apply the inverse MixColumns matrix
     col0 <= gmul(c0, "00001110") xor gmul(c1, "00001011") xor gmul(c2, "00001101") xor gmul(c3, "00001001");
     col1 <= gmul(c0, "00001001") xor gmul(c1, "00001110") xor gmul(c2, "00001011") xor gmul(c3, "00001101");
     col2 <= gmul(c0, "00001101") xor gmul(c1, "00001001") xor gmul(c2, "00001110") xor gmul(c3, "00001011");
     col3 <= gmul(c0, "00001011") xor gmul(c1, "00001101") xor gmul(c2, "00001001") xor gmul(c3, "00001110");

     -- Combine the output column
     output_col <= col0 & col1 & col2 & col3;

end architecture behavioral;


