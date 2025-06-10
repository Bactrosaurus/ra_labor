-- Laboratory RA solutions/versuch6
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 23.05.2025
-- Description:  RIU-Only-RISC-V (incomplete RV32I implementation)
--               Supports only R-, I- and U-Instructions.
-- ========================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.constant_package.all;
    use work.types.all;
    use work.util_asm_package.all;

entity riu_only_RISC_V_tb is
end entity;

architecture structure of riu_only_RISC_V_tb is

    constant PERIOD : TIME := 10 ns;

    signal s_clk : STD_LOGIC := '0';
    signal s_rst : STD_LOGIC;
    signal cycle : INTEGER   := 0;
    signal test  : INTEGER   := 0;

    signal s_registersOut : registerMemory := (others => (others => '0'));
    signal s_instructions : memory         := (others => (others => '0'));

    -- Registerprüfung
    procedure check_register(expected : INTEGER; reg_num : INTEGER; instr : STRING) is
    begin
        assert (to_integer(signed(s_registersOut(reg_num))) = expected)
            report instr & " fehlgeschlagen. Register " & INTEGER'image(reg_num) & " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(reg_num)))) & ", sollte aber " & INTEGER'image(expected) & " enthalten!"
            severity error;
    end procedure;

    -- Wiederverwendbares Instruktionsset (ADDI, OR, ADD, etc.)
    procedure load_common_instructions(mem : inout memory; v_test : INTEGER) is
    begin
        mem(1) := Asm2Std("ADDI", 1, 0, 9);
        mem(2) := Asm2Std("ADDI", 2, 0, 8);
        mem(6) := Asm2Std("OR", 10, 1, 2);
        mem(7) := Asm2Std("ADD", 8, 1, 2);
        mem(8) := Asm2Std("SUB", 11, 1, 2);
        mem(9) := Asm2Std("SUB", 12, 2, 1);
        mem(11) := Asm2Std("ADD", 12, 2, 8);
        mem(12) := Asm2Std("SUB", 12, 2, 1);
        mem(13) := Asm2Std("AND", 1, 2, 1);
        mem(14) := Asm2Std("XOR", 12, 1, 2);
        mem(15) := Asm2Std("LUI", 13, 8, 0);
        mem(16) := Asm2Std("LUI", 13, 29, 0);
        if v_test >= 2 then
            mem(17) := Asm2Std("AUIPC", 14, 1, 0);
            mem(18) := Asm2Std("AUIPC", 14, 1, 0);
        end if;

        if v_test = 3 then
            mem(19) := Asm2Std("JAL", 15, - 36, 0);
        end if;

        if v_test = 4 then
            mem(19) := Asm2Std("JAL", 15, 70, 0);
            mem(54) := Asm2Std("JALR", 15, 15, - 56);
        end if;

    end procedure;

