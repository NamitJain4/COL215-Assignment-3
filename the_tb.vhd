library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SegDisplay_tb is
    -- No ports for the testbench
end SegDisplay_tb;

architecture Behavioral of SegDisplay_tb is

    -- Component declaration for SegDisplay
    component SegDisplay
        Port ( clk : in  STD_LOGIC;
               rst : in  STD_LOGIC;
               data_in : in  STD_LOGIC_VECTOR (31 downto 0);
               A,B,C,D,E,F,G : out STD_LOGIC;
               Digit_Select : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    -- Testbench signals
    signal clk_tb : STD_LOGIC := '0';                 -- Test clock signal
    signal rst_tb : STD_LOGIC := '0';                 -- Test reset signal
    signal data_in_tb : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');  -- Test data input
    signal A_tb, B_tb, C_tb, D_tb, E_tb, F_tb, G_tb : STD_LOGIC;  -- Segment outputs
    signal Digit_Select_tb : STD_LOGIC_VECTOR (3 downto 0);      -- Anode control outputs

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: SegDisplay
        Port map (
            clk => clk_tb,
            rst => rst_tb,
            data_in => data_in_tb,
            A => A_tb,
            B => B_tb,
            C => C_tb,
            D => D_tb,
            E => E_tb,
            F => F_tb,
            G => G_tb,
            Digit_Select => Digit_Select_tb
        );

    -- Clock generation process
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end process clk_process;

    -- Stimulus process to apply valid test inputs
    stimulus_process : process
    begin
        -- Apply reset
        rst_tb <= '1';
        wait for 20 ns;
        rst_tb <= '0';
        wait for 20 ns;

        -- Test case 1: Display hexadecimal 01234567 on the 7-segment display
        data_in_tb <= X"01234567";
        wait for 400 ns; -- Wait for several clock cycles to see the output

        -- Test case 2: Display hexadecimal 89ABCDEF
        data_in_tb <= "01100001011000100110001101100100";
        wait for 400 ns;

        -- Test case 3: Display hexadecimal 2468ACE0
        data_in_tb <= "00110010001101000011011000111000";
        wait for 400 ns;

        -- Test case 4: Display hexadecimal 13579BDF
        data_in_tb <= X"13579BDF";
        wait for 400 ns;

        -- Apply reset again
        rst_tb <= '1';
        wait for 20 ns;
        rst_tb <= '0';

        -- Stop the simulation
        wait;
    end process stimulus_process;

end Behavioral;
