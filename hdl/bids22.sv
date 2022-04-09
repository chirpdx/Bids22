//////////////////////////////////////////////////////////////
// bids22.sv - Reference Model
//
// Author:	        Chirag Chaudhari (chir@pdx.edu)
// 					Amogh Morey
// Last Modified:	01-Apr-2022
// 
//
////////////////////////////////////////////////////////////////
/*Queries and understanding::

Start timer when incorrect key is given, but where is the other use of timer? Does, 
Note: Timer is always active, but the inptopcode, is used for setting/updating the timer value.
So, what should be default value of timer?

// ack should be high when error occurs or not.
Error is still there, and we give xbid, in this case xack should not be given
Note: err are 2 bits

*/
module bids22(clk, reset_n, X_bidAmt, X_bid, X_retract,
							Y_bidAmt, Y_bid, Y_retract,
							Z_bidAmt, Z_bid, Z_retract,
							C_data, C_op, C_start,
							X_ack, X_err, X_balance, X_win,
							Y_ack, Y_err, Y_balance, Y_win,
							Z_ack, Z_err, Z_balance, Z_win,
							ready, err, roundOver, maxBid
							);
	parameter integer unlock_key = 33'h0F0F0F0F;
	
	input logic clk, reset_n;
	input logic X_bid, Y_bid, Z_bid, X_retract, Y_retract, Z_retract, C_start;
	input logic [15:0] X_bidAmt, Y_bidAmt, Z_bidAmt;
	input logic [31:0] C_data;
	input logic [3:0] C_op;
	output logic X_ack, X_win, Y_ack, Y_win, Z_ack, Z_win, ready, roundOver;
	output logic [1:0] X_err, Y_err, Z_err, err;
	output logic [31:0] X_balance, Y_balance, Z_balance;
	output logic [31:0] maxBid;

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

function max(input logic [15:0] X_bidAmt, input logic [15:0] Y_bidAmt,input logic [15:0] Z_bidAmt);
	//	corner cases should we covered
    if(X_bidAmt == Y_bidAmt || X_bidAmt==Z_bidAmt || Y_bidAmt==Z_bidAmt)
	begin
		err=3'b101; // Duplicate
	end
	else if(X_bidAmt > Y_bidAmt && X_bidAmt > Z_bidAmt)
    begin
        maxBid=X_bidAmt;
		X_win=1;
    end
	else if(Y_bidAmt > X_bidAmt && Y_bidAmt > Z_bidAmt)
    begin
        maxBid=Y_bidAmt;
		Y_win=1;
    end
	else if(Z_bidAmt > X_bidAmt && Z_bidAmt > Y_bidAmt)
    begin
        maxBid=Z_bidAmt;
		Z_win=1;
    end

endfunction

typedef enum logic[2:0] {UnlockSt, LockSt, ResultSt} state;
state present_state, next_state;

always_ff@(posedge clk)
begin
	if(reset_n==0)
		begin
			present_state<=UnlockSt;
		end
	else
	begin
		if(c_start==0)
			begin
				present_state<=ResultSt; //if c_start becomes zero then you will go to result state
			end
		present_state<=next_state;
	
	end
end

always_comb
begin
	if(reset_n == 0)
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
		{X_win, Y_win, Z_win} <= '0;
		err <= '0;
		{X_ack, Y_ack, Z_ack} <= 0;
		{X_balance, Y_balance, Z_balance} <= '0;
		{X_err, Y_err, Z_err} <= '0;
		maxBid <= '0;
		roundOver <= '0;
	end
	else
	begin
		ready = 1'b1;
		case(present_state)
			Unlock:  
				begin
					if(C_op == 0)
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
					else if(C_op == 1)
					begin
						err <= 3'b010; //already unlocked
					end
					else if(C_op == 2)
					begin
						key <= C_data;
						next_state<=LockSt;  //needs to check if this works--going to lock

					end
					else if(C_op == 3)
					begin
						X_value <= C_data;
						xtemp <= C_data;
					end
					else if(C_op == 4)
					begin
						Y_value <= C_data;
						ytemp <= C_data;
					end
					else if(C_op == 5)
					begin
						Z_value <= C_data;
						ztemp <= C_data;
					end
					else if(C_op == 6)
						mask <= C_data[2:0];
					else if(C_op == 7)
						timer <= C_data;
					else if(C_op == 8)
						bid_cost <= C_data;
					else
						err <= 100; // invalid operation
					if(C_start)
						err<= 011; // cannot assert c_start when unlocked
			
				end
			Lock:
				begin
					if(C_start == 1)	// round start
					begin
						
						if(mask[2] == 1 && X_bid == 1)
						//ack signal
							if((xtemp - X_bidAmt - bid_cost) >= 0)
							begin
								xcurr <= X_bidAmt;
								xtemp <= xtemp - bid_cost;
							end
							else
							begin
								X_err <= 2'b10;		//insufficient funds
								xtemp <= xtemp - bid_cost;		// confirm whether required
							end
						else if(mask[2] == 1 && X_bid == 0)
							xcurr <= xcurr;
						else if(mask[2] == 0 && X_bid == 1)
						begin
							X_err = 2'b11;
							xcurr=2'b00;
						end
						else
							X_err= 2'b00; 
							xcurr=2'b00;  // does it require xcurr also
						
						if(mask[1] == 1 && Y_bid == 1)
							if((ytemp - Y_bidAmt - bid_cost) >= 0)
							begin
								ycurr <= Y_bidAmt;
								ytemp <= ytemp - bid_cost;
							end
							else
							begin
								Y_err <= 2'b10;		//insufficient funds
								ytemp <= ytemp - bid_cost;
							end
						else if(mask[1] == 1 && Y_bid == 0)
							ycurr <= ycurr;
						else if(mask[1] == 0 && Y_bid == 1)
							Y_err <= 2'b11;
							ycurr=2'b00;
						else
							Y_err <= 2'b00;
							ycurr=2'b00;
						
						if(Z_bid == 1)
							if((ztemp - Z_bidAmt - bid_cost) >= 0)
							begin
								zcurr <= Z_bidAmt;
								ztemp <= ztemp - bid_cost;
							end
							else
							begin
								Z_err <= 2'b10;		//insufficient funds
								ztemp <= ztemp - bid_cost;
							end
						else if(mask[0] == 1 && Z_bid == 0)
							zcurr <= zcurr;
						else if(mask[0] == 0 && Z_bid == 1)
							Z_err <= 2'b11;
							zcurr=2'b00;
						else
							Z_err <= 2'b00;
							zcurr=2'b00;
					end
					else
					begin
						next_state=Result;

						if(X_bid==1 || X_retract==1)  // Round inactive
							X_err=2'b01;
						else
							X_err=X_err;

						if(Y_bid==1 || Y_retract==1)
							Y_err=2'b01;
						else
							Y_err=Y_err;

						if(Z_bid==1 || Z_retract==1)
							Z_err=2'b01;
						else
							Z_err=Z_err;
					end
						
				end
			Result:
				begin
				roundOver=1;
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