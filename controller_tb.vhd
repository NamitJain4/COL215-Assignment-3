----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/08/2024 02:45:43 PM
-- Design Name: 
-- Module Name: controller_tb - Behavioral
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

entity controller_tb is
--  Port ( );
end controller_tb;

architecture Behavioral of controller_tb is

    component controller is
     Port (
         clk        : in  std_logic;
         a          : out std_logic;
         b          : out std_logic;
         c          : out std_logic;
         d          : out std_logic;
         e          : out std_logic;
         f          : out std_logic;
         g          : out std_logic;
         anode_sel  : out std_logic_vector (3 downto 0)
     );
end component;
    
    signal clk_period : time := 20 ns;
    signal clk : std_logic := '0';
    signal output : std_logic_vector (127 downto 0);
    signal a          :  std_logic;
     signal    b          :  std_logic;
     signal    c          :  std_logic;
     signal    d          :  std_logic;
     signal    e          :  std_logic;
     signal    f          :  std_logic;
     signal    g          :  std_logic;
     signal    anode_sel  :  std_logic_vector (3 downto 0);
--     signal test       : integer :=0;

begin
    
    DUT_counter : controller
        port map (
            clk => clk,
--            state_out => output
            a =>a,b=>b,c=>c,d=>d,e=>e,f=>f,g=>g,anode_sel=>anode_sel
        );

    clk_process :process
    begin
        while True loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;


end Behavioral;
