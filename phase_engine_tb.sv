`timescale 1ns/1ps

module phase_engine_tb;

    logic clk;
    logic rst_n;

    logic tick;

    logic scl_low_phase;
    logic scl_high_phase;
    logic sample_phase;

    logic scl_internal;

    // ============================================================
    // DUT
    // ============================================================

    phase_engine dut (

        .clk            (clk),
        .rst_n          (rst_n),
        .tick           (tick),

        .scl_low_phase  (scl_low_phase),
        .scl_high_phase (scl_high_phase),
        .sample_phase   (sample_phase),

        .scl_internal   (scl_internal)

    );

    // ============================================================
    // CLOCK
    // ============================================================

    initial begin

        clk = 0;

        forever #5 clk = ~clk;

    end

    // ============================================================
    // RESET
    // ============================================================

    initial begin

        rst_n = 0;

        #20;

        rst_n = 1;

    end

    // ============================================================
    // TICK GENERATION
    // ============================================================

    initial begin

        tick = 0;

        forever begin

            #40;

            tick = 1;

            #10;

            tick = 0;

        end
    end

    // ============================================================
    // SIMULATION CONTROL
    // ============================================================

    initial begin

        #500;

        $finish;

    end

endmodule
