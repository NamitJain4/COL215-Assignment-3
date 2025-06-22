library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SegDisplay is
    Port (
        clk : in  STD_LOGIC;              -- Clock signal
        rst : in  STD_LOGIC;              -- Reset signal
        data_in : in  STD_LOGIC_VECTOR (31 downto 0);  -- Input data (32-bit)
        A, B, C, D, E, F, G : out STD_LOGIC;  -- Outputs for the seven segments
        Digit_Select : out STD_LOGIC_VECTOR (3 downto 0)  -- Digit selector (Anode control)
    );
end SegDisplay;

architecture Behavioral of SegDisplay is
    signal digit_counter : STD_LOGIC_VECTOR(1 downto 0) := "00";  -- To select which digit to display
    signal clock_divider : INTEGER := 0;                          -- To slow down the clock for display updates
    signal segment_out : STD_LOGIC_VECTOR(6 downto 0);            -- Holds segment patterns for the 7-segment display
    signal max_count : INTEGER := 40;

 -- Function to map hexadecimal value to 7-segment display pattern using if-elsif
    function hex_to_segments(hex_val : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable seg_pattern : STD_LOGIC_VECTOR(6 downto 0);
    begin
        if hex_val = X"30" then
            seg_pattern := "0000001"; -- 0
        elsif hex_val = X"31" then
            seg_pattern := "1001111"; -- 1
        elsif hex_val = X"32" then
            seg_pattern := "0010010"; -- 2
        elsif hex_val = X"33" then
            seg_pattern := "0000110"; -- 3
        elsif hex_val = X"34" then
            seg_pattern := "1001100"; -- 4
        elsif hex_val = X"35" then
            seg_pattern := "0100100"; -- 5
        elsif hex_val = X"36" then
            seg_pattern := "0100000"; -- 6
        elsif hex_val = X"37" then
            seg_pattern := "0001111"; -- 7
        elsif hex_val = X"38" then
            seg_pattern := "0000000"; -- 8
        elsif hex_val = X"39" then
            seg_pattern := "0000100"; -- 9
        elsif hex_val = X"41" or hex_val = X"61" then
            seg_pattern := "0001000"; -- A
        elsif hex_val = X"42" or hex_val = X"62" then
            seg_pattern := "1100000"; -- B
        elsif hex_val = X"43" or hex_val = X"63" then
            seg_pattern := "0110001"; -- C
        elsif hex_val = X"44" or hex_val = X"64" then
            seg_pattern := "1000010"; -- D
        elsif hex_val = X"45" or hex_val = X"65" then
            seg_pattern := "0110000"; -- E
        elsif hex_val = X"46" or hex_val = X"66" then
            seg_pattern := "0111000"; -- F
        else
            seg_pattern := "1111110"; -- Default case, dash
        end if;
        return seg_pattern;
    end function;
    

begin

    run: process(clk, rst)
    begin
        if rst = '1' then
            segment_out <= (others => '0'); -- Clear all segments on reset
            Digit_select <= "1111";
--            Digit_Select <= "1110";         -- Disable all digits
--            A <= '1';
--            B <= '0';
--            C <= '0';
--            D <= '1';
--            E <= '1';
--            F <= '1';
--            G <= '1';
            
        elsif rising_edge(clk) then
            -- Clock divider to reduce update rate
            if clock_divider = max_count then
                clock_divider <= 0;
                digit_counter <= digit_counter + 1;
            else
                clock_divider <= clock_divider + 1;
            end if;

            if digit_counter = "00" then
                Digit_Select <= "0111";
                segment_out <= hex_to_segments(data_in(31 downto 24));
            elsif digit_counter = "01" then
                Digit_Select <= "1011";
                segment_out <= hex_to_segments(data_in(23 downto 16));
            elsif digit_counter = "10" then
                Digit_Select <= "1101";
                segment_out <= hex_to_segments(data_in(15 downto 8));
            elsif digit_counter = "11" then
                Digit_Select <= "1110";
                segment_out <= hex_to_segments(data_in(7 downto 0));
            else
                segment_out <= "0000000";
                Digit_Select <= "1111";
            end if;
            
            A <= segment_out(6);
            B <= segment_out(5);
            C <= segment_out(4);
            D <= segment_out(3);
            E <= segment_out(2);
            F <= segment_out(1);
            G <= segment_out(0);
        end if;
    end process;

end Behavioral;