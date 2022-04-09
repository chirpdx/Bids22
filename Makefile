# makefile for standard compilation
.PHONY : all clean VLOG

sim_dir := $(shell pwd)/sim/
source_dir := $(shell pwd)/hdl/
sv_files := $(shell find $(source_dir) -name 'bids22.sv')

top_module = "top"

all: VLOG
	cd $(sim_dir)
	vsim -c -do "run -all ; q"  \
		work.$(top_module)

VLIB:
	mkdir -p $(sim_dir)
	cd $(sim_dir)
	vlib work

VLOG: VLIB
	cd $(sim_dir)
	vlog -lint $(sv_files)


clean:
	echo "why?"
