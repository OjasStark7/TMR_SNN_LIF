`timescale 1ns / 1ps

module tmr_lif_neuron_tb;
    
    reg signed [15:0] V_in1, V_in2, V_in3;
    reg signed [15:0] I_in1, I_in2, I_in3;
    reg signed [15:0] dt_tau;
    reg clk, rst;
    wire signed [15:0] V_out;
    wire spike;
    
    // Instantiate the TMR LIF neuron module
    tmr_lif_neuron uut (
        .V_in1(V_in1), .V_in2(V_in2), .V_in3(V_in3),
        .I_in1(I_in1), .I_in2(I_in2), .I_in3(I_in3),
        .dt_tau(dt_tau),
        .clk(clk),
        .rst(rst),
        .V_out(V_out),
        .spike(spike)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    initial begin
        // Monitor output values
        $monitor("Time=%0t | V_out=%h | spike=%b", $time, V_out, spike);
        
        // Initialize signals
        clk = 0;
        rst = 1;
        dt_tau = 16'h0100;  // Example: dt/t = 1.0 in Q8.8
        #10 rst = 0;  // Release reset

        // Test Case 1: All neurons receive the same input current
        V_in1 = 16'h0000;  
        V_in2 = 16'h0000;
        V_in3 = 16'h0000;
        I_in1 = 16'h1000;  
        I_in2 = 16'h1000;
        I_in3 = 16'h1000;
        #100;

        // Test Case 2: One neuron deviates (fault scenario)
        I_in1 = 16'h1200;  
        I_in2 = 16'h1000;
        I_in3 = 16'h1000;
        #100;

        // Test Case 3: All neurons reach threshold
        V_in1 = 16'h3200;  
        V_in2 = 16'h3200;
        V_in3 = 16'h3200;
        #50;

        // Test Case 4: One neuron has a fault in output
        V_in1 = 16'h3500;  
        V_in2 = 16'h3200;
        V_in3 = 16'h3200;
        #50;

        // Test Case 5: Two neurons have faults in output
        V_in1 = 16'h3500;  
        V_in2 = 16'h3500;
        V_in3 = 16'h3200;
        #50;

        // Test Case 6: One neuron below threshold
        V_in1 = 16'h1800;  
        V_in2 = 16'h3200;
        V_in3 = 16'h1800;
        #50;
        
        // Test Case 7: One neuron above threshold
        V_in1 = 16'h4800;  
        V_in2 = 16'h3200;
        V_in3 = 16'h4800;
        #50;
        
        // Test Case 8: Varying neuron values
        V_in1 = 16'h4800;  
        V_in2 = 16'h4000;
        V_in3 = 16'h2800;
        #50;

        // Randomized Test Case
        repeat (5) begin
            V_in1 = $random;
            V_in2 = $random;
            V_in3 = $random;
            I_in1 = $random;
            I_in2 = $random;
            I_in3 = $random;
            #50;
        end
        
        $finish;
    end

endmodule
