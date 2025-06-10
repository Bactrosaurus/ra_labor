-- Laboratory RA solutions/versuch1
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use work.Constant_Package.all;

entity my_gen_full_adder is
    generic (
        g_data_width : integer := DATA_WIDTH_GEN
    );

    port (
        pi_a, pi_b : in  std_logic_vector(g_data_width - 1 downto 0) := (others => '0');
        pi_carry   : in  std_logic;
        po_sum     : out std_logic_vector(g_data_width - 1 downto 0) := (others => '0');
        po_carry   : out std_logic
    );
end entity;

architecture behaviour of my_gen_full_adder is
    signal s_carry : std_logic_vector(g_data_width downto 0) := (others => '0');
    signal s_b     : std_logic_vector(g_data_width - 1 downto 0);

begin
    -- invert pi_b and save in s_b when carry is 1 (for subtraction)
    process (pi_b, pi_carry)
    begin
        if pi_carry = '0' then
            s_b <= pi_b; -- normal addition
        else
            s_b <= not pi_b; -- pi_b inverted
        end if;
    end process;

    full_adders: for i in 0 to g_data_width - 1 generate
        -- first full adder with pi_carry as input
        first_adder: if i = 0 generate
            adder: entity work.my_full_adder port map (pi_a(i), s_b(i), pi_carry, po_sum(i), s_carry(i + 1));
        end generate;

        -- last full adder with po_carry as output
        last_adder: if i = g_data_width - 1 generate
            adder: entity work.my_full_adder port map (pi_a(i), s_b(i), s_carry(i), po_sum(i), po_carry);
        end generate;

        -- middle adders
        mid_adders: if i /= g_data_width - 1 and i /= 0 generate
            adder: entity work.my_full_adder port map (pi_a(i), s_b(i), s_carry(i), po_sum(i), s_carry(i + 1));
        end generate;
    end generate;
end architecture;
