-- Laboratory RA solutions/versuch1
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use work.Constant_Package.all;

entity my_full_adder is
    port (
        pi_a, pi_b, pi_carry : in  std_logic;
        po_sum, po_carry     : out std_logic
    );
end entity;

architecture behaviour of my_full_adder is
begin
    -- simplified transfer function of full adder
    po_sum   <= pi_a xor pi_b xor pi_carry;
    po_carry <= (pi_carry and (pi_a xor pi_b)) or (pi_a and pi_b);
end architecture;
