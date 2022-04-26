//////////////////////////////////////////////////////////////
// bids22.sv - Reference Model
//
// Author:	        Chirag Chaudhari (chir@pdx.edu)
// 					Amogh Morey
// Last Modified:	14-Apr-2022
// 
//
////////////////////////////////////////////////////////////////

module bids22(bids22inf.bids22arch bid);
	parameter integer unlock_key = 32'h0F0F0F0F;
	
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
logic [31:0] downtimer;
function max(input logic [15:0] X_bidAmt = 0, input logic [15:0] Y_bidAmt = 0,input logic [15:0] Z_bidAmt = 0);
begin
	//	Checking for duplicate bids
	//$display("%d, %d, %d", X_bidAmt, Y_bidAmt, Z_bidAmt);
    if((X_bidAmt == Y_bidAmt && bid.X_bid == 1 && bid.Y_bid == 1) || (X_bidAmt==Z_bidAmt && bid.X_bid == 1 && bid.Z_bid == 1) || (Y_bidAmt==Z_bidAmt && bid.Y_bid == 1 && bid.Z_bid == 1))
	begin
		bid.err=3'b101; // Duplicate
	end
	else if(X_bidAmt > Y_bidAmt && X_bidAmt > Z_bidAmt)
    begin
        bid.maxBid=X_bidAmt;
		bid.X_win=1;
    end
	else if(Y_bidAmt > X_bidAmt && Y_bidAmt > Z_bidAmt)
    begin
        bid.maxBid=Y_bidAmt;
		bid.Y_win=1;
    end
	else if(Z_bidAmt > X_bidAmt && Z_bidAmt > Y_bidAmt)
    begin
        bid.maxBid=bid.Z_bidAmt;
		bid.Z_win=1;
    end
end
endfunction

typedef enum logic[2:0] {UnlockSt, LockSt, ResultSt, WaitSt, TimerwaitSt, default_case} state;
state present_state, next_state;

always_ff@(posedge bid.clk)
begin
	if(bid.reset_n==0)
		begin
			present_state<=UnlockSt;
		end
	else
	begin

		if(bid.C_start==0)
			begin
				present_state<=ResultSt; //if c_start becomes zero then you will go to result state
			end
		present_state<=next_state;
	
	end
end

