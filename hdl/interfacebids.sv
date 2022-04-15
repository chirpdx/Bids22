interface bids22inf(input logic clk,reset_n);
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
		
	covergroup inputs_on_clk@(posedge clk);
    option.per_instance=1;
    
    coverpoint C_data;
	//64 default bins

    coverpoint C_op{
		bins no_op = {0};
        bins used[]={[1:8]};
		bins unused = {[9:$]};
    }

    coverpoint C_start{
        bins c_0={0};
        bins c_1={1};
    }

    coverpoint X_bidAmt;
	//64 default bins

    coverpoint X_bid{
        bins x_0={0};
        bins x_1={1};
    }

    coverpoint X_retract{
        bins x_retract_0={0};
        bins x_retract_1={1};
    }

    coverpoint Y_bidAmt;
	//64 default bins

    coverpoint Y_bid{
        bins y_0={0};
        bins y_1={1};
    }
	
    coverpoint Y_retract{
        bins y_retract_0={0};
        bins y_retract_1={1};
    }

    coverpoint Z_bidAmt;
	//64 default bins
	
    coverpoint Z_bid{
        bins z_0={0};
        bins z_1={1};

    }
    coverpoint Z_retract{
        bins z_retract_0={0};
        bins z_retract_1={1};
    }

	
	cross C_start, X_bid;
	cross C_start, Y_bid;
	cross C_start, Z_bid;
	cross C_start, X_retract;
	cross C_start, Y_retract;
	cross C_start, Z_retract;
	
    /*
    cross C_start,X_err{
        illegal_bins x_error=binsof(C_start)intersect{1};
    }

    cross C_start,Y_err{
        illegal_bins y_error=binsof(C_start)intersect{1};
    }

    cross C_start,Z_err{
        illegal_bins z_error=binsof(C_start)intersect{1};
    }

    cross X_bidAmt,X_bid{
        illegal_bins x= binsof(X_bid)intersect{0};
    }

    cross Y_bidAmt,Y_bid{
        illegal_bins y= binsof(Y_bid)intersect{0};
    }

    cross Z_bidAmt,Z_bid{
        illegal_bins x= binsof(Z_bid)intersect{0};
    }

    cross maxBid,roundOver{
        illegal_bins max=binsof(roundOver)intersect{0};
    }*/

endgroup

covergroup outputs_on_clk@(posedge clk);
    option.per_instance=1;
    
    coverpoint X_win;
	coverpoint Y_win;
	coverpoint Z_win;
	
	 coverpoint maxBid;
	//64 default bins
	
	cross X_win, maxBid;
	cross Y_win, maxBid;
	cross Z_win, maxBid;
	
	coverpoint X_err{
        bins no_err={0};
        bins x_err={[1:3]};		//separate bins for each error
    }

    coverpoint Y_err{
        bins no_err={0};
        bins y_err={[1:3]};
    }

    coverpoint Z_err{
        bins no_err={0};
        bins z_err={[1:3]};
    }
	
	coverpoint X_ack;
	coverpoint Y_ack;
	coverpoint Z_ack;
	
	coverpoint err{
        bins no_err={0};
        bins actual_err[]={[1:5]};		//separate bins for each error
		ignore_bins unused_err={[6:7]};
    }
	
	
endgroup

inputs_on_clk	input_group1	= new();
outputs_on_clk	output_group1	= new();

endinterface
