#! /usr/bin/bash

# Laboratory RA solutions/versuch4
# Sommersemester 25
# Group Details
# Lab Date:
# 1. Participant First and Last Name: Daniel Schwenkkrauß
# 2. Participant First and Last Name: Daniel Auberer

rm work-*.cf

# compile packages
ghdl -a --std=08 ../../Packages/constant_package.vhdl
ghdl -a --std=08 ../../Packages/types.vhdl
ghdl -a --std=08 ../../Packages/Util_Asm_Package.vhdl

# compile components

## ALU
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_and.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_or.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_xor.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_shifter.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_full_adder.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_full_adder.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_alu.vhdl

## Registers & Registerfile

ghdl -a --std=08 ../../Komponenten/Register/controlwordregister.vhdl
ghdl -a --std=08 ../../Komponenten/Register/PipelineRegister.vhdl

ghdl -a --std=08 ../../Komponenten/Registerfile/register_file.vhdl

## Misc.

ghdl -a --std=08 ../../Komponenten/Decoder/decoder.vhdl
ghdl -a --std=08 ../../Komponenten/Cache/instruction_cache.vhdl

## RISC-V
ghdl -a --std=08 ../../RISC-V/R_only_RISC_V.vhdl

# compile testbench
ghdl -a --std=08 ../../Testbenches/RISC-V/R_only_RISC_V_2_tb.vhdl

# create testbench entity
ghdl -e --std=08 R_only_RISC_V_2_tb

# start simulation and create vcd-file
ghdl -r --std=08 R_only_RISC_V_2_tb --wave=riscv2_debug.ghw

# launch gtkwave
gtkwave riscv2_debug.ghw