# makefile for standard compilation
.PHONY : all clean VLOG

sim_dir := $(shell pwd)/sim/
source_dir := $(shell pwd)/hdl/
#sv_files := $(shell find $(source_dir) -name '*.sv')
sv_files :=  $(source_dir)/interfacebids.sv $(source_dir)/bids22.sv $(source_dir)/coverage.sv $(source_dir)/tb.sv

clocks := 1000000
tasknum := 0
taskrep := 1
roundval:= 3
plus_args1:= +RUNVAL=$(clocks)
plus_args2:= +TASKVAL=$(tasknum)
plus_args3:= +TASKREP=$(taskrep)
plus_args4:= +ROUNDVAL=$(roundval)
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
		work.$(top_module) $(plus_args1) $(plus_args2) $(plus_args3) $(plus_args4)

clean:
	echo "Clean Not available"
