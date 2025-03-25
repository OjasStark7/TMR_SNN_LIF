`timescale 1ns / 1ps

module lif_neuron_q8_8 (
    input signed [15:0] V_in,   // Membrane potential (Q8.8)
    input signed [15:0] I_in,   // Input current (Q8.8)
    input signed [15:0] dt_tau, // Time constant ratio (Q8.8)
    input wire clk, rst,        // Clock and Reset
    output reg signed [15:0] V_out, // Updated membrane potential
    output reg spike              // Spike flag
);

    wire signed [15:0] delta_V, V_updated;
    reg signed [15:0] threshold = 16'h3200; // 50.0 in Q8.8

    // Instantiate fixed-point arithmetic module
    fixed_point_q8_8 adder (.a(I_in), .b(-V_in), .op(2'b01), .result(delta_V)); // I_in - V_in

    fixed_point_q8_8 multiplier (.a(delta_V), .b(dt_tau), .op(2'b10), .result(V_updated)); // (I_in - V_in) * dt_tau

    always @(posedge clk or posedge rst) begin
        if (rst)
            V_out <= 16'h0000; // Reset potential to 0.0
        else begin
		  // LIF update equation: V = V + (dt/tau) * (I - V)
            V_out <= V_in + V_updated; // V_updated=(dt/tau) * (I - V)
            if (V_out >= threshold) begin
                spike <= 1;
                V_out <= 16'h0000; // Reset potential after spike
            end else
                spike <= 0;
        end
    end

endmodule

