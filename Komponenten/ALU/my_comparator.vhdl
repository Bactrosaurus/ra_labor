-- Laboratory RA solutions/versuch5
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.Constant_Package.all;

entity my_comparator is
    generic (
        g_data_width   : integer   := DATA_WIDTH_GEN;
        g_use_unsigned : std_logic := '0'
    );

    port (
        pi_op1, pi_op2 : in  std_logic_vector(g_data_width - 1 downto 0);
        po_res         : out std_logic_vector(g_data_width - 1 downto 0)
    );
end entity;

architecture behaviour of my_comparator is
begin
    po_res <= (0 => '1', others => '0') when
    -- attention if <= is used here!
        (g_use_unsigned = '1' and unsigned(pi_op1) < unsigned(pi_op2)) or
        (g_use_unsigned = '0' and signed(pi_op1) < signed(pi_op2))
        else (others => '0');
end architecture;
