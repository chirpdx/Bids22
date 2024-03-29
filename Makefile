# makefile for standard compilation
.PHONY : all clean VLOG

sim_dir := $(shell pwd)/sim/
source_dir := $(shell pwd)/hdl/
#traces_dir := $(shell pwd)/traces/
#out_dir := $(shell pwd)/outs/
sv_files := $(shell find $(source_dir) -name 'bids22.sv')
# -and -not -name '*shiftertb*' -or -name '*.svp')

top_module = "top"

#tracefile = $(traces_dir)/our_tracefiles/trace.txt
#outfile = $(out_dir)/dram
#plus_args := +tracefile=$(tracefile) +outfile=$(outfile)


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
