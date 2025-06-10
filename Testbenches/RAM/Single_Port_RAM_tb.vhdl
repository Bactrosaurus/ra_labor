-- Laboratory RA solutions/versuch2
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
use std.env.all; -- for stop;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.constant_package.all;

entity Single_Port_RAM_tb is
end entity;

architecture behavior of Single_Port_RAM_tb is
    signal s_clk, s_rst, s_writeEnabled : std_logic := '0';
    signal s_addr, s_dataIn, s_dataOut  : std_logic_vector(15 downto 0) := (others => '0');
    constant CLK_PERIOD : time := 1 ns;

begin
    -- clock process
    clk_proc: process
    begin
        while true loop
            s_clk <= '0';
            wait for CLK_PERIOD / 2;
            s_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    ram: entity work.Single_Port_RAM
        generic map (g_reg_adr_width => 16, g_word_width => 16)
        port map (
        pi_clk => s_clk,
        pi_rst => s_rst,
        pi_we => s_writeEnabled,
        pi_addr => s_addr,
        pi_data => s_dataIn,
        po_data => s_dataOut
        );

    -- stimulus process
    stim_proc: process
    begin
        -- reset
        s_rst <= '1';
        wait until rising_edge(s_clk);
        s_rst <= '0';
        wait until rising_edge(s_clk);

        -- enable write
        s_writeEnabled <= '1';
        wait until rising_edge(s_clk);

        -- write to all addresses
        for i in 0 to (2 ** 16 - 1) loop
            s_addr <= std_logic_vector(to_unsigned(i, 16));
            s_dataIn <= std_logic_vector(to_unsigned(i, 16));
            wait until rising_edge(s_clk);
        end loop;

        -- disable write
        s_writeEnabled <= '0';
        wait until rising_edge(s_clk);

        -- read all written data and confirm it's correct
        for i in 0 to (2 ** 16 - 1) loop
            s_addr <= std_logic_vector(to_unsigned(i, 16));
            wait until rising_edge(s_clk);
            wait for 1 ns; -- wait for value being visible at output
            assert s_dataOut = std_logic_vector(to_unsigned(i, 16)) report "data incorrect!" severity error;
        end loop;
        report "test completed" severity note;
        stop;
    end process;
end architecture;
