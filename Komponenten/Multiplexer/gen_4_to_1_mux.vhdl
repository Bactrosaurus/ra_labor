-- Laboratory RA solutions/versuch6
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use work.Constant_Package.all;

entity four_to_one_mux is
    generic (
        dataWidth : integer := DATA_WIDTH_GEN
    );

    port (
        pi_1, pi_2, pi_3, pi_4 : in  std_logic_vector(dataWidth - 1 downto 0);
        pi_sel                 : in  std_logic_vector(1 downto 0);
        po_res                 : out std_logic_vector(dataWidth - 1 downto 0) := (others => '0')
    );
end entity;

architecture behaviour of four_to_one_mux is
begin
    with pi_sel select
        po_res <= pi_1                    when "00",
                  pi_2                    when "01",
                  pi_3                    when "10",
                  pi_4                    when "11",
                          (others => '0') when others;
end architecture;
