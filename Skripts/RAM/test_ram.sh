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

# compile components
ghdl -a --std=08 ../../Komponenten/RAM/Single_Port_RAM.vhdl

# compile testbench
ghdl -a --std=08 ../../Testbenches/RAM/Single_Port_RAM_tb.vhdl

# create testbench entity
ghdl -e --std=08 Single_Port_RAM_tb

# start simulation and create vcd-file
ghdl -r --std=08 Single_Port_RAM_tb --vcd=ram_debug.vcd

# launch gtkwave
gtkwave ram_debug.vcd
