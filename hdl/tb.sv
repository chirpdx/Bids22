//////////////////////////////////////////////////////////////
// tb.sv - Contains instantiation of Interface, Reference module,
//			and Covergroups.
//			Random Stimulus generation task, clk and reset gen.
//			Three Covergroups which access internal design flags,
//			state of fsm, and some register values.
//
// Author:	        Chirag Chaudhari (chir@pdx.edu)
// 					Amogh Morey
// Last Modified:	15-Apr-2022
// 
//
////////////////////////////////////////////////////////////////
//`define DEBUG
module top;

logic clk, reset_n;

localparam TRUE  = 1'b1;
localparam FALSE = 1'b0;
parameter CLOCK_CYCLE = 10;
localparam CLOCK_WIDTH = CLOCK_CYCLE/2;
parameter IDLE_CLOCKS = 10;


bids22inf BusInst();		// Instantiate Interface
bids22 BIDDUV(BusInst);		// Instantiate Reference module
cgroups cgInst(BusInst);	// Instantiate Covergroups module

// Covergroup in here to access internal regs/flags from design module
covergroup internal_reg_with_input@(posedge clk);

    //coverpoint BusInst.C_op;
	lockflag: coverpoint BIDDUV.unlock_recognized;
    lockflagwithopcode: cross lockflag, BusInst.C_op;

	// for Lower 3 bits of mask register
	maskbits: coverpoint BIDDUV.mask[2:0];

	//transition for lock unlock
	lockunlocktrans: coverpoint BIDDUV.unlock_recognized{
		bins transition_noticed[] = (0,1 => 0,1);
	}

endgroup

// Covergroup for errors with checking internal flags and regs
covergroup internal_reg_op_errors@(posedge clk);

	// invalid request (mask doesn’t allow) when round is active
	xerrmask: coverpoint BusInst.X_err iff(BIDDUV.mask[0] === 0 && BusInst.C_start === 1){
		bins X_errNotAllowed = {3};
	}

	yerrmask: coverpoint BusInst.Y_err iff(BIDDUV.mask[1] === 0 && BusInst.C_start === 1){
		bins Y_errNotAllowed = {3};
	}

	zerrmask: coverpoint BusInst.Z_err iff(BIDDUV.mask[2] === 0 && BusInst.C_start === 1){
		bins Z_errNotAllowed = {3};
	}

	// Separate bin for err 2, i.e already unlocked
	errunlock : coverpoint BusInst.err iff(BIDDUV.unlock_recognized === 1 && BusInst.C_op === 1){
		bins alreadyunlockerr = {2};
	}

	// Cannot assert c_start when unlocked, separately covered
	errroundstart : coverpoint BusInst.err iff(BIDDUV.unlock_recognized === 1 && BusInst.C_start === 1){
		bins alreadyunlockerr = {4};
	}
	
endgroup

typedef enum logic[2:0] {UnlockSt, LockSt, ResultSt, WaitSt, TimerwaitSt, default_case} state;

// fsm coverage done using functiona coverage, only for 1 transition length
covergroup fsm_group@(posedge clk);

    fsm_transition: coverpoint BIDDUV.present_state{

        bins t1 = (UnlockSt => LockSt);
        bins t2 = (LockSt => ResultSt);
        bins t3 = (ResultSt => WaitSt);
        bins t4 = (WaitSt => TimerwaitSt);
        bins t5 = (TimerwaitSt => WaitSt);
    }

endgroup

internal_reg_with_input	input_reg_group1	= new();	
fsm_group				fsm_group1			= new();	
internal_reg_op_errors	err_subset_group1	= new();	


// Clock Generation of CLOCK_CYCLE Period
initial
begin
	BusInst.clk = FALSE;
	forever #CLOCK_WIDTH BusInst.clk = ~BusInst.clk;
end

/*
// Reset Generation at start
initial
begin
	reset_n = FALSE;
	repeat (IDLE_CLOCKS) @(negedge clk);
	reset_n = TRUE;
end
*/

bit [31:0] runval;
bit [31:0] roundval;
bit [31:0] taskval;
bit [31:0] taskrep;

initial
begin : stimulus
	runval = 32'd100000;
	BusInst.reset_design();
	if($value$plusargs ("RUNVAL=%0d", runval))
		$display("Running simulation for %0d clocks with random stimulus",runval);
	else
		$display("Running simulation for default %0d clocks with random stimulus",runval);
	repeat(runval)
	begin
		BusInst.All_Random_Blind;
		@(negedge BusInst.clk);
	end
	//$display("Running random done");
	BusInst.send_ctrl();
	//$display("Stopping");
	BusInst.reset_design();
	BusInst.send_ctrl();
	taskval = 32'd0;
	taskrep = 32'd1;
	if($value$plusargs ("TASKREP=%0d", taskrep))
		$display("Running simulation for %0d repetition",taskrep);
	if($value$plusargs ("TASKVAL=%0d", taskval))
		$display("Running simulation for %0d task as well with random stimulus",taskval);

	case(taskval)
		32'd1:begin
			$display("First extra tasks");
			repeat(taskrep)
			begin
				bidmultiple();
			end
		end
		32'd2:begin
			$display("Second extra task");
		end
		32'd3:begin
			$display("Third extra task");
		end
		default: $display("No extra tasks");
	endcase

	#1000;
	$stop();
end : stimulus

task bidmultiple();
begin
	roundval = 32'd3;
	BusInst.load_participant_reg();
	BusInst.lock_design();
	BusInst.start_round();
	if($value$plusargs ("ROUNDVAL=%0d", roundval))  //how many biddings in one round
		$display("Bidding for %0d clocks",roundval);
	repeat(roundval)
	begin
		BusInst.bid_when_lock();
	end
	BusInst.stop_round();
end
endtask

`ifdef DEBUG
initial
begin
	$monitor($time," Xwin = %b, Ywin = %b, Zwin = %b", BusInst.X_win, BusInst.Y_win, BusInst.Z_win);
end
initial
begin
	$monitor($time," err = %b, C_op = %b, State = %s, roundover =%b", BusInst.err, BusInst.C_op, BIDDUV.present_state, BusInst.roundOver);
end
`endif
endmodule: top
