/****************************************************************************
FILENAME     :  video_uut.sv
PROJECT      :  Hack the Hill 2024
****************************************************************************/

/*  INSTANTIATION TEMPLATE  -------------------------------------------------

video_uut video_uut (       
    .clk_i          ( ),//               
    .cen_i          ( ),//
    .vid_sel_i      ( ),//
    .vdat_bars_i    ( ),//[19:0]
    .vdat_colour_i  ( ),//[19:0]
    .fvht_i         ( ),//[ 3:0]
    .fvht_o         ( ),//[ 3:0]
    .video_o        ( ) //[19:0]
);

-------------------------------------------------------------------------- */


module video_uut (
    input  wire         clk_i           ,// clock
    input  wire         cen_i           ,// clock enable
    input  wire         vid_sel_i       ,// select source video
    input  wire [19:0]  vdat_bars_i     ,// input video {luma, chroma}
    input  wire [19:0]  vdat_colour_i   ,// input video {luma, chroma}
    input  wire [3:0]   fvht_i          ,// input video timing signals
    output wire [3:0]   fvht_o          ,// 1 clk pulse after falling edge on input signal
    output wire [19:0]  video_o          // 1 clk pulse after any edge on input signal
); 

reg [19:0]  vid_d1;
reg [19:0]  vid_d2;
reg [3:0]   fvht_d1;
/* synthesis keep*/ reg [12:0]  pos_y; // 12 bit register representing the y position of pixel we are working on
/* synthesis keep*/ reg [12:0]  pos_x = 13'b0000000000000; // 12 bit register representing the x position of pixel we are working on
/* synthesis keep*/ reg [2:0] v_sample;
/* synthesis keep*/ reg [2:0] h_sample;


// reg [10:0] offset_x;
// reg [10:0] offset_y;

// reg flag_x = 1'b1;
// reg flag_y = 1'b1;
// reg [6:0] count;

alternate_values alternate(
    .clk (cen_i),
    .luma (10'b0100110001),
	 .cb(10'b0101010100),
	 .cr(10'b1111111110),
    .out (vid_d2)
);

//Square information 
// 0-9 Color L 1010100010  
// 10-19 CB 0010110000 
// 20-29 CE 1000011111
// 30-40 00000000111 x_target //offset_x 11 bits
// 41-51 y_target //offset_y 11 bits


reg [34:0] square_array [3:0];

initial begin
    square_array[0][10:0] = 11'b00000001111; // 0-10 00000000111  //offset_x 11 bits
    square_array[0][21:11] = 11'b00000011111; // 11-21 00000001111  //offset_y 11 bits
    square_array[0][22] = 1'b1; // 22 flag_x
    square_array[0][23] = 1'b1; // 23 flag_y
    square_array[0][33:24] = 10'b0000110010; // 24-33 width 10 bits
	 square_array[0][34] = 1'b0;

    square_array[1][10:0] = 11'b00000000000; // 0-10 00000000111  //offset_x 11 bits
    square_array[1][21:11] = 11'b00000000000; // 11-21 00000001111  //offset_y 11 bits
    square_array[1][22] = 1'b1; // 22 flag_x
    square_array[1][23] = 1'b1; // 23 flag_y
    square_array[1][33:24] = 10'b0000010010; // 24-33 width 10 bits
	 square_array[1][34] = 1'b0; //truth
	 
	 
	 square_array[2][10:0] = 11'b00000110011; // 0-10 00000000111  //offset_x 11 bits
    square_array[2][21:11] = 11'b00000000111; // 11-21 00000001111  //offset_y 11 bits
    square_array[2][22] = 1'b1; // 22 flag_x
    square_array[2][23] = 1'b1; // 23 flag_y
    square_array[2][33:24] = 10'b0000001110; // 24-33 width 10 bits
	 square_array[2][34] = 1'b0;

    square_array[3][10:0] = 11'b00000000110; // 0-10 00000000111  //offset_x 11 bits
    square_array[3][21:11] = 11'b00001100000; // 11-21 00000001111  //offset_y 11 bits
    square_array[3][22] = 1'b1; // 22 flag_x
    square_array[3][23] = 1'b1; // 23 flag_y
    square_array[3][33:24] = 10'b0000010011; // 24-33 width 10 bits
	 square_array[3][34] = 1'b0; //truth
end 

integer i;

always @(posedge clk_i) begin
	if(cen_i) begin
		    if ((h_sample == 3'b100)) begin // end of the horizontal line
		    	pos_x <= 13'b0000000000000;
		    end else begin // no new line so just increment pos_x
		    	pos_x <= pos_x + 1; 
		    end
		  vid_d1 <= vdat_bars_i; 
        for (i = 0; i < 4; i = i + 1) begin
    
		    	if (square_array[i][21:11] > 1065) begin //Set the direction based on the y position
		    		square_array[i][23] <= 0; 
		    	end 
		    	if (square_array[i][21:11] < 35) begin 
		    		square_array[i][23] <= 1;
		    	end 

		    	if (square_array[i][10:0] > 1869) begin //Set the direction based on the x position
		    		square_array[i][22] <= 0; 
		    	end 
		    	if (square_array[i][10:0] < 1) begin 
		    		square_array[i][22] <= 1;
		    	end 
    
		    	if ((pos_x > (0 + square_array[i][10:0]) && (pos_x < (square_array[i][33:24] + square_array[i][10:0])))) begin
		    		if ((pos_y > (10 + square_array[i][21:11])) && ( pos_y < (10 + square_array[i][33:24]  + square_array[i][21:11]))) begin
		    			vid_d1 <= vid_d2;
		    		end 
		    	end 
		    	
        end //for end
		 
		
		
		
		fvht_d1 <= fvht_i;
    end
end


always @(posedge clk_i) begin //Detecting stuff for a new frame
		if (cen_i) begin
			v_sample <= {v_sample[1],v_sample[0],fvht_i[2]};
		end
end
		
		
always @(posedge clk_i) begin //We are detecting for a start of a new line 
	if (cen_i) begin
		h_sample <= {h_sample[1],h_sample[0],fvht_i[1]};
	end	 
end 

always @(posedge clk_i) begin //Start of new line and/or new frame
	if (cen_i) begin
		if (h_sample == 3'b001) begin
            if (v_sample == 3'b001) begin
				pos_y <= 13'b0000000000000;
				
                for (i = 0; i < 4; i = i + 1) begin
				    if (square_array[i][22]) begin 
				    	square_array[i][10:0] <= square_array[i][10:0] + i + 1; 
				    end 
				    else begin 
				    	square_array[i][10:0] <= square_array[i][10:0] - i - 1;
				    end
				    if (square_array[i][23]) begin 
				    	square_array[i][21:11] <= square_array[i][21:11] + i + 1; 
				    end 
				    else begin 
				    	square_array[i][21:11] <= square_array[i][21:11] - i - 1;
				    end
             end
			end
			else begin
				pos_y <= pos_y + 1;
			end
		end
	end			
end



// OUTPUT
assign fvht_o  = fvht_d1;
assign video_o = vid_d1;

endmodule
