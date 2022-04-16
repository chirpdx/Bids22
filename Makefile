# makefile for standard compilation
.PHONY : all clean VLOG

sim_dir := $(shell pwd)/sim/
source_dir := $(shell pwd)/hdl/
#sv_files := $(shell find $(source_dir) -name '*.sv')
sv_files :=  $(source_dir)/interfacebids.sv $(source_dir)/bids22.sv $(source_dir)/coverage.sv $(source_dir)/tb.sv

clocks := 1000000
plus_args:= +RUNVAL=$(clocks)
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

VCOV: VLOG
	vsim -c -do "coverage save -onexit UCDBfile ; run -all ; q -sim ; vcover report -verbose UCDBfile > functcov$(clocks).txt ; q" \
		work.$(top_module) $(plus_args)

clean:
	echo "Clean Not available"
