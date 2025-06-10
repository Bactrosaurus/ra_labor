-- ========================================================================
-- Laboratory RA solutions/versuch7
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer
-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 14.05.2025
-- Description:  RUI-Only-RISC-V for an incomplete RV32I implementation, 
--               support only R/I/U/B-Instructions. 
-- ========================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.constant_package.all;
    use work.types.all;

entity riub_only_RISC_V is
    port (
        pi_rst          : in  std_logic;
        pi_clk          : in  std_logic;
        pi_instruction  : in  memory         := (others => (others => '0'));
        po_registersOut : out registermemory := (others => (others => '0'))
    );
end entity;

architecture structure of riub_only_RISC_V is
    -- ========================================================================
    -- CONSTANTS
    -- ========================================================================
    -- constant PERIOD              : time                                      := 10 ns;
    constant ADD_FOUR_TO_ADDRESS : std_logic_vector(WORD_WIDTH - 1 downto 0) := std_logic_vector(to_signed(4, WORD_WIDTH));

    -- ========================================================================
    -- SIGNAL DECLARATIONS
    -- ========================================================================

    -- Program Counter Signals
    signal s_pc_incremented  : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_pc_register_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_jmp_pc_out      : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_new_pc_out      : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    -- PC Pipeline Registers (IF → ID → EX → MEM → WB)
    signal s_pc_reg1_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_pc_reg2_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_pc_reg3_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_pc_reg4_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_pc_ex_out   : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    -- Instruction Signals
    signal s_instruction_register_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_cache_instruction        : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    -- Control Word Pipeline (ID → EX → MEM → WB)
    signal s_decoder_out : controlword := control_word_init;
    signal s_cw_reg1_out : controlword := control_word_init;
    signal s_cw_reg2_out : controlword := control_word_init;
    signal s_cw_reg3_out : controlword := control_word_init;

    -- Destination Register Pipeline (ID → EX → MEM → WB)
    signal s_d_reg1_out : std_logic_vector(4 downto 0) := (others => '0');
    signal s_d_reg2_out : std_logic_vector(4 downto 0) := (others => '0');
    signal s_d_reg3_out : std_logic_vector(4 downto 0) := (others => '0');

    -- Register File Outputs
    signal s_register_file_out1 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_register_file_out2 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    -- ALU Pipeline Signals
    signal s_ex_op_1_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_ex_op_2_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_alu_op1     : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_alu_op2     : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_alu_out     : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_alu_zero    : std_logic                                 := '0';

    -- Result Pipeline (EX → MEM → WB)
    signal s_ex_mem_res_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_mem_wb_res_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    -- Sign Extension Outputs
    signal s_signextension_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_immediateImm_out  : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_storeImm_out      : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_unsignedImm_out   : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_branchImm_out     : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_jumpImm_out       : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    -- Sign Extension Pipeline (ID → EX → MEM → WB)
    signal s_se_reg_out  : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_se_reg1_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_se_reg2_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_se_reg3_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    -- Branch Signals
    signal s_branch_target     : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_branch_target_mem : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_b_sel             : std_logic                                 := '0';
    signal s_b_sel_mem         : std_logic                                 := '0';

    -- Control Signals
    signal s_is_jump    : std_logic                                 := '0';
    signal s_wb_mux_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

