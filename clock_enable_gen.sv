`timescale 1ns/1ps

module clock_enable_gen #(

    // ============================================================
    // FPGA SYSTEM CLOCK FREQUENCY
    // Example:
    // 100_000_000 = 100 MHz
    // ============================================================

    parameter int CLK_FREQ_HZ = 100_000_000,

    // ============================================================
    // TARGET TICK FREQUENCY
    // Example:
    // 1_000_000 = 1 MHz tick generation
    // ============================================================

    parameter int TICK_FREQ_HZ = 1_000_000

)(
    input  logic clk,
    input  logic rst_n,

    // ============================================================
    // CLOCK ENABLE OUTPUT
    //
    // Pulses HIGH for ONE clk cycle.
    // ============================================================

    output logic tick
);

    // ============================================================
    // NUMBER OF CLOCK CYCLES REQUIRED
    // BEFORE GENERATING TICK
    // ============================================================

    localparam int DIV_COUNT = CLK_FREQ_HZ / TICK_FREQ_HZ;

    // ============================================================
    // COUNTER
    // ============================================================

    logic [$clog2(DIV_COUNT)-1:0] counter;

    // ============================================================
    // CLOCK ENABLE GENERATION
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            counter <= '0;
            tick    <= 1'b0;

        end
        else begin

            // Default:
            // tick LOW unless divider expires

            tick <= 1'b0;

            // Divider reached target count

            if (counter == DIV_COUNT-1) begin

                counter <= '0;

                // Generate ONE-CLOCK pulse

                tick <= 1'b1;

            end
            else begin

                counter <= counter + 1'b1;

            end
        end
    end

endmodule
