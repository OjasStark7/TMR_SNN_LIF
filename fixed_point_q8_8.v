`timescale 1ns / 1ps

module fixed_point_q8_8 (
    input signed [15:0] a, // Q8.8 fixed-point input
    input signed [15:0] b, // Q8.8 fixed-point input
    input wire [1:0] op,   // Operation: 00 = add, 01 = sub, 10 = mul
    output reg signed [15:0] result
);

    wire signed [31:0] mul_temp; // Temporary storage for multiplication
    reg signed [15:0] temp_result;
    
    always @(*) begin
        case (op)
            2'b00: temp_result = a + b;  // Addition
            2'b01: temp_result = a - b;  // Subtraction
            2'b10: temp_result = (a * b) >>> 8; // Multiplication with scaling
            default: temp_result = 16'b0;
        endcase
        
        // Clamping to -128 to 127 (Q8.8 format)
        if (temp_result > 16'sh7FFF) 
            result = 16'sh7FFF;  // Max value (127.996)
        else if (temp_result < 16'sh8000) 
            result = 16'sh8000;  // Min value (-128.0)
        else
            result = temp_result;
    end
    
endmodule
