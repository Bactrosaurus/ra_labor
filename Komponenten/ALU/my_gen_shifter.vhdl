-- Laboratory RA solutions/versuch1
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.Constant_Package.all;

entity my_gen_shifter is
    generic (
        g_data_width : integer := DATA_WIDTH_GEN
    );

    port (
        pi_data, pi_shift_amt       : in  std_logic_vector(g_data_width - 1 downto 0);
        pi_shift_type, pi_shift_dir : in  std_logic; -- type 0=logical 1=arithmetic; dir 0=left 1=right
        po_res                      : out std_logic_vector(g_data_width - 1 downto 0)
    );
end entity;

architecture behaviour of my_gen_shifter is
begin
    process (pi_data, pi_shift_amt, pi_shift_dir, pi_shift_type)
        variable v_tmp           : std_logic_vector(g_data_width - 1 downto 0);
        variable v_msb           : std_logic;
        variable v_shift_amt_int : integer;
    begin
        v_tmp := (others => '0');
        v_msb := pi_data(g_data_width - 1);
        
        -- convert shift amount vector to integer
        -- shift amounts are never larger than 5 bits, so we only take the first 5
        -- to make sure that the SRAI and SRLI instructions are interpreted correctly
        v_shift_amt_int := to_integer(unsigned(pi_shift_amt(4 downto 0)));

        if pi_shift_dir = '0' then -- shift left (logical and arithmetic are the same here)
            if v_shift_amt_int < g_data_width then
                v_tmp(g_data_width - 1 downto v_shift_amt_int) := pi_data(g_data_width - 1 - v_shift_amt_int downto 0);
                v_tmp(v_shift_amt_int - 1 downto 0) := (others => '0');
            else
                v_tmp := (others => '0');
            end if;
        else -- shift right
            if v_shift_amt_int < g_data_width then
                v_tmp(g_data_width - 1 - v_shift_amt_int downto 0) := pi_data(g_data_width - 1 downto v_shift_amt_int);
                if pi_shift_type = '0' then -- logical shift
                    v_tmp(g_data_width - 1 downto g_data_width - v_shift_amt_int) := (others => '0');
                else -- arithmetic shift
                    v_tmp(g_data_width - 1 downto g_data_width - v_shift_amt_int) := (others => v_msb);
                end if;
            else
                if pi_shift_type = '0' then
                    v_tmp := (others => '0');
                else
                    v_tmp := (others => v_msb);
                end if;
            end if;
        end if;

        po_res <= v_tmp;
    end process;
end architecture;
