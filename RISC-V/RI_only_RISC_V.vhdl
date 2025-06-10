-- Laboratory RA solutions/versuch5
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: Daniel Schwenkkrauß
-- 2. Participant First and Last Name: Daniel Auberer

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 14.05.2025
-- Description:  RUI-Only-RISC-V for an incomplete RV32I implementation, 
--               support only R/I/U-Instructions. 
-- ========================================================================

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use work.constant_package.all;
    use work.types.all;

entity ri_only_RISC_V is
    port (
        pi_rst          : in  std_logic;
        pi_clk          : in  std_logic;
        pi_instruction  : in  memory         := (others => (others => '0'));
        po_registersOut : out registermemory := (others => (others => '0'))
    );
end entity;

architecture structure of ri_only_RISC_V is
    -- constant PERIOD              : time                                      := 10 ns;
    constant ADD_FOUR_TO_ADDRESS : std_logic_vector(WORD_WIDTH - 1 downto 0) := std_logic_vector(to_signed((4), WORD_WIDTH));

    -- signals
    -- begin solution:
    signal s_pc_incremented, s_pc_register_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    signal s_instruction_register_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_cache_instruction        : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    signal s_decoder_out, s_cw_reg1_out, s_cw_reg2_out, s_cw_reg3_out : controlword                  := control_word_init;
    signal s_d_reg1_out, s_d_reg2_out, s_d_reg3_out                   : std_logic_vector(4 downto 0) := (others => '0');

    signal s_register_file_out1, s_register_file_out2 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    signal s_alu_op1, s_alu_op2, s_alu_out    : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_ex_mem_res_out, s_mem_wb_res_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');

    signal s_ex_op_2_out      : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_immediateImm_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal s_se_reg_out       : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
    -- end solution!!
