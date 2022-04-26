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

task load_participant_reg();
begin
	automatic bit [31:0] val = '0;
	val = 32'h10000;
	send_ctrl(4'h3, val);
	val = 32'h20000;
	send_ctrl(4'h4, val);
	val = 32'h30000;
	send_ctrl(4'h5, val);
end
endtask

task lock_design();
begin
	automatic bit [31:0] val = '0;
	val = get_bidamt();
	send_ctrl(4'h2, val);
end
endtask

task unlock_design();
begin
	automatic bit [31:0] val = '0;
	val = get_bidamt();
	send_ctrl(4'h1, val);
end
endtask

task setmask();
begin
	automatic bit [31:0] val = '0;
	val = get_bidamt();
	$display("mask setting = %b", val[2:0]);
	send_ctrl(4'h6, val);
end
endtask

task start_round();
begin
	C_start = 1'b1;
end
endtask

task stop_round();
begin
	C_start = 1'b0;
end
endtask

task All_Random_Blind();		// Random stimulus gen task
begin
	X_bid		= $random();
	Y_bid		= $random();
	Z_bid		= $random();
	X_retract	= $random();
	Y_retract	= $random();
	Z_retract	= $random();
	C_start		= $random();
	X_bidAmt	= $random();
	Y_bidAmt	= $random();
	Z_bidAmt	= $random();
	C_data		= $random();
	C_op		= $random();
end
endtask

task bid_when_lock();
begin
	automatic bit [15:0] val = '0;
	automatic logic [1:0] bidwho;
	bidwho = $random();
	val = get_bidamt();
	if(bidwho == 2'b00)
	begin
		X_bid = 1'b1;
		X_bidAmt = val;
	end
	else if(bidwho == 2'b01)
	begin
		Y_bid = 1'b1;
		Y_bidAmt = val;
	end
	else if(bidwho == 2'b10)
	begin
		Z_bid = 1'b1;
		Z_bidAmt = val;
	end
	else
	begin
		X_bid = 1'b1;
		X_bidAmt = get_bidamt();
		Y_bid = 1'b1;
		Y_bidAmt = get_bidamt();
		Z_bid = 1'b1;
		Z_bidAmt = get_bidamt();
	end
	@(negedge clk);
	X_bid = 1'b0;
	X_bidAmt = '0;
	Y_bid = 1'b0;
	Y_bidAmt = '0;
	Z_bid = 1'b0;
	Z_bidAmt = '0;
end
endtask

function bit[15:0] get_bidamt();
	bit [1:0] selector1;
    
	selector1=$random();

    if(selector1 == 2'b00)
        return 32'h0;
    else if(selector1 == 2'b11)
        return 32'hFFFF;
    else
        return $random;

endfunction: get_bidamt



endinterface
