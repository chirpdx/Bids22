//////////////////////////////////////////////////////////////
// coverage.sv - Contains various covergroups based on interface signals only
//
// Author:	        Chirag Chaudhari (chir@pdx.edu)
// 					Amogh Morey
// Last Modified:	15-Apr-2022
// 
//
////////////////////////////////////////////////////////////////
program cgroups(bids22inf.bids22arch bid);

covergroup inputs_group@(posedge bid.clk);
    
    inCdata: coverpoint bid.C_data;
	//64 default bins

    inCop: coverpoint bid.C_op iff(!bid.C_start){
		bins no_op = {0};
        bins used[]={[1:8]};
		bins unused = {[9:$]};
    }

    inCstart: coverpoint bid.C_start{
        bins c_0={0};
        bins c_1={1};
    }

    // cover bid amounts only when bid signal is high and round is started
    inXbidAmt: coverpoint bid.X_bidAmt iff(bid.X_bid === 1 && bid.C_start === 1);
	//64 default bins

    // bids can be actively covered only when C_start is 1, i.e. round is started
    inXbid: coverpoint bid.X_bid iff(bid.C_start === 1){
        bins x_0={0};
        bins x_1={1};
    }

    inXretract: coverpoint bid.X_retract iff(bid.C_start === 1){
        bins x_retract_0={0};
        bins x_retract_1={1};
    }

    inYbidAmt: coverpoint bid.Y_bidAmt iff(bid.Y_bid === 1 && bid.C_start === 1);
	//64 default bins
    //cross bid.Y_bidAmt, bid.Y_bid
    //bins Y_one = binsof(bid.Y_bid) intersect { 0 };

    inYbid: coverpoint bid.Y_bid iff(bid.C_start === 1){
        bins y_0={0};
        bins y_1={1};
    }
	
    inYretract: coverpoint bid.Y_retract iff(bid.C_start === 1){
        bins y_retract_0={0};
        bins y_retract_1={1};
    }

    inZbidAmt: coverpoint bid.Z_bidAmt iff(bid.Z_bid === 1 && bid.C_start === 1);
	//64 default bins
	
    inZbid: coverpoint bid.Z_bid iff(bid.C_start === 1){
        bins z_0={0};
        bins z_1={1};
    }

    inZretract:coverpoint bid.Z_retract iff(bid.C_start === 1){
        bins z_retract_0={0};
        bins z_retract_1={1};
    }

	// experimental purpose coverpoint with signal name
    // will create bins when C_start = 0 also
	incross_startXbid: cross inCstart, bid.X_bid;
	incross_startYbid: cross inCstart, bid.Y_bid;
	incross_startZbid: cross inCstart, bid.Z_bid;
	incross_startXret: cross inCstart, bid.X_retract;
	incross_startYret: cross inCstart, bid.Y_retract;
	incross_startZret: cross inCstart, bid.Z_retract;

endgroup

covergroup outputs_group@(posedge bid.clk);
    
    // cover X, Y or Z win only when round is over
    opXwin: coverpoint bid.X_win iff(bid.roundOver === 1);
	opYwin: coverpoint bid.Y_win iff(bid.roundOver === 1);
	opZwin: coverpoint bid.Z_win iff(bid.roundOver === 1);
	
	opmaxBid: coverpoint bid.maxBid iff(bid.roundOver === 1);
	//64 default bins
	
    // cross coverage of when win occurs with the corresponding maxBid value
	opcrossmaxBidXwin: cross opXwin, opmaxBid{
        ignore_bins maxBidXwin = binsof(opXwin) intersect { 0 };        // ignoring X_win bins when X_win is 0
    }
	opcrossmaxBidYwin: cross opYwin, opmaxBid{
        ignore_bins maxBidXwin = binsof(opYwin) intersect { 0 };
    }
	opcrossmaxBidZwin: cross opZwin, opmaxBid{
        ignore_bins maxBidXwin = binsof(opZwin) intersect { 0 };
    }
	
	opXerr: coverpoint bid.X_err{
        bins no_err={0};
        bins x_err={[1:3]};		//separate bins for each error
    }

    opYerr: coverpoint bid.Y_err{
        bins no_err={0};
        bins y_err={[1:3]};
    }

    opZerr: coverpoint bid.Z_err{
        bins no_err={0};
        bins z_err={[1:3]};
    }

    // specifically coverage bin for participant error of round inactive found when C_start is 0
    opXerrinactive: coverpoint bid.X_err iff(bid.C_start === 0){
        bins round_inactive = {1};
    }

    opYerrinactive: coverpoint bid.Y_err iff(bid.C_start === 0){
        bins round_inactive = {1};
    }

    opZerrinactive: coverpoint bid.Z_err iff(bid.C_start === 0){
        bins round_inactive = {1};
    }
	
	opXack: coverpoint bid.X_ack iff(bid.C_start === 1);
	opYack: coverpoint bid.Y_ack iff(bid.C_start === 1);
	opZack: coverpoint bid.Z_ack iff(bid.C_start === 1);
	
	opallErrors: coverpoint bid.err{
        bins no_err={0};
        bins actual_err[]={[1:5]};		//separate bins for each error
		ignore_bins unused_err={[6:7]};
    }

    opXvalue: coverpoint bid.X_balance iff(bid.roundOver === 1);
    // 64 auto bins
    opYvalue: coverpoint bid.Y_balance iff(bid.roundOver === 1);
    opZvalue: coverpoint bid.Z_balance iff(bid.roundOver === 1);

    opready: coverpoint bid.ready;
    oproundover: coverpoint bid.roundOver;
	
endgroup

//Cover maxbid and roundover when reset is 0(reset applied)
covergroup reset_zero_group@(posedge bid.clk);

    maxbidzero: coverpoint bid.maxBid iff !bid.reset_n{
        bins zero={0};
    }

    roundOverzero: coverpoint bid.roundOver iff !bid.reset_n{
        bins zero={0};
    }

endgroup

inputs_group	    input_group1	= new();
outputs_group	    output_group1	= new();
reset_zero_group	rst_zero_group1	= new();

endprogram