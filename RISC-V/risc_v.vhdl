library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.constant_package.all;
    use work.types.all;
    use work.util_asm_package.all;

entity riscv is
    port (
        KEY                                : in  std_logic_vector(1 downto 0);
        SW                                 : in  std_logic_vector(9 downto 0);
        LEDR                               : out std_logic_vector(7 downto 0);
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : out std_logic_vector(6 downto 0)
    );
end entity;

architecture arc of riscv is
    signal s_rst          : std_logic                                 := '0';
    signal s_clk          : std_logic                                 := '0';
    signal s_registersOut : registermemory                            := (others => (others => '0'));
    signal s_instructions : memory                                    := (others => (others => '0'));
    signal seg_patterns   : seg_patterns                              := (others => (others => '0'));
    signal s_instrIF      : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
begin
    riscv: entity work.riubs_bp_lu_only_RISC_V
        port map (
            pi_rst             => s_rst,
            pi_clk             => s_clk,
            pi_instruction     => s_instructions,
            po_registersOut    => s_registersOut,
            po_debugdatamemory => open,
            po_instrIF         => s_instrIF
        );

    s_rst            <= not KEY(0);
    s_clk            <= KEY(1);
    LEDR(7 downto 0) <= s_registersOut(to_integer(unsigned(SW(4 downto 0))))(7 downto 0);

    gen_decoder: for i in 0 to 5 generate
        decoder_inst: entity work.hex_7seg_decoder
            port map (
                bin_in  => s_instrIF((i * 4 + 3) downto i * 4),
                seg_out => seg_patterns(i)
            );
    end generate;

    HEX0 <= seg_patterns(0);
    HEX1 <= seg_patterns(1);
    HEX2 <= seg_patterns(2);
    HEX3 <= seg_patterns(3);
    HEX4 <= seg_patterns(4);
    HEX5 <= seg_patterns(5);

    s_instructions(1)  <= Asm2Std("ADDI", 1, 0, 9);
    s_instructions(2)  <= Asm2Std("ADDI", 2, 0, 8);
    s_instructions(3)  <= Asm2Std("OR", 10, 1, 2);
    s_instructions(4)  <= Asm2Std("ADD", 8, 1, 2);
    s_instructions(5)  <= Asm2Std("SUB", 11, 1, 2);
    s_instructions(6)  <= Asm2Std("SUB", 12, 2, 1);
    s_instructions(7)  <= Asm2Std("ADD", 12, 2, 8);
    s_instructions(8)  <= Asm2Std("SUB", 12, 2, 1);
    s_instructions(9)  <= Asm2Std("AND", 1, 2, 1);
    s_instructions(10) <= Asm2Std("XOR", 12, 1, 2);
    s_instructions(11) <= Asm2Std("LUI", 13, 8, 0);
    s_instructions(12) <= Asm2Std("LUI", 13, 29, 0);
    s_instructions(13) <= Asm2Std("AUIPC", 14, 1, 0);
    s_instructions(14) <= Asm2Std("AUIPC", 14, 1, 0);

    -- Fibonacci Algorithmus

    -- int a = 0;        // a = x1
    -- int b = 1;        // b = x2
    -- int temp;         // temp = x3
    -- int i = 2;        // i = x4
    -- int n = 10;       // n =  x6
    -- int result;       // result = to x5

    -- while (i < n) {
    --     temp = a + b; // x3 = x1 + x2
    --     a = b;        // x1 = x2
    --     b = temp;     // x2 = x3
    --     i++;          // x4 = x4 + 1
    -- }

    -- result = b;       // x5 = x2

    -- s_instructions(1) <= Asm2Std("ADDI", 1, 0, 0); -- x1 = 0
    -- s_instructions(2) <= Asm2Std("ADDI", 2, 0, 1); -- x2 = 1
    -- s_instructions(3) <= Asm2Std("ADDI", 4, 0, 2); -- x4 = 2
    -- s_instructions(4) <= Asm2Std("ADDI", 6, 0, 10); -- x6 = 10

    -- loop:
    -- s_instructions(5) <= Asm2Std("ADD", 3, 1, 2); -- x3 = x1 + x2
    -- s_instructions(6) <= Asm2Std("ADD", 1, 2, 0); -- x1 = x2
    -- s_instructions(7) <= Asm2Std("ADD", 2, 3, 0); -- x2 = x3
    -- s_instructions(8) <= Asm2Std("ADDI", 4, 4, 1); -- x4 = x4 + 1
    -- s_instructions(9) <= Asm2Std("BLT", 4, 6, -8); -- branch if i < n to instruction 5
    -- end loop

    -- s_instructions(10) <= Asm2Std("ADD", 5, 2, 0); -- x5 = x2

end architecture;
