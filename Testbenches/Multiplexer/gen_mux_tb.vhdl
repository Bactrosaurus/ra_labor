-- Authors: Daniel Schwenkkrauß & Daniel Auberer

library ieee;
use ieee.std_logic_1164.all;
use work.Constant_Package.all;

entity gen_mux_tb is
end entity gen_mux_tb;

architecture behaviour of gen_mux_tb is
    signal s_first, s_second : std_logic_vector(31 downto 0) := (others => '0');
    signal s_sel : std_logic := '0';

    signal s_res_5 : std_logic_vector(4 downto 0) := (others => '0');
    signal s_res_6 : std_logic_vector(5 downto 0) := (others => '0');
    signal s_res_8 : std_logic_vector(7 downto 0) := (others => '0');
    signal s_res_16 : std_logic_vector(15 downto 0) := (others => '0');
    signal s_res_32 : std_logic_vector(31 downto 0) := (others => '0');

begin
    mux_5: entity work.Multiplexer
        generic map (dataWidth => 5)
        port map (
        pi_first => s_first(4 downto 0),
        pi_second => s_second(4 downto 0),
        pi_sel => s_sel,
        po_res => s_res_5
        );

    mux_6: entity work.Multiplexer
        generic map (dataWidth => 6)
        port map (
        pi_first => s_first(5 downto 0),
        pi_second => s_second(5 downto 0),
        pi_sel => s_sel,
        po_res => s_res_6
        );

    mux_8: entity work.Multiplexer
        generic map (dataWidth => 8)
        port map (
        pi_first => s_first(7 downto 0),
        pi_second => s_second(7 downto 0),
        pi_sel => s_sel,
        po_res => s_res_8
        );

    mux_16: entity work.Multiplexer
        generic map (dataWidth => 16)
        port map (
        pi_first => s_first(15 downto 0),
        pi_second => s_second(15 downto 0),
        pi_sel => s_sel,
        po_res => s_res_16
        );

    mux_32: entity work.Multiplexer
        generic map (dataWidth => 32)
        port map (
        pi_first => s_first(31 downto 0),
        pi_second => s_second(31 downto 0),
        pi_sel => s_sel,
        po_res => s_res_32
        );

    -- stimulus process
    test_proc: process
        variable v_test_num_1 : std_logic_vector(31 downto 0);
        variable v_test_num_2 : std_logic_vector(31 downto 0);
        type t_test_nums is array(0 to 5, 0 to 1) of std_logic_vector(31 downto 0);
        variable v_test_nums : t_test_nums;
    begin
        v_test_nums(0, 0) := "10101010111010100100101010101011";
        v_test_nums(0, 1) := "10101010111010111000101010101011";

        v_test_nums(1, 0) := "10101010101010011111010010000001";
        v_test_nums(1, 1) := "10101010101010010111010010000001";

        v_test_nums(2, 0) := "11111111111100001001010100110101";
        v_test_nums(2, 1) := "11111111100000001001010100110101";

        v_test_nums(3, 0) := "01010101000000000000101011011111";
        v_test_nums(3, 1) := "01010101000100000000101011011111";

        v_test_nums(4, 0) := "11111110101010010101001110100000";
        v_test_nums(4, 1) := "11111110101100010101001110100000";

        v_test_nums(5, 0) := "10000100000000000000001111110010";
        v_test_nums(5, 1) := "10000100000000100100001111110010";

        for i in 0 to 5 loop
            v_test_num_1 := v_test_nums(i, 0);
            v_test_num_2 := v_test_nums(i, 1);
            wait for 20 ns;
            s_first <= v_test_num_1;
            s_second <= v_test_num_2;
            s_sel <= '0';
            wait for 20 ns;
            assert s_res_5 = v_test_num_1(4 downto 0) report "5 bit mux error" severity error;
            assert s_res_6 = v_test_num_1(5 downto 0) report "6 bit mux error" severity error;
            assert s_res_8 = v_test_num_1(7 downto 0) report "8 bit mux error" severity error;
            assert s_res_16 = v_test_num_1(15 downto 0) report "16 bit mux error" severity error;
            assert s_res_32 = v_test_num_1 report "32 bit mux error" severity error;

            s_sel <= '1';
            wait for 20 ns;
            wait for 20 ns;
            assert s_res_5 = v_test_num_2(4 downto 0) report "5 bit mux error" severity error;
            assert s_res_6 = v_test_num_2(5 downto 0) report "6 bit mux error" severity error;
            assert s_res_8 = v_test_num_2(7 downto 0) report "8 bit mux error" severity error;
            assert s_res_16 = v_test_num_2(15 downto 0) report "16 bit mux error" severity error;
            assert s_res_32 = v_test_num_2 report "32 bit mux error" severity error;
        end loop;

        report "Alle Tests erfolgreich." severity note;
        wait;
    end process test_proc;
end behaviour;
