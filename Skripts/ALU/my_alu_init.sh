#! /usr/bin/bash

# Laboratory RA solutions/versuch1
# Sommersemester 25
# Group Details
# Lab Date:
# 1. Participant First and Last Name: Daniel Schwenkkrauß
# 2. Participant First and Last Name: Daniel Auberer

rm work-*.cf

# compile packages
ghdl -a --std=08 ../../Packages/constant_package.vhdl

# compile components
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_and.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_or.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_xor.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_shifter.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_full_adder.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_gen_full_adder.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_comparator.vhdl
ghdl -a --std=08 ../../Komponenten/ALU/my_alu.vhdl

# compile testbench
ghdl -a --std=08 ../../Testbenches/ALU/my_alu_tb.vhdl

# create testbench entity
ghdl -e --std=08 my_alu_tb

# start simulation and create vcd-file
ghdl -r --std=08 my_alu_tb --vcd=my_alu_debug.vcd

# launch gtkwave
gtkwave my_alu_debug.vcd
