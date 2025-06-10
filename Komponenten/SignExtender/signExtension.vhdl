-- Laboratory RA solutions/versuch3
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

-- ========================================================================
-- Description:  Sign extender for a RV32I processor. Takes the entire instruction
--               and produces a 32-Bit value by sign-extending, shifting and piecing
--               together the immedate value in the instruction.
-- ========================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.constant_package.all;

entity signExtension is
    generic (
        g_word_width : integer := WORD_WIDTH
    );

    port (
        pi_instr                                                               : in  std_logic_vector(g_word_width - 1 downto 0);
        po_storeImm, po_immediateImm, po_unsignedImm, po_branchImm, po_jumpImm : out std_logic_vector(g_word_width - 1 downto 0) := (others => '0')
    );
end entity;

architecture arc of signExtension is
begin
    -- resize adds MSB to left when using signed type automatically

    -- i-type (bits 31-20)
    po_immediateImm <= std_logic_vector(
        resize(
            signed(pi_instr(31 downto 20)),
            32
        )
    );

    -- s-type (bits 31-25 and 11-7)
    po_storeImm <= std_logic_vector(
        resize(
            signed(pi_instr(31 downto 25) & pi_instr(11 downto 7)),
            32
        )
    );

    -- u-type does not represent offset or address but arbitrary bit pattern so no sign extension is needed
    -- u-type (bits 31-12 shifted left by 12 bits according to spec)
    po_unsignedImm <= pi_instr(31 downto 12) & "000000000000";

    -- for b/j-type, immediate is used to encode offsets in multiples of 2 (word aligned) so LSB is always 0 (even number)
    -- and omitted and has to be added manually according to spec

    -- b-type (bits 31, 7, 30-25 and 11-8 shifted one to left according to spec)
    po_branchImm <= std_logic_vector(
        resize(
            signed(pi_instr(31) & pi_instr(7) & pi_instr(30 downto 25) & pi_instr(11 downto 8) & '0'),
            32
        )
    );

    -- j-type (bits 31, 19-12, 20 and 30-21 shifted one to left according to spec)
    po_jumpImm <= std_logic_vector(
        resize(
            signed(pi_instr(31) & pi_instr(19 downto 12) & pi_instr(20) & pi_instr(30 downto 21) & '0'),
            32
        )
    );
end architecture;
