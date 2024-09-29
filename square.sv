module square (
    input wire [12:0] x_given,      
    input wire [12:0] y_given,       
    input wire [12:0] x_target,     
    input wire [12:0] y_target,
    input wire [10:0] width,
    input wire [19:0] color_given, //Color
    output wire[19:0] color_output,    // 4-bit sum output
    output wire square_state          // Carry-out
);

if ( x_given > x_target  and x_given < (x_target + width)) begin
    if ( y_given < y_target and y_given > y_target ) begin
        color_output <= color_given;
        square_state <= 1;
    end
    color_output <= color_given;
        square_state <= 1;
end
return true,color_given


else return false, color_given

end module