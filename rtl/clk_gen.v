module clk_gen #(
    parameter CLK_FREQ   = 50_000_000, 
    parameter BLINK_FREQ = 2         
)(
    input  wire clk_50Mhz,
    input  wire rst,
    output reg  tick_1hz, 
    output reg  b_hz    
);

    localparam CNT_1HZ_MAX = CLK_FREQ - 1;
    reg [31:0] cnt_1hz;

    always @(posedge clk_50Mhz or negedge rst) begin
        if (!rst) begin
            cnt_1hz  <= 32'd0;
            tick_1hz <= 1'b0;
        end
        else begin
            if (cnt_1hz >= CNT_1HZ_MAX) begin
                cnt_1hz  <= 32'd0;
                tick_1hz <= 1'b1;
            end
            else begin
                cnt_1hz  <= cnt_1hz + 1'b1;
                tick_1hz <= 1'b0;
            end
        end
    end

    localparam CNT_BHZ_HALF = CLK_FREQ / (2 * BLINK_FREQ) - 1;
    reg [31:0] cnt_bhz;

    always @(posedge clk_50Mhz or negedge rst) begin
        if (!rst) begin
            cnt_bhz <= 32'd0;
            b_hz    <= 1'b0;
        end
        else begin
            if (cnt_bhz >= CNT_BHZ_HALF) begin
                cnt_bhz <= 32'd0;
                b_hz    <= ~b_hz;
            end
            else begin
                cnt_bhz <= cnt_bhz + 1'b1;
            end
        end
    end

endmodule