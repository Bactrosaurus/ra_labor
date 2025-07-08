-- Laboratory RA solutions/versuch1
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

library ieee;
    use ieee.std_logic_1164.all;
    use work.Constant_Package.all;

entity my_alu is
    generic (
        g_data_width : integer := DATA_WIDTH_GEN;
        g_op_width   : integer := ALU_OPCODE_WIDTH
    );

    port (
        pi_op1, pi_op2       : in  std_logic_vector(g_data_width - 1 downto 0);
        pi_aluOp             : in  std_logic_vector(g_op_width - 1 downto 0);
        po_aluOut            : out std_logic_vector(g_data_width - 1 downto 0);
        po_carryOut, po_zero : out std_logic
    );
end entity;

architecture behaviour of my_alu is
    signal s_xor_res, s_or_res, s_and_res, s_shift_res, s_add_res, s_slt_res, s_sltu_res : std_logic_vector(g_data_width - 1 downto 0) := (others => '0');
    signal s_carry_in, s_carry_out, s_shift_type, s_shift_direction                      : std_logic                                   := '0';

begin
    my_xor: entity work.my_gen_xor generic map (g_data_width) port map (pi_op1, pi_op2, s_xor_res);
    my_or: entity work.my_gen_or generic map (g_data_width) port map (pi_op1, pi_op2, s_or_res);
    my_and: entity work.my_gen_and generic map (g_data_width) port map (pi_op1, pi_op2, s_and_res);
    my_shift: entity work.my_gen_shifter generic map (g_data_width) port map (pi_op1, pi_op2, s_shift_type, s_shift_direction, s_shift_res);
    my_add: entity work.my_gen_full_adder generic map (g_data_width) port map (pi_op1, pi_op2, s_carry_in, s_add_res, s_carry_out);
    my_slt: entity work.my_comparator generic map (g_data_width, '0') port map (pi_op1, pi_op2, s_slt_res);
    my_sltu: entity work.my_comparator generic map (g_data_width, '1') port map (pi_op1, pi_op2, s_sltu_res);

    with pi_aluOp select s_shift_direction <=
        '0' when SLL_ALU_OP,
        '1' when SRL_ALU_OP,
        '1' when SRA_ALU_OP,
        '0' when others;

    s_shift_type <= pi_aluOp(g_op_width - 1);
    s_carry_in   <= pi_aluOp(g_op_width - 1);

    with pi_aluOp select po_aluOut <=
        s_xor_res               when XOR_ALU_OP,
        s_or_res                when OR_ALU_OP,
        s_and_res               when AND_ALU_OP,
        s_shift_res             when SLL_ALU_OP,
        s_shift_res             when SRL_ALU_OP,
        s_shift_res             when SRA_ALU_OP,
        s_add_res               when ADD_ALU_OP,
        s_add_res               when SUB_ALU_OP,
        s_slt_res               when SLT_ALU_OP,
        s_sltu_res              when SLTU_ALU_OP,
                (others => '0') when others;

    po_zero <= not (or po_aluOut); -- 1 when all bits are 0
    po_carryOut <= s_carry_out;
end architecture;
