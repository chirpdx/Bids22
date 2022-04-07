//`define DEBUG
module top();

logic clk, reset_n;

localparam TRUE  = 1'b1;
localparam FALSE = 1'b0;
parameter CLOCK_CYCLE = 10;
localparam CLOCK_WIDTH = CLOCK_CYCLE/2;
parameter IDLE_CLOCKS = 5;



// Instantiate FSM Module
bids22 BIDDUV(clk, reset_n);

// Clock Generation of CLOCK_CYCLE Period
initial
begin
	Clock = FALSE;
	forever #CLOCK_WIDTH Clock = ~Clock;
end

// Reset Generation at start
initial
begin
	Reset = FALSE;
	repeat (IDLE_CLOCKS) @(negedge Clock);
	Reset = TRUE;
end

initial
begin : stimulus

$stop();
end : stimulus


`ifdef DEBUG
initial
begin
	$monitor($time);
end
`endif
endmodule: top



endmodule
    
        
