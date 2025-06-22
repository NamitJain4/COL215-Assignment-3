library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller is
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
end controller;

architecture Behavioral of controller is
     type state_type is (
         ReadInput, InvShiftRows, InvSubBytes, XOR_RoundKey,
         InvMixColumns, seg_display, WriteOutput, Completed
     );

     signal current_state, next_state  : state_type;
     signal internal_state, state_out            : std_logic_vector(127 downto 0) := (others => '0');

     component SegDisplay
         Port (
             clk          : in  STD_LOGIC;
             rst          : in  STD_LOGIC;
             data_in      : in  STD_LOGIC_VECTOR(31 downto 0);
             A, B, C, D, E, F, G : out STD_LOGIC;
             Digit_Select : out STD_LOGIC_VECTOR(3 downto 0)
         );
     end component;

     component xor_operation
         Port (
             inp1   : in  STD_LOGIC_VECTOR(7 downto 0);
             inp2   : in  STD_LOGIC_VECTOR(7 downto 0);
             output : out STD_LOGIC_VECTOR(7 downto 0)
         );
     end component;

     component inv_mix_columns
         Port (
             input_col  : in  std_logic_vector(31 downto 0);
             output_col : out std_logic_vector(31 downto 0)
         );
     end component;

     component inv_shift_rows
         Port (
             input  : in  std_logic_vector(31 downto 0);
             inp_row: in  std_logic_vector(1 downto 0);
             outpt  : out std_logic_vector(31 downto 0)
         );
     end component;

     component inv_sub_byte
         Port (
             clk : in std_logic;
             input_data  : in  std_logic_vector(7 downto 0);
             output_data : out std_logic_vector(7 downto 0)
         );
     end component;

     component round_key_reader
         Port (
           clk      : in  std_logic;
           addr     : in  std_logic_vector(7 downto 0);
           dout     : out std_logic_vector(7 downto 0)
         );
     end component;

    component blk_mem_gen_1
        Port (
            clka  : in  std_logic;
            ena   : in  std_logic;
            wea   : in  std_logic_vector(0 downto 0);
            addra : in  std_logic_vector(3 downto 0);
            dina  : in  std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;



     signal xor_in1, xor_in2, xor_out : std_logic_vector(7 downto 0) := (others => '0');

     signal input_inv_shift_rows, outpt_inv_shift_rows,
            input_col_inv_mix_columns, output_col_inv_mix_columns : std_logic_vector(31 downto 0) := (others => '0');

     signal inp_row_inv_shift_rows                               : std_logic_vector(1 downto 0) := "11";
     signal input_data_inv_sub_byte, output_data_inv_sub_byte    : std_logic_vector(7 downto 0) := (others => '0');
     signal data_in_seg_display                                  : std_logic_vector(31 downto 0) := (others => '0');

     signal xor_addr                                             : std_logic_vector(7 downto 0) := (others => '0');

     signal reset                                                : std_logic := '1';
     signal xor_counter                                          : integer := 0;
     signal inv_shift_rows_addr :  std_logic_vector (1 downto 0) := "00";
     signal inv_shift_rows_counter : integer := 0;
     --signal first_inv_shift_rows : std_logic := '1';
     signal inv_mix_columns_counter : integer := 0;
     signal inv_sub_byte_counter : integer := 0;
     signal round_counter : integer := 0;
     signal round_key : std_logic_vector (7 downto 0) := (others => '0');

     signal location : integer := 0;
     signal input_byte : std_logic_vector (7 downto 0) := (others => '0');
     signal output_byte : std_logic_vector (7 downto 0) := (others => '0');
     signal we : std_logic_vector (0 downto 0) := "0";

     signal waiting : integer := 4;

     signal read_input_counter : integer := 0;
     signal write_output_counter : integer := 0;

     signal seg_display_counter : integer := 0;
     signal seg_display_ratio : integer := 10;
     signal seg_display_digit : integer := 0;

     signal test : integer := 0;
     signal rst : std_logic := '0';

     signal initial_num_of_inputs : integer := 1;
     signal num_of_inputs_left : integer := 1;


begin
     -- Port mappings for xor_operation components
     xor_port : xor_operation
         port map (
             inp1   => xor_in1,
             inp2   => xor_in2,
             output => xor_out
         );

     -- Port mapping for SegDisplay component
     seg_display_port : SegDisplay
         port map (
             clk         => clk,
             rst         => rst,
             data_in     => data_in_seg_display,
             A           => a,
             B           => b,
             C           => c,
             D           => d,
             E           => e,
             F           => f,
             G           => g,
             Digit_Select => anode_sel
         );

     -- Port mapping for inv_mix_columns component
     inv_mix_columns_port : inv_mix_columns
         port map (
             input_col   => input_col_inv_mix_columns,
             output_col  => output_col_inv_mix_columns
         );

     -- Port mapping for inv_shift_rows component
     inv_shift_rows_port : inv_shift_rows
         port map (
             input   => input_inv_shift_rows,
             inp_row => not inp_row_inv_shift_rows,
             outpt   => outpt_inv_shift_rows
         );

     -- Port mapping for inv_sub_byte component
     inv_sub_byte_port : inv_sub_byte
         port map (
             clk => clk,
             input_data  => input_data_inv_sub_byte,
             output_data => output_data_inv_sub_byte
         );

     round_key_reader_port : round_key_reader
        port map (
            clk => clk,
            addr => xor_addr,
            dout => round_key
        );

    input_file_port : blk_mem_gen_1
        port map (
            clka  => clk,
            ena   => '1',
            wea   => we,
            addra => std_logic_vector(to_unsigned(location, 4)),
            dina  => input_byte,
            douta => output_byte
        );


     -- State Transition Process
     process(clk, reset)
     begin
         if reset = '1' then
             current_state <= ReadInput;
         elsif rising_edge(clk) then
             if waiting > 0 then
                waiting <= waiting - 1;
             else
                current_state <= next_state;
                test <= test + 1;
                waiting <= 4;
             end if;
         end if;
     end process;

     -- Next State Logic and Output Logic
     process(current_state, test)
     begin
         case current_state is
             when ReadInput =>
                if read_input_counter = 16 then
                    internal_state(127 - (8 * read_input_counter - 8) downto 127 - (8 * read_input_counter - 1)) <= output_byte;
                    next_state <= XOR_RoundKey;
                    read_input_counter <= 0;
                    location <= 0;
                else
                    if read_input_counter >= 1 then
                        internal_state(127 - (8 * read_input_counter - 8) downto 127 - (8 * read_input_counter - 1)) <= output_byte;
                    end if;
                    -- 4 * (read_input_counter mod 4) + (read_input_counter / 4)
                    location <= read_input_counter + 16 * (initial_num_of_inputs - num_of_inputs_left);    --- add some 16*counter
                    read_input_counter <= read_input_counter + 1;
                    next_state <= ReadInput;
                    if read_input_counter = 0 then
                        reset <= '0';
                    end if;
                end if;

             when InvShiftRows =>
                 -- Implement InvShiftRows logic here
                 if inv_shift_rows_counter = 4 then
                     internal_state(8 * inv_shift_rows_counter - 1 + 0 downto 8 * inv_shift_rows_counter - 8 + 0) <= outpt_inv_shift_rows (7 downto 0);
                     internal_state(8 * inv_shift_rows_counter - 1 + 32 downto 8 * inv_shift_rows_counter - 8 + 32) <= outpt_inv_shift_rows (15 downto 8);
                     internal_state(8 * inv_shift_rows_counter - 1 + 64 downto 8 * inv_shift_rows_counter - 8 + 64) <= outpt_inv_shift_rows (23 downto 16);
                     internal_state(8 * inv_shift_rows_counter - 1 + 96 downto 8 * inv_shift_rows_counter - 8 + 96) <= outpt_inv_shift_rows (31 downto 24);
                     next_state <= InvSubBytes;
                     inv_shift_rows_addr <= "00";
                     inv_shift_rows_counter <= 0;
                 else
                     if inv_shift_rows_counter > 0 then
                         internal_state(8 * inv_shift_rows_counter - 1 + 0 downto 8 * inv_shift_rows_counter - 8 + 0) <= outpt_inv_shift_rows (7 downto 0);
                         internal_state(8 * inv_shift_rows_counter - 1 + 32 downto 8 * inv_shift_rows_counter - 8 + 32) <= outpt_inv_shift_rows (15 downto 8);
                         internal_state(8 * inv_shift_rows_counter - 1 + 64 downto 8 * inv_shift_rows_counter - 8 + 64) <= outpt_inv_shift_rows (23 downto 16);
                         internal_state(8 * inv_shift_rows_counter - 1 + 96 downto 8 * inv_shift_rows_counter - 8 + 96) <= outpt_inv_shift_rows (31 downto 24);
                     end if;
                     inv_shift_rows_counter <= inv_shift_rows_counter + 1;
                     inv_shift_rows_addr <= inv_shift_rows_addr + 1;
                     input_inv_shift_rows <= internal_state(8 * inv_shift_rows_counter + 103 downto 8 * inv_shift_rows_counter + 96) & internal_state(8 * inv_shift_rows_counter + 71 downto 8 * inv_shift_rows_counter + 64) & internal_state(8 * inv_shift_rows_counter + 39 downto 8 * inv_shift_rows_counter + 32) & internal_state(8 * inv_shift_rows_counter + 7 downto 8 * inv_shift_rows_counter);
                     inp_row_inv_shift_rows <= inv_shift_rows_addr;
                     next_state <= InvShiftRows;
                 end if;

             when InvSubBytes =>
                 -- Implement InvSubBytes logic here
                 if inv_sub_byte_counter = 16 then
                     internal_state(8 * inv_sub_byte_counter - 1 downto 8 * inv_sub_byte_counter - 8) <= output_data_inv_sub_byte;
                     next_state <= XOR_RoundKey;
                     inv_sub_byte_counter <= 0;
                 else
                     if inv_sub_byte_counter > 0 then
                         internal_state(8 * inv_sub_byte_counter - 1 downto 8 * inv_sub_byte_counter - 8) <= output_data_inv_sub_byte;
                     end if;
                     inv_sub_byte_counter <= inv_sub_byte_counter + 1;
                     input_data_inv_sub_byte <= internal_state(8 * inv_sub_byte_counter + 7 downto 8 * inv_sub_byte_counter);
                     next_state <= InvSubBytes;
                 end if;

             when XOR_RoundKey =>

                 if xor_counter = 17 then
                     internal_state(127 - (8 * xor_counter - 16) downto 127 - (8 * xor_counter - 9)) <= xor_out;
                     round_counter <= round_counter + 1;
                     if round_counter = 0 then
                        next_state <= InvShiftRows;
                     elsif round_counter = 9 then
                        next_state <= WriteOutput;
                        -- next_state <= seg_display;
                        xor_addr <= (others => '0');
                        round_counter <= 0;
                     else
                        next_state <= InvMixColumns;
                     end if;
                     xor_counter <= 0;
                 else
                     if xor_counter > 1 then
                         internal_state(127 - (8 * xor_counter - 16) downto 127 - (8 * xor_counter - 9)) <= xor_out;
                     end if;
                     if xor_counter > 0 then
                        xor_in1 <= internal_state(127 - (8 * xor_counter - 8) downto 127 - (8 * xor_counter - 1));
                        xor_in2 <= round_key;
                        xor_addr <= xor_addr + 1;
                     end if;
                     xor_counter <= xor_counter + 1;
                     next_state <= XOR_RoundKey;
                 end if;

             when InvMixColumns =>
                 -- Implement InvMixColumns logic here
                 if inv_mix_columns_counter = 4 then
                     internal_state(127 - (32 * inv_mix_columns_counter - 32) downto 127 - (32 * inv_mix_columns_counter - 1)) <= output_col_inv_mix_columns;
                     next_state <= InvShiftRows;
                     inv_mix_columns_counter <= 0;
                 else
                     if inv_mix_columns_counter > 0 then
                        internal_state(127 - (32 * inv_mix_columns_counter - 32) downto 127 - (32 * inv_mix_columns_counter - 1)) <= output_col_inv_mix_columns;
                     end if;
                     inv_mix_columns_counter <= inv_mix_columns_counter + 1;
                     input_col_inv_mix_columns <= internal_state(127 - (32 * inv_mix_columns_counter + 0) downto 127 - (32 * inv_mix_columns_counter + 31));
                     next_state <= InvMixColumns;
                 end if;

             when WriteOutput =>
                if write_output_counter = 16 then
                    next_state <= seg_display;
                    location <= 0;
                    write_output_counter <= 0;
                    we <= "0";
                    rst<='0';

                else
                    we <= "1";
                    location <= write_output_counter + 16 * (initial_num_of_inputs - num_of_inputs_left);
                    input_byte <= internal_state (127 - (write_output_counter * 8) downto 127 - (write_output_counter * 8 + 7));
                    write_output_counter <= write_output_counter + 1;
                    next_state <= WriteOutput;
                end if;
                if write_output_counter = 0 then
                    state_out <= internal_state;
                end if;

             when seg_display =>
                 next_state <= seg_display;
                 if seg_display_counter = seg_display_ratio then
                    seg_display_digit <= seg_display_digit + 1;
                    seg_display_counter <= 0;
                    if seg_display_digit = 12 then
                        next_state <= Completed;
                        seg_display_digit <= 0;
                    end if;
                 else
                     if seg_display_counter = 0 then
                        data_in_seg_display <= internal_state (127 - (8 * seg_display_digit) downto 127 - (8 * seg_display_digit + 31));
                     end if;
                     seg_display_counter <= seg_display_counter + 1;
                 end if;

             when Completed =>
                if num_of_inputs_left > 1 then
                    next_state <= ReadInput;
                    num_of_inputs_left <= initial_num_of_inputs - 1;
                else
                    rst <= '1';
                    next_state <= Completed;
                end if;
                -- add some more counter and handle the variables properly

         end case;
     end process;
end Behavioral;