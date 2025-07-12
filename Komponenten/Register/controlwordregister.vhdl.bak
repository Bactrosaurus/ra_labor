-- Laboratory RA solutions/versuch4
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

-- ========================================================================
-- Author:       Niklas Gutsmiedl
-- Last updated: 02.2024
-- Description:  Register to hold signals of type controlWord,
--               as defined in types.vhdl. Used as phase registers  
--               for the control path in the RV pipeline
-- ========================================================================
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use IEEE.MATH_REAL.all;
    use work.Constant_Package.all;
    use work.types.all;

entity ControlWordRegister is
    port (
        pi_rst, pi_clk, pi_stall : in  std_logic := '0';
        pi_controlWord   : in  controlWord := CONTROL_WORD_INIT; -- incoming control word
        po_controlWord   : out controlWord := CONTROL_WORD_INIT  -- outgoing control word
    );
end entity;

architecture arc1 of ControlWordRegister is
    signal s_controlWord : controlWord := CONTROL_WORD_INIT;

begin
    process (pi_clk, pi_rst)
    begin
        if (pi_rst) then
            s_controlWord <= CONTROL_WORD_INIT;
        elsif rising_edge(pi_clk) and pi_stall = '0' then
            s_controlWord <= pi_controlWord; -- update register contents on falling clock edge
        end if;
    end process;
    po_controlWord <= s_controlWord;
end architecture;
