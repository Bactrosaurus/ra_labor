-- Laboratory RA solutions/versuch3
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.Constant_package.all;
    use work.types.all;

entity decoder is
    generic (
        g_word_width : integer := WORD_WIDTH
    );

    port (
        pi_instruction : in  std_logic_vector(g_word_width - 1 downto 0);
        po_controlWord : out controlword
    );
end entity;

architecture arc of decoder is
begin
    process (pi_instruction)
        variable v_ctrl_word : controlword;
        variable v_insFormat : t_instruction_type;
    begin
        -- Default value
        v_ctrl_word := control_word_init;

        -- Check opcode of instruction (last 6 bits) and use t_instruction_type
        case pi_instruction(6 downto 0) is
            when R_INS_OP =>
                v_insFormat := rFormat;
            when I_INS_OP =>
                v_insFormat := iFormat;
            when LUI_INS_OP =>
                v_insFormat := uFormat;
            when AUIPC_INS_OP =>
                v_insFormat := uFormat;
            when JAL_INS_OP =>
                v_insFormat := uFormat;
            when JALR_INS_OP =>
                v_insFormat := iFormat;
            when B_INS_OP =>
                v_insFormat := bFormat;
            when others =>
                v_insFormat := nullFormat;
        end case;

        case v_insFormat is
            when rFormat =>
                -- r-type instructions read rs2 and rs1 registers for source operands and
                -- write result in rd
                -- instruction in r-format uses bit 30 to differentiate between add/sub
                -- and arithmetic/logical r-shift
                -- bits 14-12 are "funct3" which sets operation type
                -- ALU opcodes match this format
                v_ctrl_word.ALU_OP := pi_instruction(30) & pi_instruction(14 downto 12);
                v_ctrl_word.REG_WRITE := '1';
            when iFormat =>
                if pi_instruction(6 downto 0) = JALR_INS_OP then
                    v_ctrl_word.ALU_OP := ADD_ALU_OP;
                    v_ctrl_word.PC_SEL := '1';
                    v_ctrl_word.WB_SEL := "10";
                else
                    -- check for SRAI and SRLI instruction where bits 31-25 mimic funct7 (special format)
                    if pi_instruction(14 downto 12) = SRL_ALU_OP(2 downto 0) then
                        v_ctrl_word.ALU_OP(3) := pi_instruction(30);
                    else
                        v_ctrl_word.ALU_OP(3) := '0';
                    end if;
                    v_ctrl_word.ALU_OP(2 downto 0) := pi_instruction(14 downto 12);
                    v_ctrl_word.WB_SEL := "00";
                end if;

                v_ctrl_word.I_IMM_SEL := '1';
                v_ctrl_word.REG_WRITE := '1';
            when uFormat =>
                v_ctrl_word.ALU_OP := ADD_ALU_OP;
                v_ctrl_word.I_IMM_SEL := '1';
                if pi_instruction(6 downto 0) = AUIPC_INS_OP then
                    v_ctrl_word.A_SEL := '1';
                    v_ctrl_word.WB_SEL := "00";
                elsif pi_instruction(6 downto 0) = JAL_INS_OP then
                    v_ctrl_word.A_SEL := '1';
                    v_ctrl_word.PC_SEL := '1';
                    v_ctrl_word.WB_SEL := "10";
                else
                    v_ctrl_word.A_SEL := '0';
                    v_ctrl_word.WB_SEL := "01";
                end if;
                v_ctrl_word.REG_WRITE := '1';
            when bFormat =>
                v_ctrl_word.IS_BRANCH := '1';
                v_ctrl_word.CMP_RESULT := '1';

                if pi_instruction(14 downto 12) = FUNC3_BEQ or
                   pi_instruction(14 downto 12) = FUNC3_BGE or
                   pi_instruction(14 downto 12) = FUNC3_BGEU then
                    v_ctrl_word.CMP_RESULT := '0';
                end if;

                if pi_instruction(14 downto 12) = FUNC3_BEQ or
                   pi_instruction(14 downto 12) = FUNC3_BNE then
                    v_ctrl_word.ALU_OP := SUB_ALU_OP;
                end if;

                if pi_instruction(14 downto 12) = FUNC3_BLT or
                   pi_instruction(14 downto 12) = FUNC3_BGE then
                    v_ctrl_word.ALU_OP := SLT_ALU_OP;
                end if;

                if pi_instruction(14 downto 12) = FUNC3_BLTU or
                   pi_instruction(14 downto 12) = FUNC3_BGEU then
                    v_ctrl_word.ALU_OP := SLTU_ALU_OP;
                end if;
            when others =>
                null;
        end case;
        po_controlWord <= v_ctrl_word;
    end process;
end architecture;
