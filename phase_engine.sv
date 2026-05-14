`timescale 1ns/1ps

module phase_engine (

    input  logic clk,
    input  logic rst_n,

    // ============================================================
    // TICK INPUT
    //
    // Phase advances ONLY when tick arrives.
    // Tick comes from clock_enable_gen.
    // ============================================================

    input  logic tick,

    // ============================================================
    // PHASE OUTPUTS
    // ============================================================

    output logic scl_low_phase,
    output logic scl_high_phase,
    output logic sample_phase,

    // ============================================================
    // GENERATED SCL STATE
    // ============================================================

    output logic scl_internal
);

    // ============================================================
    // PHASE STATE MACHINE
    // ============================================================

    typedef enum logic [1:0] {

        PHASE_SCL_LOW,
        PHASE_SCL_HIGH,
        PHASE_SAMPLE

    } phase_t;

    phase_t current_phase;

    // ============================================================
    // PHASE TRANSITIONS
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            current_phase <= PHASE_SCL_LOW;

        end
        else begin

            if (tick) begin

                case (current_phase)

                    // ============================================
                    // LOW -> HIGH
                    // ============================================

                    PHASE_SCL_LOW:
                        current_phase <= PHASE_SCL_HIGH;

                    // ============================================
                    // HIGH -> SAMPLE
                    // ============================================

                    PHASE_SCL_HIGH:
                        current_phase <= PHASE_SAMPLE;

                    // ============================================
                    // SAMPLE -> LOW
                    // ============================================

                    PHASE_SAMPLE:
                        current_phase <= PHASE_SCL_LOW;

                    default:
                        current_phase <= PHASE_SCL_LOW;

                endcase
            end
        end
    end

    // ============================================================
    // PHASE OUTPUT DECODING
    // ============================================================

    always_comb begin

        // Default outputs

        scl_low_phase  = 1'b0;
        scl_high_phase = 1'b0;
        sample_phase   = 1'b0;

        scl_internal   = 1'b0;

        case (current_phase)

            // ====================================================
            // SCL LOW PHASE
            //
            // SDA allowed to change here.
            // ====================================================

            PHASE_SCL_LOW: begin

                scl_low_phase = 1'b1;

                scl_internal = 1'b0;

            end

            // ====================================================
            // SCL HIGH PHASE
            //
            // SDA must remain stable.
            // ====================================================

            PHASE_SCL_HIGH: begin

                scl_high_phase = 1'b1;

                scl_internal = 1'b1;

            end

            // ====================================================
            // SAMPLE PHASE
            //
            // Sampling performed here.
            // ====================================================

            PHASE_SAMPLE: begin

                sample_phase = 1'b1;

                scl_internal = 1'b1;

            end

            default: begin

                scl_low_phase = 1'b1;

                scl_internal = 1'b0;

            end
        endcase
    end

endmodule
