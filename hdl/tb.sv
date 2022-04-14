//`define DEBUG
module top;

logic clk, reset_n;

localparam TRUE  = 1'b1;
localparam FALSE = 1'b0;
parameter CLOCK_CYCLE = 10;
localparam CLOCK_WIDTH = CLOCK_CYCLE/2;
parameter IDLE_CLOCKS = 50;



// Instantiate Module
bids22inf BusInst(.*);
bids22 BIDDUV(BusInst);
cgroups cgInst(.*);

bids22cg1 g1;

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
g1 = new();
$stop();
end : stimulus


`ifdef DEBUG
initial
begin
	$monitor($time);
end
`endif
endmodule: top


    
        
