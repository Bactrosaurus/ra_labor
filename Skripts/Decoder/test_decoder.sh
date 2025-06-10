#! /usr/bin/bash

# Laboratory RA solutions/versuch3
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
ghdl -a --std=08 ../../Komponenten/Decoder/decoder.vhdl

# compile testbench
ghdl -a --std=08 ../../Testbenches/Decoder/decoder_tb.vhdl

# create testbench entity
ghdl -e --std=08 decoder_tb

# start simulation and create vcd-file
ghdl -r --std=08 decoder_tb --vcd=decoder_debug.vcd

# launch gtkwave
gtkwave decoder_debug.vcd
