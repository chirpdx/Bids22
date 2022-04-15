interface bids22inf(input logic clk,reset_n);
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
		output roundOver,
		output X_err, 
		output Y_err, 
		output Z_err, 
		output err,
		output X_balance, 
		output Y_balance, 
		output Z_balance,
		output maxBid);
	covergroup bids22cg1@(posedge clk);
    option.per_instance=1;
    
    coverpoint C_data{
        bins data_1={[0:7]};
        bins data_2={[7:15]};
        bins data_3={[15:23]};
        bins data_4={[23:31]};
    }

    coverpoint C_op{
        bins op_code[]={[0:3]};
    }

    coverpoint C_start{
        bins c_0={0};
        bins c_1={1};
    }

    coverpoint X_bidAmt{
        bins x_amt_low={[0:7]};
        bins x_amt_high={[7:15]};
    }

    coverpoint X_bid{
        bins x_0={0};
        bins x_1={1};
    }

    coverpoint X_retract{
        bins x_retract_0={0};
        bins x_retract_1={1};
    }

    coverpoint Y_bidAmt{
        bins y_amt_low={[0:7]};
        bins y_amt_high={[7:15]};
    }

    coverpoint Y_bid{
        bins y_0={0};
        bins y_1={1};
    }
    coverpoint Y_retract{
        bins y_retract_0={0};
        bins y_retract_1={1};
    }

    coverpoint Z_bidAmt{
        bins z_amt_low={[0:7]};
        bins z_amt_high={[7:15]};
    }
    coverpoint Z_bid{
        bins z_0={0};
        bins z_1={1};

    }
    coverpoint Z_retract{
        bins z_retract_0={0};
        bins z_retract_1={1};
    }

    coverpoint X_err{
        bins x_e={0};
        bins x_e_1={1};
    }

    coverpoint Y_err{
        bins y_e={0};
        bins y_e_1={1};
    }

    coverpoint Z_err{
        bins z_e={0};
        bins z_1={1};
    }

    coverpoint maxBid{
        bins max_out={[0:31]};
    }
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
bids22cg1 gi=new();

endinterface
