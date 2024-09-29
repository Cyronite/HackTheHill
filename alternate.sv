
module alternate_values(
    input wire clk,       // Clock signal
	 input wire [9:0] luma,
	 input wire [9:0] cb,
    input wire [9:0] cr, 
    output reg [19:0] out  // Output (for example, 8-bit value)
);


// Flip-flop to store the current state
reg toggle_state;

// Always block triggered on the rising edge of the clock or reset
always @(posedge clk) begin
    
        // Toggle the state and switch between VALUE1 and VALUE2
        toggle_state <= ~toggle_state;
        if (toggle_state) begin
            out <= {luma,cb};
        end else begin
            out <= {luma,cr};
			end
    end


endmodule