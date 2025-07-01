-- Laboratory RA solutions/versuch2
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use work.Constant_Package.all;

entity PipelineRegister is
    generic (
        g_register_width : integer := REG_ADR_WIDTH
    );

    port (
        pi_data                  : in  std_logic_vector(g_register_width - 1 downto 0) := (others => '0');
        pi_clk, pi_rst, pi_stall : in  std_logic                                       := '0';
        po_data                  : out std_logic_vector(g_register_width - 1 downto 0) := (others => '0')
    );
end entity;

architecture behaviour of PipelineRegister is
    signal s_reg : std_logic_vector(g_register_width - 1 downto 0) := (others => '0');

begin
    process (pi_clk, pi_rst)
    begin
        if pi_rst = '1' then
            s_reg <= (others => '0');
        elsif rising_edge(pi_clk) and pi_stall = '0' then
            s_reg <= pi_data;
        end if;
    end process;
    po_data <= s_reg;
end architecture;
