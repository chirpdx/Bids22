//`define DEBUG
module top;

logic clk, reset_n;

localparam TRUE  = 1'b1;
localparam FALSE = 1'b0;
parameter CLOCK_CYCLE = 10;
localparam CLOCK_WIDTH = CLOCK_CYCLE/2;
parameter IDLE_CLOCKS = 10;



// Instantiate Module
bids22inf BusInst(.*);
bids22 BIDDUV(BusInst);
//cgroups cgInst(BusInst);

//bids22cg1 g1;

covergroup internal_reg_with_input@(posedge clk);
    option.per_instance=1;
    //coverpoint BusInst.C_op;
	//coverpoint BIDDUV.unlock_recognized;
    cross BIDDUV.unlock_recognized, BusInst.C_op;
	
endgroup

internal_reg_with_input	input_reg_group1	= new();	


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
	//g1 = new();
	repeat (20)
	begin
		BusInst.C_data = 32'h56;
		BusInst.C_op = 3'h2;
		BusInst.C_start = 0;
		@(negedge clk);
		
	end
	BusInst.C_start = 1;
	@(negedge clk);
	BusInst.X_bid = 1;
	BusInst.X_bidAmt = 10;
	BusInst.Y_bid = 1;
	BusInst.Y_bidAmt = 20;
	BusInst.Z_bid = 1;
	BusInst.Z_bidAmt = 30;
	@(negedge clk);
	BusInst.X_bid = 1;
	BusInst.X_bidAmt = 40;
	BusInst.Y_bid = 1;
	BusInst.Y_bidAmt = 50;
	BusInst.Z_bid = 1;
	BusInst.Z_bidAmt = 70;
	@(negedge clk);
	BusInst.C_start = 0;
	@(negedge clk);
	BusInst.C_data = 32'h56;
	BusInst.C_op = 3'h1;
	@(negedge clk);
	BusInst.C_data = 32'h58;
	BusInst.C_op = 3'h2;
	@(negedge clk);
	#1000;
	repeat(10000)
	begin
		All_Random_Blind;
		@(negedge clk);
	end
	$stop();
end : stimulus

task All_Random_Blind();
begin
	{BusInst.X_bid, BusInst.Y_bid}		= $random();
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