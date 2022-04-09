//////////////////////////////////////////////////////////////
// bids22.sv - Reference Model
//
// Author:	        Chirag Chaudhari (chir@pdx.edu)
// 					Amogh Morey
// Last Modified:	01-Apr-2022
// 
//
////////////////////////////////////////////////////////////////

interface bids22(input logic clk,reset_n);
	logic clk, reset_n;
	logic X_bid, Y_bid, Z_bid, X_retract, Y_retract, Z_retract, C_start;
	logic [15:0] X_bidAmt, Y_bidAmt, Z_bidAmt;
	logic [31:0] C_data;
	logic [3:0] C_op;
	logic X_ack, X_win, Y_ack, Y_win, Z_ack, Z_win, ready, roundOver;
	logic [1:0] X_err, Y_err, Z_err, err;
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
		output roundOver;
		output X_err, 
		output Y_err, 
		output Z_err, 
		output err;
		output X_balance, 
		output Y_balance, 
		output Z_balance,
		output maxBid);

endinterface

module bids22(bids22.bids22arch bid);
	parameter integer unlock_key = 33'h0F0F0F0F;
	
// Internal Registers
logic [31:0] X_value, Y_value, Z_value;
logic [31:0] xtemp, ytemp, ztemp;
logic [31:0] xcurr, ycurr, zcurr;
logic [31:0] timer;
logic [31:0] key;
logic [2:0] mask;
logic [31:0] bid_cost;

enum logic[3:0] {	NoOp 		= 4'b0000,
					Unlock		= 4'b0001,
					Lock		= 4'b0010,
					LoadX		= 4'b0011,
					LoadY		= 4'b0100,
					LoadZ		= 4'b0101,
					SetXYZmask	= 4'b0110,
					SetTimer	= 4'b0111,
					BidCharge	= 4'b1000
					} Opcode;

logic unlock_recognized; // Lock Flag

function max(input logic [15:0] bid.X_bidAmt, input logic [15:0] bid.Y_bidAmt,input logic [15:0] bid.Z_bidAmt);
	//	corner cases should we covered
    if(bid.X_bidAmt == bid.Y_bidAmt || bid.X_bidAmt==bid.Z_bidAmt || bid.Y_bidAmt==bid.Z_bidAmt)
	begin
		bid.err=3'b101; // Duplicate
	end
	else if(bid.X_bidAmt > bid.Y_bidAmt && bid.X_bidAmt > bid.Z_bidAmt)
    begin
        bid.maxBid=bid.X_bidAmt;
		bid.X_win=1;
    end
	else if(bid.Y_bidAmt > bid.X_bidAmt && bid.Y_bidAmt > bid.Z_bidAmt)
    begin
        bid.maxBid=bid.Y_bidAmt;
		bid.Y_win=1;
    end
	else if(bid.Z_bidAmt > bid.X_bidAmt && bid.Z_bidAmt > bid.Y_bidAmt)
    begin
        bid.maxBid=bid.Z_bidAmt;
		bid.Z_win=1;
    end

endfunction

<<<<<<< HEAD
typedef enum logic[2:0]{Unlock,Lock,Result}state;
=======
typedef enum logic[2:0] {UnlockSt, LockSt, ResultSt} state;
>>>>>>> 92f53b653080be08dd8dcd14e9f8842cb4fd17c9
state present_state, next_state;

always_ff@(posedge bid.clk)
begin
	if(bid.reset_n==0)
		begin
			present_state<=UnlockSt;
		end
	else
	begin
		if(bid.c_start==0)
			begin
				present_state<=ResultSt; //if c_start becomes zero then you will go to result state
			end
		present_state<=next_state;
	
	end
end

