interface bids22inf();
	logic clk,reset_n;
	logic X_bid, Y_bid, Z_bid, X_retract, Y_retract, Z_retract, C_start;
	logic [15:0] X_bidAmt, Y_bidAmt, Z_bidAmt;
	logic [31:0] C_data;
	logic [3:0] C_op;
	logic X_ack, X_win, Y_ack, Y_win, Z_ack, Z_win, ready, roundOver;
	logic [1:0] X_err, Y_err, Z_err;
	logic [2:0] err;
	logic [31:0] X_balance, Y_balance, Z_balance;
	logic [31:0] maxBid;

	modport bids22arch(
		input clk,
		input reset_n,
		input X_bid,
		input Y_bid, 
		input Z_bid, 
		input X_retract, 
		input Y_retract, 
		input Z_retract, 
		input C_start,
		input X_bidAmt, 
		input Y_bidAmt, 
		input Z_bidAmt,
		input C_data,
		input C_op,
		output X_ack, 
		output X_win, 
		output Y_ack, 
		output Y_win, 
		output Z_ack, 
		output Z_win, 
		output ready, 
		output roundOver,
		output X_err, 
		output Y_err, 
		output Z_err, 
		output err,
		output X_balance, 
		output Y_balance, 
		output Z_balance,
		output maxBid);

// to enable the design
task reset_design();
begin
	reset_n = 1'b0;
	@(negedge clk);
	@(negedge clk);
	reset_n = 1'b1;
	C_start = 1'b0;
	@(negedge clk);
end
endtask

// to drive design into different configurations/modes
task send_ctrl(int cvalue = 4'h0, int datavalue = 32'h0);
begin
	C_op = cvalue;
	C_data = datavalue;
	@(negedge clk);
	C_op = '0;
	C_data = '0;
end
endtask

endinterface
