covergroup bids22(@posedge clk);
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
        bins x_e={1};
    }

    coverpoint Y_err{
        bins y_e={0};
        bins y_e={1};
    }

    coverpoint Z_err{
        bins z_e={0};
        bins z_1={1};
    }

    coverpoint maxBid{
        bins max_out={0:31};
    }

    cross c_start,X_err{
        ignore bins x_error=binsof(c_start)intersect{1};
    }

    cross c_start,Y_err{
        ignore bins y_error=binsof(c_start)intersect{1};
    }

    cross c_start,Z_err{
        ignore bins z_error=binsof(c_start)intersect{1};
    }

    cross X_bidAmt,X_bid{
        ignore bins x= binsof(X_bid)intersect{0};
    }

    cross Y_bidAmt,Y_bid{
        ignore bins y= binsof(Y_bid)intersect{0};
    }

    cross Z_bidAmt,Z_bid{
        ignore bins x= binsof(Z_bid)intersect{0};
    }

    cross maxBid,roundOver{
        ignore bins max=binsof(roundOver)intersect{0};
    }

endgroup