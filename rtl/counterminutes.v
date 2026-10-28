module counter_minutes (
    input  wire       clk_50Mhz,
    input  wire       rst,
    input  wire       tick_second,   
    input  wire       enable_2,     
    input  wire       mode,          
    input  wire       up,           
    input  wire       down,       
    output reg  [3:0] min_ones,
    output reg  [3:0] min_tens,
    output wire       tick_minutes   
);

    assign tick_minutes = (mode == 1'b0) && tick_second && (min_tens == 4'd5) && (min_ones == 4'd9);

    always @(posedge clk_50Mhz or negedge rst) begin
        if (!rst) begin
            min_ones <= 4'd0;
            min_tens <= 4'd0;
        end
        else begin
            if (mode == 1'b0) begin
                if (tick_second) begin
                    if (min_ones == 4'd9) begin
                        min_ones <= 4'd0;
                        if (min_tens == 4'd5) begin
                            min_tens <= 4'd0;
                        end
                        else begin
                            min_tens <= min_tens + 1'b1;
                        end
                    end
                    else begin
                        min_ones <= min_ones + 1'b1;
                    end
                end
            end
            else begin
                if (enable_2) begin
                    if (up) begin
                        if (min_ones == 4'd9) begin
                            min_ones <= 4'd0;
                            if (min_tens == 4'd5) begin
                                min_tens <= 4'd0;
                            end
                            else begin
                                min_tens <= min_tens + 1'b1;
                            end
                        end
                        else begin
                            min_ones <= min_ones + 1'b1;
                        end
                    end
                    else if (down) begin
                        if (min_ones == 4'd0) begin
                            min_ones <= 4'd9;
                            if (min_tens == 4'd0) begin
                                min_tens <= 4'd5;
                            end
                            else begin
                                min_tens <= min_tens - 1'b1;
                            end
                        end
                        else begin
                            min_ones <= min_ones - 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule


