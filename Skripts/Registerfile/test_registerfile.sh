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

# compile components
ghdl -a --std=08 ../../Komponenten/Registerfile/register_file.vhdl

# compile testbench
ghdl -a --std=08 ../../Testbenches/Registerfile/register_file_tb.vhdl

# create testbench entity
ghdl -e --std=08 register_file_tb

# start simulation and create vcd-file
ghdl -r --std=08 register_file_tb --vcd=regfile_debug.vcd

# launch gtkwave
gtkwave regfile_debug.vcd
