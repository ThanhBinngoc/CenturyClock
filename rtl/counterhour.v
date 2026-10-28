module counter_hour (
    input  wire       clk_50Mhz,
    input  wire       rst,
    input  wire       tick_minutes, 
    input  wire       mode,        
    input  wire       enable_3,      
    input  wire       up,        
    input  wire       down,       
    output reg  [3:0] hour_ones,
    output reg  [3:0] hour_tens,
    output wire       tick_hour      
);

    assign tick_hour = (mode == 1'b0) && tick_minutes && (hour_tens == 4'd2) && (hour_ones == 4'd3);

    always @(posedge clk_50Mhz or negedge rst) begin
        if (!rst) begin
            hour_ones <= 4'd0;
            hour_tens <= 4'd0;
        end
        else begin
            if (mode == 1'b0) begin
                if (tick_minutes) begin
                    if (hour_tens == 4'd2 && hour_ones == 4'd3) begin
                        hour_ones <= 4'd0;
                        hour_tens <= 4'd0;
                    end
                    else if (hour_ones == 4'd9) begin
                        hour_ones <= 4'd0;
                        hour_tens <= hour_tens + 1'b1;
                    end
                    else begin
                        hour_ones <= hour_ones + 1'b1;
                    end
                end
            end
            else begin
                if (enable_3) begin
                    if (up) begin
                        if (hour_tens == 4'd2 && hour_ones == 4'd3) begin
                            hour_ones <= 4'd0;
                            hour_tens <= 4'd0;
                        end
                        else if (hour_ones == 4'd9) begin
                            hour_ones <= 4'd0;
                            hour_tens <= hour_tens + 1'b1;
                        end
                        else begin
                            hour_ones <= hour_ones + 1'b1;
                        end
                    end
                    else if (down) begin
                        if (hour_tens == 4'd0 && hour_ones == 4'd0) begin
                            hour_ones <= 4'd3;
                            hour_tens <= 4'd2;
                        end
                        else if (hour_ones == 4'd0) begin
                            hour_ones <= 4'd9;
                            hour_tens <= hour_tens - 1'b1;
                        end
                        else begin
                            hour_ones <= hour_ones - 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule