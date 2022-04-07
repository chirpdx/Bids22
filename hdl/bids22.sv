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

Start time when incorrect key is given, but where is the other use of timer? Does, 
Note: Timer is always active, but the inptopcode, is used for setting/updating the timer value.
So, what should be default value of timer?

C_start is not as strobe. When C_start is high bids can be placed.

XYZ mask value can be cosidered as lower 3 bits of C_data

Every clock the bid signal is high, bid charge will be deducted.

Ready will be high when result is ready. ideally after C_start is deasserted.
Difference between roundOver and ready?

Does the bidAmt in same round needs to be in increasing order?

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
	
logic [31:0] X_value, Y_value, Z_value;
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

bit unlock_recognized = 0;

always_ff@(posedge clk)
begin
	if(reset_n == 0)
begin
	BidCharge <= 1;
end
else
		unique case(C_op)
			NoOp : begin
				X_balance = X_value;
end
			Unlock: if(C_data === unlock_key) unlock_recognized = 1; else unlock_recognized = 0;
			Lock:
			LoadX:
			LoadY:
			LoadZ:
			SetXYZmask:
			SetTimer:
			BidCharge:
			default:
		endcase
end

endmodule: bids22
	
