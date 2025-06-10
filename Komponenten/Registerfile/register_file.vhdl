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

entity register_file is
    generic (
        adr_width  : integer := REG_ADR_WIDTH;
        word_width : integer := WORD_WIDTH
    );

    port (
        pi_clk, pi_rst, pi_writeEnable                    : in  std_logic;
        pi_readRegAddr1, pi_readRegAddr2, pi_writeRegAddr : in  std_logic_vector(adr_width - 1 downto 0);
        pi_writeRegData                                   : in  std_logic_vector(word_width - 1 downto 0);
        po_readRegData1, po_readRegData2                  : out std_logic_vector(word_width - 1 downto 0);
        po_registerOut                                    : out registermemory
    );
end entity;

architecture behaviour of register_file is
    signal s_reg_file : registermemory                            := (others => (others => '0'));
    signal s_read1    : std_logic_vector(word_width - 1 downto 0) := (others => '0');
    signal s_read2    : std_logic_vector(word_width - 1 downto 0) := (others => '0');

begin
    -- logic of registerfile
    process (pi_clk, pi_rst)
    begin
        if pi_rst = '1' then -- reset
            s_reg_file <= (others => (others => '0'));
        elsif rising_edge(pi_clk) then
            s_read1 <= s_reg_file(to_integer(unsigned(pi_readRegAddr1)));
            s_read2 <= s_reg_file(to_integer(unsigned(pi_readRegAddr2)));

            if pi_writeEnable = '1' and to_integer(unsigned(pi_writeRegAddr)) /= 0 then -- writing
                s_reg_file(to_integer(unsigned(pi_writeRegAddr))) <= pi_writeRegData;
            end if;
        end if;
    end process;
    
    po_readRegData1 <= s_read1; -- async output
    po_readRegData2 <= s_read2;
    po_registerOut  <= s_reg_file;
end architecture;
