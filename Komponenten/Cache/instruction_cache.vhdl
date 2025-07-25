-- Laboratory RA solutions/versuch4
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

-- ========================================================================
-- Author:       Marcel Riess
-- Last updated: 14.05.2025
-- Description:  Generic instruction cache (read only) with debug port,
--               to allow writing data in testbenches
-- ========================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.constant_package.all;
    use work.types.all;

entity instruction_cache is
    generic (
        adr_width : integer := ADR_WIDTH -- Address Bus width of instruction memory (in RISCVI: 32)
        -- mem_size  : integer := 2 ** 10    -- Size of instruction cache
    );
    port (
        pi_adr              : in  std_logic_vector(adr_width - 1 downto 0)  := (others => '0'); -- Adress of the instruction to select
        pi_clk              : in  std_logic                                 := '0';
        pi_rst              : in  std_logic                                 := '0';
        pi_instructionCache : in  memory                                    := (others => (others => '0'));
        po_instruction      : out std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0')  -- Selected instruction
    );
end entity;

architecture behavior of instruction_cache is
    signal instructions : memory := (others => (others => '0'));

begin
    process (pi_clk) is
    begin
        if rising_edge(pi_clk) then
            instructions <= pi_instructionCache;
            if pi_rst = '1' then
                instructions <= (others => (others => '0'));
            end if;
            po_instruction <= instructions(to_integer(unsigned(pi_adr(adr_width - 1 downto 2))));
        end if;
    end process;
end architecture;
