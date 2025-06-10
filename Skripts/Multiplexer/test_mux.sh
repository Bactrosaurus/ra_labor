#! /usr/bin/bash

# Laboratory RA solutions/versuch2
# Sommersemester 25
# Group Details
# Lab Date:
# 1. Participant First and Last Name: Daniel Schwenkkrauß
# 2. Participant First and Last Name: Daniel Auberer

rm work-*.cf

# compile packages
ghdl -a --std=08 ../../Packages/constant_package.vhdl

# compile components
ghdl -a --std=08 ../../Komponenten/Multiplexer/gen_mux.vhdl

# compile testbench
ghdl -a --std=08 ../../Testbenches/Multiplexer/gen_mux_tb.vhdl

# create testbench entity
ghdl -e --std=08 gen_mux_tb

# start simulation and create vcd-file
ghdl -r --std=08 gen_mux_tb --vcd=mux_debug.vcd

# launch gtkwave
gtkwave mux_debug.vcd