always_comb
begin
	bid.err = '0;
	if(bid.reset_n == 0)
	begin
		unlock_recognized = 1;
		X_value = '0;
		Y_value = '0;
		Z_value = '0;
		mask = 3'b111;
		timer = 32'hF;
		key = '0;
		bid_cost = 1;

		{xtemp, ytemp, ztemp} = '0;
		{xcurr, ycurr, zcurr} = '0;

		bid.ready = 1'b0;
		{bid.X_win, bid.Y_win, bid.Z_win} = '0;
		bid.err = '0;
		{bid.X_ack, bid.Y_ack, bid.Z_ack} = 0;
		{bid.X_balance, bid.Y_balance, bid.Z_balance} = '0;
		{bid.X_err, bid.Y_err, bid.Z_err} = '0;
		bid.maxBid = '0;
		bid.roundOver = '0;
		downtimer = '0;
	end
	else
	begin
		bid.ready = 1'b1;
 		bid.roundOver = 0;
		case(present_state)
			UnlockSt:  
				begin
					next_state = UnlockSt;
					if(bid.C_op == NoOp)
					begin
						key <= key;
						X_value = X_value;
						Y_value = Y_value;
						Z_value = Z_value;
						xtemp = X_value;
						ytemp = X_value;
						ztemp = X_value;
						mask = mask;
						bid_cost = bid_cost;
						timer = timer;
						bid.err = '0;
					end
					else if(bid.C_op == Unlock)
					begin
						bid.err <= 3'b010; //already unlocked
					end
					else if(bid.C_op == Lock)
					begin
						key = bid.C_data;
						next_state = LockSt;  //needs to check if this works--going to lock
						downtimer = timer;
						bid.err = '0;
					end
					else if(bid.C_op == LoadX)
					begin
						X_value = bid.C_data;
						xtemp = bid.C_data;
						bid.err = '0;
					end
					else if(bid.C_op == LoadY)
					begin
						Y_value = bid.C_data;
						ytemp = bid.C_data;
						bid.err = '0;
					end
					else if(bid.C_op == LoadZ)
					begin
						Z_value = bid.C_data;
						ztemp = bid.C_data;
						bid.err = '0;
					end
					else if(bid.C_op == SetXYZmask)
					begin
						mask = bid.C_data[2:0];
						bid.err = '0;
					end
					else if(bid.C_op == SetTimer)
					begin
						timer = bid.C_data;
						bid.err = '0;
					end
					else if(bid.C_op == BidCharge)
					begin
						bid_cost = bid.C_data;
						bid.err = '0;
					end
					else
						bid.err = 100; // invalid operation
					if(bid.C_start)
						bid.err = 011; // cannot assert c_start when unlocked
			
				end
			LockSt:
				begin
					unlock_recognized = 1'b0;
					if(bid.C_start == 1)	// round start
					begin
						next_state = LockSt;
              			if(mask[0] == 1 && bid.X_bid == 1)
							if((xtemp - bid.X_bidAmt - bid_cost) >= 0)
							begin
								xcurr = bid.X_bidAmt;
								xtemp = xtemp - bid_cost;
								bid.X_ack = 1;
								bid.X_err = 2'b00;
							end
							else
							begin
								bid.X_err = 2'b10;		//insufficient funds
								xtemp = xtemp - bid_cost;
								bid.X_ack = 0;
							end
							else if(mask[0] == 1 && bid.X_bid == 0)
							begin
								xcurr = xcurr;
								bid.X_err = 2'b00;
							end
							else if(mask[0] == 0 && bid.X_bid == 1)
							begin
								bid.X_err = 2'b11;
								xcurr = 2'b00;
								bid.X_ack = 0;
							end
						else
							bid.X_err= 2'b00; 
							xcurr=2'b00;
              				bid.X_ack = 0;
						
						if(mask[1] == 1 && bid.Y_bid == 1)
							if((ytemp - bid.Y_bidAmt - bid_cost) >= 0)
							begin
								ycurr = bid.Y_bidAmt;
								ytemp = ytemp - bid_cost;
								bid.Y_ack = 1;
								bid.Y_err = 2'b00;
							end
							else
							begin
								ytemp = ytemp - bid_cost;
								bid.Y_err = 2'b10;		//insufficient funds
								bid.Y_ack = 0;
							end
							else if(mask[1] == 1 && bid.Y_bid == 0)
							begin
								ycurr = ycurr;
								bid.Y_err = 2'b00;
							end
							else if(mask[1] == 0 && bid.Y_bid == 1)
                       		begin
								bid.Y_err = 2'b11;
								ycurr = 2'b00;
                            	bid.Y_ack = 0;
                        end
						else
                        begin
							bid.Y_err = 2'b00;
							ycurr = 2'b00;
                            bid.Y_ack = 0;
                        end
						
						if(mask[2] == 1 && bid.Z_bid == 1)
							if((ztemp - bid.Z_bidAmt - bid_cost) >= 0)
							begin
								zcurr = bid.Z_bidAmt;
								ztemp = ztemp - bid_cost;
                                bid.Z_ack = 1;
								bid.Z_err = 2'b00;
							end
							else
							begin
								bid.Z_err = 2'b10;		//insufficient funds
								ztemp = ztemp - bid_cost;
                                bid.Z_ack = 0;
							end
						else if(mask[2] == 1 && bid.Z_bid == 0)
						begin
							zcurr = zcurr;
							bid.Z_err = 2'b00;
						end
						else if(mask[2] == 0 && bid.Z_bid == 1)
                        begin
							bid.Z_err = 2'b11;
							zcurr = 2'b00;
                            bid.Z_ack = 0;
                        end
						else
                        begin
							bid.Z_err = 2'b00;
							zcurr = 2'b00;
                            bid.Z_ack = 0;
                        end

                        if(bid.X_retract)
							xcurr = '0;
						if(bid.Y_retract)
							ycurr = '0;
						if(bid.Z_retract)
							zcurr = '0;
					end
					else		// C_start == 0
					begin
						next_state = ResultSt;

						if(bid.X_bid==1 || bid.X_retract==1)  // Round inactive
							bid.X_err = 2'b01;
						else
							bid.X_err=bid.X_err;

						if(bid.Y_bid==1 || bid.Y_retract==1)
							bid.Y_err = 2'b01;
						else
							bid.Y_err = bid.Y_err;

						if(bid.Z_bid==1 || bid.Z_retract==1)
							bid.Z_err = 2'b01;
						else
							bid.Z_err = bid.Z_err;
					end						
				end
			ResultSt:
				begin
					if(bid.C_start == 1)
					begin
						next_state = LockSt;
						unlock_recognized = 1'b0;
					end
					else
					begin
						bid.roundOver = 1;
						max(xcurr,ycurr,zcurr);
						next_state = WaitSt;
					end
				end
			WaitSt:
				begin
				bid.roundOver = 0;
				{xcurr, ycurr, zcurr} = '0;
				{bid.X_win, bid.Y_win, bid.Z_win} = '0;
				if(bid.C_start == 1)
					next_state = LockSt;
				else if(bid.C_start == 0 && bid.C_op == Unlock)
					begin
						if(key === bid.C_data)
						begin
							next_state = UnlockSt;
							unlock_recognized = 1'b1;
						end
						else
						begin
							next_state = TimerwaitSt;
							downtimer = timer;
						end

					end
				else
					next_state = WaitSt;
				end
			TimerwaitSt:
				begin
					downtimer = downtimer - 1;
					if(downtimer == '0)
						next_state = WaitSt;
					else
						next_state = TimerwaitSt;
				end
			default_case: begin
				next_state = UnlockSt;
				unlock_recognized = 1'b1;
			end
		endcase
	end

end
endmodule: bids22