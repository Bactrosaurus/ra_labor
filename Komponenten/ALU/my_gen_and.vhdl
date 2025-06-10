-- Laboratory RA solutions/versuch1
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use work.Constant_Package.all;

entity my_gen_and is
    generic (
        g_data_width : integer := DATA_WIDTH_GEN
    );

    port (
        pi_op1, pi_op2 : in  std_logic_vector(g_data_width - 1 downto 0);
        po_res         : out std_logic_vector(g_data_width - 1 downto 0)
    );
end entity;

architecture behaviour of my_gen_and is
begin
    po_res <= pi_op1 and pi_op2;
end architecture;
