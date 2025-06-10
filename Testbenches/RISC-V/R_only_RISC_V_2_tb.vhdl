-- Laboratory RA solutions/versuch4
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 14.05.2025
-- Description:  R-Only-RISC-V foran incomplete RV32I implementation, support
--               only R-Instructions. 
--
-- ========================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.constant_package.all;
    use work.types.all;
    use work.util_asm_package.all;

entity R_only_RISC_V_2_tb is
end entity;

architecture structure of R_only_RISC_V_2_tb is

    constant PERIOD : time := 10 ns;
    -- signals
    -- begin solution:
    signal s_rst : std_logic := '0';
    signal s_clk : std_logic := '0';

    -- end solution!!
    signal s_registersOut : registerMemory := (others => (others => '0'));
    signal s_instructions : memory         := (
        -- begin solution:
        1      => std_logic_vector'(
            "0" & ADD_ALU_OP(ALU_OPCODE_WIDTH - 1) & "00000" -- func7
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rs2
            & std_logic_vector(to_unsigned(1, REG_ADR_WIDTH)) -- rs1
            & ADD_ALU_OP(ALU_OPCODE_WIDTH - 2 downto 0) -- func3
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rd
            & R_INS_OP), -- opcode

        4      => std_logic_vector'(
            "0" & ADD_ALU_OP(ALU_OPCODE_WIDTH - 1) & "00000" -- func7
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rs2
            & std_logic_vector(to_unsigned(1, REG_ADR_WIDTH)) -- rs1
            & ADD_ALU_OP(ALU_OPCODE_WIDTH - 2 downto 0) -- func3
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rd
            & R_INS_OP), -- opcode

        7      => std_logic_vector'(
            "0" & ADD_ALU_OP(ALU_OPCODE_WIDTH - 1) & "00000" -- func7
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rs2
            & std_logic_vector(to_unsigned(1, REG_ADR_WIDTH)) -- rs1
            & ADD_ALU_OP(ALU_OPCODE_WIDTH - 2 downto 0) -- func3
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rd
            & R_INS_OP), -- opcode

        10     => std_logic_vector'(
            "0" & ADD_ALU_OP(ALU_OPCODE_WIDTH - 1) & "00000" -- func7
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rs2
            & std_logic_vector(to_unsigned(1, REG_ADR_WIDTH)) -- rs1
            & ADD_ALU_OP(ALU_OPCODE_WIDTH - 2 downto 0) -- func3
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rd
            & R_INS_OP),  -- opcode

        13     => std_logic_vector'(
            "0" & ADD_ALU_OP(ALU_OPCODE_WIDTH - 1) & "00000" -- func7
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rs2
            & std_logic_vector(to_unsigned(1, REG_ADR_WIDTH)) -- rs1
            & ADD_ALU_OP(ALU_OPCODE_WIDTH - 2 downto 0) -- func3
            & std_logic_vector(to_unsigned(2, REG_ADR_WIDTH)) -- rd
            & R_INS_OP),  -- opcode

        others => (others => '0')
            -- end solution!!
    );

begin
    -- Instanziierung der Entity
    riscv_inst: entity work.R_only_RISC_V
        port map (
            pi_rst          => s_rst,
            pi_clk          => s_clk,
            pi_instruction  => s_instructions,
            po_registersOut => s_registersOut
        );

    process is

    begin
        wait for PERIOD / 2;
        for i in 1 to 21 loop
            s_clk <= '1';
            wait for PERIOD / 2;
            s_clk <= '0';
            wait for PERIOD / 2;

            -- begin solution:
            if (i = 5) then -- after 5 clock clock cycles
                assert (to_integer(signed(s_registersOut(2))) = 17)
                    report "ADD-Operation failed. Register 2 contains " & integer'image(to_integer(signed(s_registersOut(2)))) & " but should contain " & integer'image(17) & " after cycle 4"
                    severity error;
            end if;

            if (i = 8) then -- after 5 clock clock cycles
                assert (to_integer(signed(s_registersOut(2))) = 26)
                    report "ADD-Operation failed. Register 2 contains " & integer'image(to_integer(signed(s_registersOut(2)))) & " but should contain " & integer'image(26) & " after cycle 7"
                    severity error;
            end if;

            if (i = 11) then -- after 5 clock clock cycles
                assert (to_integer(signed(s_registersOut(2))) = 35)
                    report "ADD-Operation failed. Register 2 contains " & integer'image(to_integer(signed(s_registersOut(2)))) & " but should contain " & integer'image(35) & " after cycle 10"
                    severity error;
            end if;

            if (i = 14) then -- after 5 clock clock cycles
                assert (to_integer(signed(s_registersOut(2))) = 44)
                    report "ADD-Operation failed. Register 2 contains " & integer'image(to_integer(signed(s_registersOut(2)))) & " but should contain " & integer'image(44) & " after cycle 13"
                    severity error;
            end if;

            if (i = 17) then -- after 5 clock clock cycles
                assert (to_integer(signed(s_registersOut(2))) = 53)
                    report "ADD-Operation failed. Register 2 contains " & integer'image(to_integer(signed(s_registersOut(2)))) & " but should contain " & integer'image(53) & " after cycle 16"
                    severity error;
            end if;

            -- end solution!!
        end loop;
        report "End of test!!!";
        wait;

    end process;

end architecture;