begin
    ---********************************************************************
    ---* program counter adder and pc-register
    ---********************************************************************
    -- begin solution:
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
            pi_data => s_pc_incremented,
            po_data => s_pc_register_out
        );
    -- end solution!!

    ---********************************************************************
    ---* instruction fetch 
    ---********************************************************************
    -- begin solution:
    instruction_cache: entity work.instruction_cache
        generic map (adr_width => WORD_WIDTH)
        port map (
            pi_clk              => not pi_clk,
            pi_rst              => pi_rst,
            pi_adr              => s_pc_register_out,
            pi_instructionCache => pi_instruction,
            po_instruction      => s_cache_instruction
        );
    -- end solution!!

    ---********************************************************************
    ---* Pipeline-Register (IF -> ID) start
    ---********************************************************************
    -- begin solution:
    instruction_cache_register: entity work.PipelineRegister
        generic map (g_register_width => WORD_WIDTH)
        port map (
            pi_clk  => pi_clk,
            pi_rst  => pi_rst,
            pi_data => s_cache_instruction,
            po_data => s_instruction_register_out
        );
    -- end solution!!

    ---********************************************************************
    ---* decode phase
    ---********************************************************************
    -- begin solution:
    dec1: entity work.decoder
        generic map (g_word_width => WORD_WIDTH)
        port map (
            pi_instruction => s_instruction_register_out,
            po_controlWord => s_decoder_out
        );

    signextension: entity work.signExtension
        port map (
            pi_instr        => s_instruction_register_out,
            po_immediateImm => s_immediateImm_out,
            po_storeImm     => open,
            po_unsignedImm  => open,
            po_branchImm    => open,
            po_jumpImm      => open
        );
    -- end solution!!

    ---********************************************************************
    ---* Pipeline-Register (ID -> EX) 
    ---********************************************************************
    -- begin solution: 
    cw_reg1: entity work.controlwordregister
    -- FIRST controlword register
    port map (
        pi_clk         => pi_clk,
        pi_rst         => pi_rst,
        pi_controlWord => s_decoder_out,
        po_controlWord => s_cw_reg1_out
    );

    d_reg1: entity work.PipelineRegister
    -- FIRST pipeline register. holds the destination address bits 11 to 7 in the instruction
    generic map (g_register_width => REG_ADR_WIDTH) port map (
        pi_clk  => pi_clk,
        pi_rst  => pi_rst,
        pi_data => s_instruction_register_out(11 downto 7),
        po_data => s_d_reg1_out
    );

    id_ex_op1: entity work.PipelineRegister
    -- A operand register for the alu
    generic map (g_register_width => WORD_WIDTH) port map (
        pi_clk  => pi_clk,
        pi_rst  => pi_rst,
        pi_data => s_register_file_out1,
        po_data => s_alu_op1
    );

    id_ex_op2: entity work.PipelineRegister
    -- B operand register for the alu
    generic map (g_register_width => WORD_WIDTH) port map (
        pi_clk  => pi_clk,
        pi_rst  => pi_rst,
        pi_data => s_register_file_out2,
        po_data => s_ex_op_2_out
    );

    id_ex_se: entity work.PipelineRegister
    -- Register for sign extended immediate
    generic map (g_register_width => WORD_WIDTH) port map (
        pi_clk  => pi_clk,
        pi_rst  => pi_rst,
        pi_data => s_immediateImm_out,
        po_data => s_se_reg_out
    );
    -- end solution!!

    ---********************************************************************
    ---* execute phase
    ---********************************************************************
    -- begin solution:
    imm_mux: entity work.Multiplexer
    -- Immediate multiplexer
    generic map (dataWidth => WORD_WIDTH) port map (
        pi_first  => s_ex_op_2_out,
        pi_second => s_se_reg_out,
        pi_sel    => s_cw_reg1_out.I_IMM_SEL,
        po_res    => s_alu_op2
    );

    alu: entity work.my_alu
    -- ALU
    generic map (g_data_width => WORD_WIDTH, g_op_width => ALU_OPCODE_WIDTH) port map (
        pi_op1      => s_alu_op1,
        pi_op2      => s_alu_op2,
        pi_aluOp    => s_cw_reg1_out.ALU_OP,
        po_aluOut   => s_alu_out,
        po_carryOut => open
    );
    -- end solution!!

    ---********************************************************************
    ---* Pipeline-Register (EX -> MEM) 
    ---********************************************************************
    -- begin solution:
    ex_mem_res: entity work.PipelineRegister
    -- result register immediately after the alu
    generic map (g_register_width => WORD_WIDTH) port map (
        pi_clk  => pi_clk,
        pi_rst  => pi_rst,
        pi_data => s_alu_out,
        po_data => s_ex_mem_res_out
    );

    cw_reg2: entity work.controlwordregister
    -- SECOND controlword register
    port map (
        pi_clk         => pi_clk,
        pi_rst         => pi_rst,
        pi_controlWord => s_cw_reg1_out,
        po_controlWord => s_cw_reg2_out
    );

    d_reg2: entity work.PipelineRegister
    -- SECOND pipeline register. holds the destination address bits 11 to 7 in the instruction
    generic map (g_register_width => REG_ADR_WIDTH) port map (
        pi_clk  => pi_clk,
        pi_rst  => pi_rst,
        pi_data => s_d_reg1_out,
        po_data => s_d_reg2_out
    );
    -- end solution!!

    ---********************************************************************
    ---* memory phase
    ---********************************************************************

    ---********************************************************************
    ---* Pipeline-Register (MEM -> WB) 
    ---********************************************************************
    -- begin solution:
    cw_reg3: entity work.controlwordregister
    -- THIRD controlword register
    port map (
        pi_clk         => pi_clk,
        pi_rst         => pi_rst,
        pi_controlWord => s_cw_reg2_out,
        po_controlWord => s_cw_reg3_out
    );

    d_reg3: entity work.PipelineRegister
    -- THIRD pipeline register. holds the destination address bits 11 to 7 in the instruction
    generic map (g_register_width => REG_ADR_WIDTH) port map (
        pi_clk  => pi_clk,
        pi_rst  => pi_rst,
        pi_data => s_d_reg2_out,
        po_data => s_d_reg3_out
    );
    -- end solution!!

    ---********************************************************************
    ---* write back phase
    ---********************************************************************
    mem_wb_res: entity work.PipelineRegister
    -- SECOND result register after the alu that is immediately after the ex->mem register
    generic map (g_register_width => WORD_WIDTH) port map (
        pi_clk  => pi_clk,
        pi_rst  => pi_rst,
        pi_data => s_ex_mem_res_out,
        po_data => s_mem_wb_res_out
    );

    ---********************************************************************
    ---* register file (negative clock)
    ---********************************************************************
    -- begin solution:
    register_file: entity work.register_file
    -- Registerfile
    port map (
        pi_clk          => not pi_clk,
        pi_rst          => pi_rst,
        pi_writeEnable  => s_cw_reg3_out.REG_WRITE,
        pi_writeRegData => s_mem_wb_res_out,
        pi_writeRegAddr => s_d_reg3_out,
        pi_readRegAddr1 => s_instruction_register_out(19 downto 15),
        pi_readRegAddr2 => s_instruction_register_out(24 downto 20),
        po_readRegData1 => s_register_file_out1,
        po_readRegData2 => s_register_file_out2,
        po_registerOut  => po_registersOut
    );
    -- end solution!!
    ---********************************************************************
    ---********************************************************************    
end architecture;