begin
    -- ========================================================================
    -- IF STAGE (Instruction Fetch)
    -- ========================================================================

    -- Program Counter Logic
    pc_adder: entity work.my_gen_full_adder
        generic map (g_data_width => WORD_WIDTH)
        port map (
            pi_a     => ADD_FOUR_TO_ADDRESS,
            pi_b     => s_pc_register_out,
            pi_carry => '0',
            po_sum   => s_pc_incremented,
            po_carry => open
        );

    pc_register: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_new_pc_out,
            po_data => s_pc_register_out
        );

    -- PC Selection Logic
    pc_jmp_mux: entity work.Multiplexer
        generic map (dataWidth => WORD_WIDTH)
        port map (
            pi_first  => s_pc_incremented,
            pi_second => s_ex_mem_res_out,
            pi_sel    => s_cw_reg2_out.PC_SEL,
            po_res    => s_jmp_pc_out
        );

    pc_branch_mux: entity work.Multiplexer
        generic map (dataWidth => WORD_WIDTH)
        port map (
            pi_first  => s_jmp_pc_out,
            pi_second => s_branch_target_mem,
            pi_sel    => s_b_sel_mem,
            po_res    => s_new_pc_out
        );

    -- Instruction Cache
    instruction_cache: entity work.instruction_cache
        generic map (adr_width => WORD_WIDTH)
        port map (
            pi_clk              => not pi_clk,
            pi_rst              => pi_rst,
            pi_adr              => s_pc_register_out,
            pi_instructionCache => pi_instruction,
            po_instruction      => s_cache_instruction
        );

    -- Flushing of pipeline after branch or jump instructions implemented by s_b_sel_mem or s_is_jump
    -- indicating branch or jump in mem-phase. All pipeline and controlword-registers in IF and ID phase
    -- will have pi_rst or s_b_sel_mem or s_is_jump as reset signal so reset is triggered when branch
    -- or jump is detected and pipeline is flushed.

    -- IF/ID Pipeline Register
    instruction_cache_register: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst or s_b_sel_mem or s_is_jump,
            pi_data => s_cache_instruction,
            po_data => s_instruction_register_out
        );

    -- ========================================================================
    -- ID STAGE (Instruction Decode)
    -- ========================================================================

    -- Instruction Decoder
    dec1: entity work.decoder
        generic map (g_word_width => WORD_WIDTH)
        port map (
            pi_instruction => s_instruction_register_out,
            po_controlWord => s_decoder_out
        );

    -- Sign Extension Unit
    signextension: entity work.signExtension
        port map (
            pi_instr        => s_instruction_register_out,
            po_immediateImm => s_immediateImm_out,
            po_storeImm     => s_storeImm_out,
            po_unsignedImm  => s_unsignedImm_out,
            po_branchImm    => s_branchImm_out,
            po_jumpImm      => s_jumpImm_out
        );

    -- Immediate Selection
    with s_instruction_register_out(6 downto 0) select
        s_signextension_out <= s_immediateImm_out      when I_INS_OP,
                               s_storeImm_out          when S_INS_OP,
                               s_unsignedImm_out       when LUI_INS_OP,
                               s_unsignedImm_out       when AUIPC_INS_OP,
                               s_branchImm_out         when B_INS_OP,
                               s_jumpImm_out           when JAL_INS_OP,
                               s_immediateImm_out      when JALR_INS_OP,
                                       (others => '0') when others;

    -- Register File
    register_file: entity work.register_file
        port map (
            pi_clk          => not pi_clk,
            pi_rst          => pi_rst,
            pi_writeEnable  => s_cw_reg3_out.REG_WRITE,
            pi_writeRegData => s_wb_mux_out,
            pi_writeRegAddr => s_d_reg3_out,
            pi_readRegAddr1 => s_instruction_register_out(19 downto 15),
            pi_readRegAddr2 => s_instruction_register_out(24 downto 20),
            po_readRegData1 => s_register_file_out1,
            po_readRegData2 => s_register_file_out2,
            po_registerOut  => po_registersOut
        );

    -- ID/EX Pipeline Registers
    cw_reg1: entity work.controlwordregister
        port map (
            pi_clk         => pi_clk,
            pi_rst         => pi_rst or s_b_sel_mem or s_is_jump,
            pi_controlWord => s_decoder_out,
            po_controlWord => s_cw_reg1_out
        );

    d_reg1: entity work.PipelineRegister
        generic map (g_register_width => REG_ADR_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst or s_b_sel_mem or s_is_jump,
            pi_data => s_instruction_register_out(11 downto 7),
            po_data => s_d_reg1_out
        );

    id_ex_op1: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst or s_b_sel_mem or s_is_jump,
            pi_data => s_register_file_out1,
            po_data => s_ex_op_1_out
        );

    id_ex_op2: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst or s_b_sel_mem or s_is_jump,
            pi_data => s_register_file_out2,
            po_data => s_ex_op_2_out
        );

    id_ex_se: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst or s_b_sel_mem or s_is_jump,
            pi_data => s_signextension_out,
            po_data => s_se_reg_out
        );

    -- ========================================================================
    -- EX STAGE (Execute)
    -- ========================================================================

    -- ALU Input Multiplexers
    pc_mux: entity work.Multiplexer
        generic map (dataWidth => WORD_WIDTH)
        port map (
            pi_first  => s_ex_op_1_out,
            pi_second => s_pc_reg2_out,
            pi_sel    => s_cw_reg1_out.A_SEL,
            po_res    => s_alu_op1
        );

    imm_mux: entity work.Multiplexer
        generic map (dataWidth => WORD_WIDTH)
        port map (
            pi_first  => s_ex_op_2_out,
            pi_second => s_se_reg_out,
            pi_sel    => s_cw_reg1_out.I_IMM_SEL,
            po_res    => s_alu_op2
        );

    -- Arithmetic Logic Unit
    alu: entity work.my_alu
        generic map (g_data_width => WORD_WIDTH, g_op_width => ALU_OPCODE_WIDTH)
        port map (
            pi_op1      => s_alu_op1,
            pi_op2      => s_alu_op2,
            pi_aluOp    => s_cw_reg1_out.ALU_OP,
            po_aluOut   => s_alu_out,
            po_zero     => s_alu_zero,
            po_carryOut => open
        );

    -- Branch Target Calculation
    branch_adder: entity work.my_gen_full_adder
        generic map (g_data_width => WORD_WIDTH)
        port map (
            pi_a     => s_pc_reg2_out,
            pi_b     => s_se_reg_out,
            pi_carry => '0',
            po_sum   => s_branch_target,
            po_carry => open
        );

    -- Branch and Jump Control Logic
    s_b_sel   <= s_cw_reg1_out.IS_BRANCH and (s_alu_zero xor s_cw_reg1_out.CMP_RESULT);
    s_is_jump <= s_cw_reg2_out.PC_SEL;

    -- EX/MEM Pipeline Registers
    b_sel_mem: entity work.PipelineRegister
        generic map (g_register_width => 1)
        port map (
            pi_clk     => pi_clk,
            pi_rst     => pi_rst,
            pi_data(0) => s_b_sel,
            po_data(0) => s_b_sel_mem
        );

    branch_target_mem: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_branch_target,
            po_data => s_branch_target_mem
        );

    ex_mem_res: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_alu_out,
            po_data => s_ex_mem_res_out
        );

    cw_reg2: entity work.controlwordregister
        port map (
            pi_clk         => pi_clk,
            pi_rst         => pi_rst,
            pi_controlWord => s_cw_reg1_out,
            po_controlWord => s_cw_reg2_out
        );

    d_reg2: entity work.PipelineRegister
        generic map (g_register_width => REG_ADR_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_d_reg1_out,
            po_data => s_d_reg2_out
        );

    -- ========================================================================
    -- MEM STAGE (Memory Access)
    -- ========================================================================
    -- (No memory operations in this simplified implementation)

    -- MEM/WB Pipeline Registers
    cw_reg3: entity work.controlwordregister
        port map (
            pi_clk         => pi_clk,
            pi_rst         => pi_rst,
            pi_controlWord => s_cw_reg2_out,
            po_controlWord => s_cw_reg3_out
        );

    d_reg3: entity work.PipelineRegister
        generic map (g_register_width => REG_ADR_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_d_reg2_out,
            po_data => s_d_reg3_out
        );

    -- ========================================================================
    -- WB STAGE (Write Back)
    -- ========================================================================
    mem_wb_res: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_ex_mem_res_out,
            po_data => s_mem_wb_res_out
        );

    wb_mux: entity work.four_to_one_mux
        generic map (dataWidth => WORD_WIDTH)
        port map (
            pi_1   => s_mem_wb_res_out,
            pi_2   => s_se_reg3_out,
            pi_3   => s_pc_reg4_out,
            pi_4   => (others => '0'),
            pi_sel => s_cw_reg3_out.WB_SEL,
            po_res => s_wb_mux_out
        );

    -- ========================================================================
    -- PC PIPELINE REGISTERS
    -- ========================================================================
    pc_reg1: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_pc_register_out,
            po_data => s_pc_reg1_out
        );

    pc_reg2: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_pc_reg1_out,
            po_data => s_pc_reg2_out
        );

    pc_ex_adder: entity work.my_gen_full_adder
        generic map (g_data_width => WORD_WIDTH)
        port map (
            pi_a     => ADD_FOUR_TO_ADDRESS,
            pi_b     => s_pc_reg2_out,
            pi_carry => '0',
            po_sum   => s_pc_ex_out,
            po_carry => open
        );

    pc_reg3: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_pc_ex_out,
            po_data => s_pc_reg3_out
        );

    pc_reg4: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_pc_reg3_out,
            po_data => s_pc_reg4_out
        );

    -- ========================================================================
    -- SIGN EXTENSION PIPELINE REGISTERS
    -- ========================================================================
    se_reg1: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst or s_b_sel_mem or s_is_jump,
            pi_data => s_signextension_out,
            po_data => s_se_reg1_out
        );

    se_reg2: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_se_reg1_out,
            po_data => s_se_reg2_out
        );

    se_reg3: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_se_reg2_out,
            po_data => s_se_reg3_out
        );

end architecture;
