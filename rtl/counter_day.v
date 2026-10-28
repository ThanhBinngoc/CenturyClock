module counter_day (
    input  wire       clk_50Mhz,
    input  wire       rst,
    input  wire       tick_hour,   
    input  wire       mode,         
    input  wire       enable_4,         
    input  wire       up,             
    input  wire       down,        
    input  wire [3:0] max_days_ones,    
    input  wire [3:0] max_days_tens,    
    output reg  [3:0] day_ones,
    output reg  [3:0] day_tens,
    output wire       tick_day        
);

    wire is_max_day = (day_tens == max_days_tens) && (day_ones == max_days_ones);
    wire is_min_day = (day_tens == 4'd0) && (day_ones == 4'd1);
    wire is_overflow = (day_tens > max_days_tens) || ((day_tens == max_days_tens) && (day_ones > max_days_ones));

    assign tick_day = (mode == 1'b0) && tick_hour && (is_max_day || is_overflow);

    always @(posedge clk_50Mhz or negedge rst) begin
        if (!rst) begin
            day_ones <= 4'd1;
            day_tens <= 4'd0;
        end
        else begin
            if (mode == 1'b0) begin
                if (tick_hour) begin
                    if (is_max_day || is_overflow) begin
                        day_ones <= 4'd1;
                        day_tens <= 4'd0;
                    end
                    else if (day_ones == 4'd9) begin
                        day_ones <= 4'd0;
                        day_tens <= day_tens + 1'b1;
                    end
                    else begin
                        day_ones <= day_ones + 1'b1;
                    end
                end
                else if (is_overflow) begin
                    day_ones <= max_days_ones;
                    day_tens <= max_days_tens;
                end
            end
            else begin
                if (enable_4) begin
                    if (up) begin
                        if (is_max_day || is_overflow) begin
                            day_ones <= 4'd1;
                            day_tens <= 4'd0;
                        end
                        else if (day_ones == 4'd9) begin
                            day_ones <= 4'd0;
                            day_tens <= day_tens + 1'b1;
                        end
                        else begin
                            day_ones <= day_ones + 1'b1;
                        end
                    end
                    else if (down) begin
                        if (is_min_day) begin
                            day_ones <= max_days_ones;
                            day_tens <= max_days_tens;
                        end
                        else if (is_overflow) begin
                            day_ones <= max_days_ones;
                            day_tens <= max_days_tens;
                        end
                        else if (day_ones == 4'd0) begin
                            day_ones <= 4'd9;
                            day_tens <= day_tens - 1'b1;
                        end
                        else begin
                            day_ones <= day_ones - 1'b1;
                        end
                    end
                end
                else if (is_overflow) begin
                    day_ones <= max_days_ones;
                    day_tens <= max_days_tens;
                end
            end
        end
    end

endmodule