begin

    -- DUT
    riub_only_riscv: entity work.riu_only_RISC_V
        port map (
            pi_rst          => s_rst,
            pi_clk          => s_clk,
            pi_instruction  => s_instructions,
            po_registersOut => s_registersOut
        );

    -- Taktgenerator
    process
    begin
        while now < 5000 ns loop
            wait for PERIOD / 2;
            s_clk <= not s_clk;
        end loop;
        wait; -- Prozess beenden
    end process;

    -- Testlaufprozess
    process
        variable v_instr : memory := (others => (others => '0'));
    begin
        -- === Test 1: LUI ===
        report "== TEST 1: LUI ==";
        test <= 1;
        s_rst <= '1';
        wait for PERIOD;
        s_rst <= '0';
        load_common_instructions(v_instr, test);
        s_instructions <= v_instr;
        for i in 1 to 100 loop
            wait until rising_edge(s_clk);
            cycle <= i;
        end loop;

        -- === Test 2: AUIPC ===
        report "== TEST 2: AUIPC ==";
        test <= 2;
        s_rst <= '1';
        wait for PERIOD / 2;
        s_rst <= '0';
        wait for PERIOD / 2;
        load_common_instructions(v_instr, test);
        s_instructions <= v_instr;

        for i in 1 to 100 loop
            wait until rising_edge(s_clk);
            cycle <= i;
        end loop;
        report "==   PASSED   ==";
        -- === Test 3: JAL ===
        report "== TEST 3: JAL ==";
        test <= 3;
        s_rst <= '1';
        wait for PERIOD / 2;
        s_rst <= '0';
        wait for PERIOD / 2;
        load_common_instructions(v_instr, test);
        s_instructions <= v_instr;

        for i in 1 to 100 loop
            wait until rising_edge(s_clk);
            cycle <= i;
        end loop;
        report "==   PASSED   ==";
        -- === Test 4: JALR ===
        report "== TEST 4: JALR ==";
        test <= 4;
        s_rst <= '1';
        wait for PERIOD / 2;
        s_rst <= '0';
        wait for PERIOD / 2;
        load_common_instructions(v_instr, test);
        s_instructions <= v_instr;

        for i in 1 to 100 loop
            wait until rising_edge(s_clk);
            cycle <= i;
        end loop;
        report "==   PASSED   ==";
        report "== ALLE TESTS ABGESCHLOSSEN ==";
        wait;
    end process;

    -- Prüfroutine (separat lassen für Klarheit)
    process (cycle)
    begin
        if test >= 1 then
            -- Prüflogik für LUI
            if (cycle = 6) then
                check_register(9, 1, "ADDI");
            end if;
            if (cycle = 7) then
                check_register(8, 2, "ADDI");
            end if;
            if (cycle = 11) then
                check_register(9, 10, "OR");
            end if;
            if (cycle = 12) then
                check_register(17, 8, "ADD");
            end if;
            if (cycle = 13) then
                check_register(1, 11, "SUB");
            end if;
            if (cycle = 14) then
                check_register(- 1, 12, "SUB");
            end if;
            if (cycle = 16) then
                check_register(25, 12, "ADD");
            end if;
            if (cycle = 17) then
                check_register(- 1, 12, "SUB");
            end if;
            if (cycle = 18) then
                check_register(8, 1, "AND");
            end if;
            if (cycle = 19) then
                check_register(1, 12, "XOR");
            end if;
            if (cycle = 20) then
                check_register(8 * 2 ** 12, 13, "LUI");
            end if;
            if (cycle = 21) then
                check_register(29 * 2 ** 12, 13, "LUI");
            end if;
        end if;
        if test >= 2 then
            -- Prüflogik für AUIPC
            --REPORT "Register " & INTEGER'image(14) &
            --       " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(14)))) 
            --        ;
            if (cycle = 22) then
                check_register(4164, 14, "AUIPC");
            end if;
            if (cycle = 23) then
                check_register(4168, 14, "AUIPC");
            end if;
        end if;
        if test = 3 then
            -- Prüflogik für JAL
            if (cycle = 24) then
                check_register(80, 15, "JAL");
            end if;
            if (cycle = 23 + 5) then
                check_register(9, 1, "ADDI");
            end if;
            if (cycle = 22 + 7) then
                check_register(8, 2, "ADDI");
            end if;
            if (cycle = 22 + 11) then
                check_register(9, 10, "OR");
            end if;
            if (cycle = 22 + 12) then
                check_register(17, 8, "ADD");
            end if;
            if (cycle = 22 + 13) then
                check_register(1, 11, "SUB");
            end if;
            if (cycle = 22 + 14) then
                check_register(- 1, 12, "SUB");
            end if;
            if (cycle = 22 + 16) then
                check_register(25, 12, "ADD");
            end if;
            if (cycle = 22 + 17) then
                check_register(- 1, 12, "SUB");
            end if;
            if (cycle = 22 + 18) then
                check_register(8, 2, "AND");
            end if;
            if (cycle = 22 + 19) then
                check_register(1, 12, "XOR");
            end if;
            if (cycle = 22 + 20) then
                check_register(8 * 2 ** 12, 13, "LUI");
            end if;
            if (cycle = 22 + 21) then
                check_register(29 * 2 ** 12, 13, "LUI");
            end if;
            if (cycle = 22 + 22) then
                check_register(4164, 14, "AUIPC");
            end if;
            if (cycle = 22 + 23) then
                check_register(4168, 14, "AUIPC");
            end if;
        end if;
        if test = 4 then
            -- Prüflogik für JALR
            if (cycle = 24) then
                check_register(80, 15, "JAL");
            end if;
            if (cycle = 28) then
                check_register(220, 15, "JALR");
            end if;
            if (cycle = 32) then
                check_register(8, 1, "JALR");
            end if;
            if (cycle = 32) then
                check_register(8, 2, "JALR");
            end if;
            if (cycle = 33) then
                check_register(8, 10, "OR");
            end if;
            if (cycle = 34) then
                check_register(16, 8, "ADD");
            end if;
            if (cycle = 35) then
                check_register(0, 11, "SUB");
            end if;
            if (cycle = 36) then
                check_register(0, 12, "SUB");
            end if;
            if (cycle = 37) then
                check_register(24, 12, "ADD");
            end if;
            if (cycle = 38) then
                check_register(0, 12, "SUB");
            end if;
            if (cycle = 39) then
                check_register(8, 1, "AND");
            end if;
        end if;
    end process;

end architecture;
