-- Laboratory RA solutions/versuch2
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;
    use work.constant_package.all;
    use work.types.all;

entity Single_Port_RAM is
    generic (
        g_reg_adr_width : integer := REG_ADR_WIDTH;
        g_word_width    : integer := WORD_WIDTH
    );

    port (
        pi_clk, pi_rst, pi_we : in  std_logic;
        pi_addr               : in  std_logic_vector(g_reg_adr_width - 1 downto 0);
        pi_data               : in  std_logic_vector(g_word_width - 1 downto 0);
        po_data               : out std_logic_vector(g_word_width - 1 downto 0)
    );
end entity;

architecture behaviour of Single_Port_RAM is
    type ram is array (0 to 2 ** g_reg_adr_width - 1) of std_logic_vector(g_word_width - 1 downto 0);
    signal s_reg : ram := (others => (others => '0'));

begin
    -- process for synchronous logic of single port RAM
    process (pi_clk, pi_rst)
    begin
        if pi_rst = '1' then
            s_reg <= (others => (others => '0')); -- reset RAM to 0
        elsif rising_edge(pi_clk) then
            if pi_we = '1' then -- when writing enabled
                s_reg(to_integer(unsigned(pi_addr))) <= pi_data;
            end if;
            po_data <= s_reg(to_integer(unsigned(pi_addr))); -- synchronous output on rising edge
        end if;
    end process;
end architecture;
