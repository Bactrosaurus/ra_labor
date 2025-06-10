-- Laboratory RA solutions/versuch1
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use work.Constant_Package.all;

entity Multiplexer is
    generic (
        dataWidth : integer := DATA_WIDTH_GEN
    );

    port (
        pi_first, pi_second : in  std_logic_vector(dataWidth - 1 downto 0);
        pi_sel              : in  std_logic;
        po_res              : out std_logic_vector(dataWidth - 1 downto 0) := (others => '0')
    );
end entity;

architecture behaviour of Multiplexer is
begin
    with pi_sel select
        po_res <= pi_first                when '0',
                  pi_second               when '1',
                          (others => '0') when others;
end architecture;
