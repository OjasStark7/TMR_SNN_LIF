`timescale 1ns / 1ps

module tmr_lif_neuron (
    input signed [15:0] V_in1, V_in2, V_in3,  // Membrane potentials from 3 neurons
    input signed [15:0] I_in1, I_in2, I_in3,  // Input currents from 3 neurons
    input signed [15:0] dt_tau,               // Time constant ratio (Q8.8 format, dt/t)
    input wire clk, rst,                      // Clock and Reset signals
    output reg signed [15:0] V_out,           // TMR-voted membrane potential
    output reg spike                          // TMR-voted spike output
);

    wire signed [15:0] V1, V2, V3;
    wire spike1, spike2, spike3;
    
    lif_neuron_q8_8 neuron1 (.V_in(V_in1), .I_in(I_in1), .dt_tau(dt_tau), .clk(clk), .rst(rst), .V_out(V1), .spike(spike1));
    lif_neuron_q8_8 neuron2 (.V_in(V_in2), .I_in(I_in2), .dt_tau(dt_tau), .clk(clk), .rst(rst), .V_out(V2), .spike(spike2));
    lif_neuron_q8_8 neuron3 (.V_in(V_in3), .I_in(I_in3), .dt_tau(dt_tau), .clk(clk), .rst(rst), .V_out(V3), .spike(spike3));
    
    // Majority voter for membrane potential
    always @(*) begin
        if ((V1 >= V2 && V1 <= V3) || (V1 <= V2 && V1 >= V3))
            V_out = V1;
        else if ((V2 >= V1 && V2 <= V3) || (V2 <= V1 && V2 >= V3))
            V_out = V2;
        else
            V_out = V3;
    end
    
    // Majority voter for spike output
    always @(*) begin
        spike = (spike1 & spike2) | (spike2 & spike3) | (spike1 & spike3);
    end
endmodule
