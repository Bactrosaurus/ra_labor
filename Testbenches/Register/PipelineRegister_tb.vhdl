-- Authors: Daniel Schwenkkrauß & Daniel Auberer

library ieee;
use ieee.std_logic_1164.all;
use work.Constant_Package.all;

entity my_pipeline_tb is
end entity my_pipeline_tb;

architecture behaviour of my_pipeline_tb is
    signal reg_in_32 : std_logic_vector(31 downto 0) := (others => '0'); -- 32 bit register input

    signal reg_out_5 : std_logic_vector(4 downto 0) := (others => '0');
    signal reg_out_6 : std_logic_vector(5 downto 0) := (others => '0');
    signal reg_out_8 : std_logic_vector(7 downto 0) := (others => '0');
    signal reg_out_16 : std_logic_vector(15 downto 0) := (others => '0');
    signal reg_out_32 : std_logic_vector(31 downto 0) := (others => '0');

    signal s_clk : std_logic := '0'; -- clock signal
    signal s_rst : std_logic := '0'; -- reset signal

begin
    -- clock process (clk period 20 ns - 100 cycles)
    clk_process: process
    begin
        for i in 0 to 99 loop
            s_clk <= '0';
            wait for 10 ns;
            s_clk <= '1';
            wait for 10 ns;
        end loop;
    end process;

    reg_5: entity work.PipelineRegister
        generic map (g_register_width => 5)
        port map (pi_data => reg_in_32(4 downto 0), pi_clk => s_clk, pi_rst => s_rst, po_data => reg_out_5);

    reg_6: entity work.PipelineRegister
        generic map (g_register_width => 6)
        port map (pi_data => reg_in_32(5 downto 0), pi_clk => s_clk, pi_rst => s_rst, po_data => reg_out_6);

    reg_8: entity work.PipelineRegister
        generic map (g_register_width => 8)
        port map (pi_data => reg_in_32(7 downto 0), pi_clk => s_clk, pi_rst => s_rst, po_data => reg_out_8);

    reg_16: entity work.PipelineRegister
        generic map (g_register_width => 16)
        port map (pi_data => reg_in_32(15 downto 0), pi_clk => s_clk, pi_rst => s_rst, po_data => reg_out_16);

    reg_32: entity work.PipelineRegister
        generic map (g_register_width => 32)
        port map (pi_data => reg_in_32, pi_clk => s_clk, pi_rst => s_rst, po_data => reg_out_32);

    -- stimulus process
    test_proc: process
        variable v_test_num : std_logic_vector(31 downto 0);
        type t_test_nums is array(0 to 5) of std_logic_vector(31 downto 0);
        variable v_test_nums : t_test_nums;
    begin
        v_test_nums(0) := "10101010111010100100101010101011";
        v_test_nums(1) := "10101010101010011111010010000001";
        v_test_nums(2) := "11111111111100001001010100110101";
        v_test_nums(3) := "01010101000000000000101011011111";
        v_test_nums(4) := "11111110101010010101001110100000";
        v_test_nums(5) := "10000100000000000000001111110010";

        for i in 0 to 5 loop
            v_test_num := v_test_nums(i);
            s_rst <= '0';
            wait for 20 ns;
            reg_in_32 <= v_test_num;
            wait for 20 ns;
            assert reg_out_5 = v_test_num(4 downto 0) report "5 bit reg error" severity error;
            assert reg_out_6 = v_test_num(5 downto 0) report "6 bit reg error" severity error;
            assert reg_out_8 = v_test_num(7 downto 0) report "8 bit reg error" severity error;
            assert reg_out_16 = v_test_num(15 downto 0) report "16 bit reg error" severity error;
            assert reg_out_32 = v_test_num report "32 bit reg error" severity error;
        end loop;

        report "Alle Tests erfolgreich." severity note;
        wait;
    end process test_proc;
end behaviour;