always_comb
begin
	if(bid.reset_n == 0)
	begin
		unlock_recognized <= 1;
		X_value <= '0;
		Y_value <= '0;
		Z_value <= '0;
		mask <= 3'b111;
		timer <= 32'hF;
		key <= '0;
		bid_cost <= 1;

		{xtemp, ytemp, ztemp} <= '0;
		{xcurr, ycurr, zcurr} <= '0;

		ready <= 1'b0;
		{bid.X_win, bid.Y_win, bid.Z_win} <= '0;
		err <= '0;
		{bid.X_ack, bid.Y_ack, bid.Z_ack} <= 0;
		{bid.X_balance, bid.Y_balance, bid.Z_balance} <= '0;
		{bid.X_err, bid.Y_err, bid.Z_err} <= '0;
		bid.maxBid <= '0;
		bid.roundOver <= '0;
	end
	else
	begin
		ready = 1'b1;
		case(present_state)
			Unlock:  
				begin
					if(bid.C_op == 0)
					begin
						key <= key;
						X_value <= X_value;
						Y_value <= Y_value;
						Z_value <= Z_value;
						xtemp <= X_value;
						ytemp <= X_value;
						ztemp <= X_value;
						mask <= mask;
						bid_cost <= bid_cost;
						timer <= timer;
					end
					else if(bid.C_op == 1)
					begin
						bid.err <= 3'b010; //already unlocked
					end
					else if(bid.C_op == 2)
					begin
						key <= bid.C_data;
						next_state<=LockSt;  //needs to check if this works--going to lock

					end
					else if(bid.C_op == 3)
					begin
						X_value <= bid.C_data;
						xtemp <= bid.C_data;
					end
					else if(bid.C_op == 4)
					begin
						Y_value <= bid.C_data;
						ytemp <= bid.C_data;
					end
					else if(bid.C_op == 5)
					begin
						Z_value <= bid.C_data;
						ztemp <= bid.C_data;
					end
					else if(bid.C_op == 6)
						mask <= bid.C_data[2:0];
					else if(bid.C_op == 7)
						timer <= bid.C_data;
					else if(bid.C_op == 8)
						bid_cost <= bid.C_data;
					else
						bid.err <= 100; // invalid operation
					if(C_start)
						bid.err<= 011; // cannot assert c_start when unlocked
			
				end
			Lock:
				begin
					if(bid.C_start == 1)	// round start
					begin
						
						if(mask[2] == 1 && bid.X_bid == 1)
						//ack signal
							if((xtemp - bid.X_bidAmt - bid_cost) >= 0)
							begin
								xcurr <= bid.X_bidAmt;
								xtemp <= xtemp - bid_cost;
							end
							else
							begin
								bid.X_err <= 2'b10;		//insufficient funds
								xtemp <= xtemp - bid_cost;		// confirm whether required
							end
						else if(mask[2] == 1 && bid.X_bid == 0)
							xcurr <= xcurr;
						else if(mask[2] == 0 && bid.X_bid == 1)
						begin
							bid.X_err = 2'b11;
							xcurr=2'b00;
						end
						else
							bid.X_err= 2'b00; 
							xcurr=2'b00;  // does it require xcurr also
						
						if(mask[1] == 1 && bid.Y_bid == 1)
							if((ytemp - bid.Y_bidAmt - bid_cost) >= 0)
							begin
								ycurr <= bid.Y_bidAmt;
								ytemp <= ytemp - bid_cost;
							end
							else
							begin
								Y_err <= 2'b10;		//insufficient funds
								ytemp <= ytemp - bid_cost;
							end
						else if(mask[1] == 1 && bid.Y_bid == 0)
							ycurr <= ycurr;
						else if(mask[1] == 0 && bid.Y_bid == 1)
							bid.Y_err <= 2'b11;
							ycurr=2'b00;
						else
							bid.Y_err <= 2'b00;
							ycurr=2'b00;
						
						if(bid.Z_bid == 1)
							if((ztemp - bid.Z_bidAmt - bid_cost) >= 0)
							begin
								zcurr <= bid.Z_bidAmt;
								ztemp <= ztemp - bid_cost;
							end
							else
							begin
								bid.Z_err <= 2'b10;		//insufficient funds
								ztemp <= ztemp - bid_cost;
							end
						else if(mask[0] == 1 && bid.Z_bid == 0)
							zcurr <= zcurr;
						else if(mask[0] == 0 && bid.Z_bid == 1)
							bid.Z_err <= 2'b11;
							zcurr=2'b00;
						else
							bid.Z_err <= 2'b00;
							zcurr=2'b00;
					end
					else
					begin
						next_state=Result;

						if(bid.X_bid==1 || bid.X_retract==1)  // Round inactive
							bid.X_err=2'b01;
						else
							bid.X_err=bid.X_err;

						if(bid.Y_bid==1 || bid.Y_retract==1)
							bid.Y_err=2'b01;
						else
							bid.Y_err=bid.Y_err;

						if(bid.Z_bid==1 || bid.Z_retract==1)
							bid.Z_err=2'b01;
						else
							bid.Z_err=bid.Z_err;
					end						
				end
			Result:
				begin
				bid.roundOver=1;
				max(xcurr,ycurr,zcurr);
				end
			default_case=UnlockSt;
		endcase
	end

end
endmodule: bids22
//max function
//retract functionality
//Timer- task - When in Lock state or Result state, trying to Unlock, 
//All invalid operations, if we try to unlock when c_start==1 ,we should get a invalid operations
//Key does not match with c_data- Bad key
//interface
//All ack pending
//bids either recieve an ack or err
//Balance of x,y,z, it should we given in Result