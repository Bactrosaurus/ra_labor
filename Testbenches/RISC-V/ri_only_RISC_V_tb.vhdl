-- Laboratory RA solutions/versuch5
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 21.05.2025
-- Description:  RI-Only-RISC-V for an incomplete RV32I implementation, support
--               only R- and I-Instructions. 
--
-- ========================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.constant_package.all;
    use work.types.all;
    use work.util_asm_package.all;

entity ri_only_RISC_V_tb is

end entity;

architecture structure of ri_only_RISC_V_tb is

    constant PERIOD : TIME := 10 ns;
    signal s_clk          : STD_LOGIC      := '0';
    signal s_rst          : STD_LOGIC      := '0';
    signal cycle          : INTEGER        := 0;
    signal s_test         : INTEGER        := 0;
    signal s_registersOut : registerMemory := (others => (others => '0'));
    signal s_instructions : memory         := (others => (others => '0'));

    -- Prozedur fuer Vergleich
    procedure check_register(
            expected : INTEGER;
            reg_num  : INTEGER;
            instr    : STRING
        ) is
    begin
        assert (to_integer(signed(s_registersOut(reg_num))) = expected)
            report instr & " fehlgeschlagen. Register " & INTEGER'image(reg_num) & " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(reg_num)))) & ", sollte aber " & INTEGER'image(expected) & " enthalten!"
            severity error;
    end procedure;

begin

    DUT: entity work.ri_only_RISC_V
        port map (
            pi_rst          => s_rst,
            pi_clk          => s_clk,
            pi_instruction  => s_instructions,
            po_registersOut => s_registersOut
        );

    process (cycle) is

    begin

        if s_test = 1 then
            if (cycle = 5) then
                check_register(9, 1, "ADDI");
            end if;
            if (cycle = 6) then
                check_register(8, 2, "ADDI");
            end if;
            if (cycle = 12) then
                check_register(13, 3, "ORI");
            end if;
            if (cycle = 13) then
                check_register(8, 2, "ADDI");
            end if;
            if (cycle = 14) then
                check_register(288, 3, "SLLI");
            end if;
            if (cycle = 15) then
                check_register(0, 3, "SRLI");
            end if;
            if (cycle = 16) then
                check_register(12, 3, "XORI");
            end if;
            if (cycle = 17) then
                check_register(1, 3, "XOR");
            end if;
            if (cycle = 18) then
                check_register(1, 3, "SLTI");
            end if;
            if (cycle = 19) then
                check_register(0, 3, "SLTIU");
            end if;
            if (cycle = 20) then
                check_register(0, 3, "SLTI");
            end if;
            if (cycle = 21) then
                check_register(1, 3, "SLTIU");
            end if;
            if (cycle = 28) then
                check_register(1, 3, "SLT");
            end if;
            if (cycle = 29) then
                check_register(1, 3, "SLTU");
            end if;
            if (cycle = 30) then
                check_register(0, 3, "SLT");
            end if;
            if (cycle = 31) then
                check_register(0, 3, "SLTU");
            end if;

        elsif s_test = 2 then
            if (cycle = 5) then
                check_register(9, 1, "ADDI");
            end if;
            if (cycle = 6) then
                check_register(8, 2, "ADDI");
            end if;
            if (cycle = 10) then
                check_register(17, 8, "ADD");
            end if;
            if (cycle = 11) then
                check_register(1, 11, "SUB");
            end if;
            if (cycle = 12) then
                check_register(- 1, 12, "SUB");
            end if;
            if (cycle = 13) then
                check_register(9, 9, "OR");
            end if;
            if (cycle = 14) then
                check_register(1, 9, "XOR");
            end if;
            if (cycle = 15) then
                check_register(8, 9, "AND");
            end if;
            if (cycle = 16) then
                check_register(16, 8, "SLL");
            end if;
            if (cycle = 17) then
                check_register(8, 8, "SRL");
            end if;
            if (cycle = 18) then
                check_register(- 8, 9, "SUB");
            end if;
            if (cycle = 19) then
                check_register(0, 10, "SRA");
            end if;
        end if;

    end process;

    process is
    begin
        -- test 1 I-Format
        s_test <= 1;
        s_instructions <= (
            1      => Asm2Std("ADDI", 1, 0, 9),
            2      => Asm2Std("ADDI", 2, 0, 8),
            8      => Asm2Std("ORI", 3, 1, 5),
            9      => Asm2Std("ANDI", 3, 1, 5),
            10     => Asm2Std("SLLI", 3, 1, 5),
            11     => Asm2Std("SRLI", 3, 1, 5),
            12     => Asm2Std("XORI", 3, 1, 5),
            13     => Asm2Std("XOR", 3, 1, 2),
            14     => Asm2Std("SLTI", 3, 1, 10),
            15     => Asm2Std("SLTIU", 3, 1, 8),
            16     => Asm2Std("SLTI", 3, 1, - 10),
            17     => Asm2Std("SLTIU", 3, 1, - 8),
            18     => Asm2Std("SUB", 14, 0, 1),
            19     => Asm2Std("SUB", 15, 0, 2),
            24     => Asm2Std("SLT", 3, 14, 15),
            25     => Asm2Std("SLTU", 3, 14, 15),
            26     => Asm2Std("SLT", 3, 15, 14),
            27     => Asm2Std("SLTU", 3, 15, 14),
            others => (others => '0')
        );
        wait for PERIOD;
        for i in 1 to 35 loop
            s_clk <= '1';
            wait for PERIOD / 2;
            s_clk <= '0';
            wait for PERIOD / 2;
            cycle <= i;
        end loop;
        report "End of tests for I-Format!";

        -- test 2 (R Befehle)
        s_test <= 2;

        s_rst <= '1';
        wait for PERIOD / 2;
        s_rst <= '0';
        wait for PERIOD / 2;

        s_instructions <= (
            1      => Asm2Std("ADDI", 1, 0, 9),
            2      => Asm2Std("ADDI", 2, 0, 8),
            6      => Asm2Std("ADD", 8, 1, 2),
            7      => Asm2Std("SUB", 11, 1, 2),
            8      => Asm2Std("SUB", 12, 2, 1),
            9      => Asm2Std("OR", 9, 2, 1),
            10     => Asm2Std("XOR", 9, 2, 1),
            11     => Asm2Std("AND", 9, 2, 1),
            12     => Asm2Std("SLL", 8, 2, 11),
            13     => Asm2Std("SRL", 8, 8, 11),
            14     => Asm2Std("SUB", 9, 0, 2),
            15     => Asm2Std("SRA", 10, 1, 2),
            others => (others => '0')
        );

        wait for PERIOD;

        for i in 1 to 22 loop
            s_clk <= '1';
            wait for PERIOD / 2;
            s_clk <= '0';
            wait for PERIOD / 2;
            cycle <= i;
        end loop;
        report "End of tests for R-Format!";
        report "End of test RI!!!";
        wait;

    end process;

end architecture;
