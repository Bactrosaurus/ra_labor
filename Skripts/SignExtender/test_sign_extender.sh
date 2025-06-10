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
ghdl -a --std=08 ../../Packages/type_packages.vhdl
ghdl -a --std=08 ../../Packages/types.vhdl
ghdl -a --std=08 ../../Packages/Util_Asm_Package.vhdl

# compile components
ghdl -a --std=08 ../../Komponenten/SignExtender/signExtension.vhdl

# compile testbench
ghdl -a --std=08 ../../Testbenches/SignExtender/signExtension_tb.vhdl

# create testbench entity
ghdl -e --std=08 signExtension_tb

# start simulation and create vcd-file
ghdl -r --std=08 signExtension_tb --vcd=sign_extension_debug.vcd

# launch gtkwave
gtkwave sign_extension_debug.vcd
