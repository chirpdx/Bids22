//`define DEBUG
module top;

logic clk, reset_n;

localparam TRUE  = 1'b1;
localparam FALSE = 1'b0;
parameter CLOCK_CYCLE = 10;
localparam CLOCK_WIDTH = CLOCK_CYCLE/2;
parameter IDLE_CLOCKS = 10;


bids22inf BusInst(.*);		// Instantiate Interface
bids22 BIDDUV(BusInst);		// Instantiate Reference module
cgroups cgInst(BusInst);	// Instantiate Covergroups module

// Covergroup in here to access internal regs from ref module
covergroup internal_reg_with_input@(posedge clk);
    option.per_instance=1;

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

typedef enum logic[2:0] {UnlockSt, LockSt, ResultSt, WaitSt, TimerwaitSt, default_case} state;

// fsm coverage done using functiona coverage, only for 1 transitions
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


// Clock Generation of CLOCK_CYCLE Period
initial
begin
	clk = FALSE;
	forever #CLOCK_WIDTH clk = ~clk;
end

// Reset Generation at start
initial
begin
	reset_n = FALSE;
	repeat (IDLE_CLOCKS) @(negedge clk);
	reset_n = TRUE;
end

initial
begin : stimulus
	repeat(1000000)
	begin
		All_Random_Blind;
		@(negedge clk);
	end
	$stop();
end : stimulus

task All_Random_Blind();		// Random stimulus gen task
begin
	BusInst.X_bid		= $random();
	BusInst.Y_bid		= $random();
	BusInst.Z_bid		= $random();
	BusInst.X_retract	= $random();
	BusInst.Y_retract	= $random();
	BusInst.Z_retract	= $random();
	BusInst.C_start		= $random();
	BusInst.X_bidAmt	= $random();
	BusInst.Y_bidAmt	= $random();
	BusInst.Z_bidAmt	= $random();
	BusInst.C_data		= $random();
	BusInst.C_op		= $random();
end
endtask

`ifdef DEBUG
initial
begin
	$monitor($time);
end
`endif
endmodule: top
