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
ghdl -a --std=08 ../../Komponenten/Register/PipelineRegister.vhdl

# compile testbench
ghdl -a --std=08 ../../Testbenches/Register/PipelineRegister_tb.vhdl

# create testbench entity
ghdl -e --std=08 my_pipeline_tb

# start simulation and create vcd-file
ghdl -r --std=08 my_pipeline_tb --vcd=pipeline_debug.vcd

# launch gtkwave
gtkwave pipeline_debug.vcd
