`timescale 1ns / 1ps
module FIR_tb ;
    parameter inbit = 11;
    parameter outbit = 23;
    parameter n=32;
    parameter numberOfTestPatterns = 1000;
    parameter cycle = 10;

    reg rst;
    reg clk;
    reg signed [inbit-1:0] infixdata [0:numberOfTestPatterns-1];
    reg signed [inbit-1:0] infix;
    reg signed [outbit-1:0] outfixgold [0:numberOfTestPatterns-1];
    wire signed [outbit-1:0] outfix ;
    reg signed [inbit-1:0] tap [0:n-1];
    FIR U1(.rst(rst), .clk(clk), .infix(infix) , .outfix(outfix));

    reg [15:0] count;
    reg [5:0] counttap;
	reg [15:0] countout;
    reg signed [outbit-1 :0] outgold;
    reg signed [inbit-1 :0] coeff;
    initial 
    begin
		$sdf_annotate("./fir_syn.sdf",U1);
        $fsdbDumpfile("FIR.fsdb");
	    $fsdbDumpvars(0,"+mda");
        $fsdbDumpvars();   
		//$toggle_count("U1");
        //$toggle_count_mode(1);
    end
    integer in,coef , gold, in_data, golden_data, i,tap_data;
    initial begin
        in = $fopen("input_fix.txt","r");
        coef = $fopen("coef_fix.txt","r");
        gold = $fopen("out_fix.txt","r");
        for (i=0;i<numberOfTestPatterns;i=i+1)  
        begin
            in_data = $fscanf(in , "%d" , infixdata[i]);
            golden_data = $fscanf(gold , "%d" , outfixgold[i]);
        end
        for (i=0;i<n;i=i+1)  
        begin
            tap_data = $fscanf(coef , "%d" , tap[i]);
        end
    end
    initial begin
        clk = 0;
        rst = 1;
        #(cycle)
        rst = 0;
    end

    always #(cycle/2) clk = ~clk ;
    always@(negedge clk)begin
        if(rst)
            count <= 0;
        else if(count==(numberOfTestPatterns-1))
            count <= 0;
        else
            count <= count+1;
    end
	always@(negedge clk)begin
        if(rst)
            countout <= 0;
		else if(count==0)
			countout <=0;
        else if(countout==(numberOfTestPatterns-1))
            countout <= 0;
        else
            countout <= countout+1;
    end
    always@(negedge clk)begin
        if(rst)
            counttap <= 0;
        else if(counttap==n-1)
            counttap <= 0;
        else
            counttap <= counttap+1;
    end
    always@(negedge clk)begin
        if(rst)
            infix <= 0;
        else
            infix <= infixdata[count];
    end
     always@(negedge clk)begin
        if(!rst)
            coeff <= tap[counttap];
    end
    // display golden out
    always@(negedge clk)begin
        if(!rst)
            outgold <= outfixgold[countout];
    end

	always@(negedge clk)begin
        if(!rst &&count>=2) begin
            if(outfix==outgold) begin
				$display ("////////////// Successful !! //////////////" );
				$display ("\n Correct_Answer: ", outgold,  ",  OUT_DATA: ", outfix );
			end
			else begin
				$display ("\n //// Error//// \n " );
				$display ("\n Correct_Answer: ", outgold,  ",  OUT_DATA: ", outfix );
				//$toggle_count_report_flat("FIR_rtl.tcf", "U1");
				$finish;
			end
		end
    end
	always@(negedge clk)begin
        if(countout==numberOfTestPatterns-1)begin
			YOU_PASS_task;
		end
    end




task YOU_PASS_task;begin
// image_.success;
$display ("----------------------------------------------------------------------------------------------------------------------");
$display ("                                                  Congratulations!                                                    ");
$display ("                                           You have passed all patterns!                                              ");
$display ("                                                                                                                      ");
$display ("                                        Your execution cycles   = %5d cycles                                          ", countout);
$display ("                                        Your clock period       = %.1f ns                                             ", cycle);
$display ("----------------------------------------------------------------------------------------------------------------------");
#(cycle)
$finish;    
end endtask

endmodule
