module counter_month (
    input  wire       clk_50Mhz,
    input  wire       rst,
    input  wire       tick_day,     
    input  wire       enable_5,      
    input  wire       mode,         
    input  wire       up,        
    input  wire       down,       
    output reg  [3:0] month_ones,
    output reg  [3:0] month_tens,
    output wire       tick_month    
);

    assign tick_month = (mode == 1'b0) && tick_day && (month_tens == 4'd1) && (month_ones == 4'd2);

    always @(posedge clk_50Mhz or negedge rst) begin
        if (!rst) begin
            month_ones <= 4'd1;
            month_tens <= 4'd0;
        end
        else begin
            if (mode == 1'b0) begin
                if (tick_day) begin
                    if (month_tens == 4'd1 && month_ones == 4'd2) begin
                        month_ones <= 4'd1;
                        month_tens <= 4'd0;
                    end
                    else if (month_ones == 4'd9) begin
                        month_ones <= 4'd0;
                        month_tens <= 4'd1;
                    end
                    else begin
                        month_ones <= month_ones + 1'b1;
                    end
                end
            end
            else begin
                if (enable_5) begin
                    if (up) begin
                        if (month_tens == 4'd1 && month_ones == 4'd2) begin
                            month_ones <= 4'd1;
                            month_tens <= 4'd0;
                        end
                        else if (month_ones == 4'd9) begin
                            month_ones <= 4'd0;
                            month_tens <= 4'd1;
                        end
                        else begin
                            month_ones <= month_ones + 1'b1;
                        end
                    end
                    else if (down) begin
                        if (month_tens == 4'd0 && month_ones == 4'd1) begin
                            month_ones <= 4'd2;
                            month_tens <= 4'd1;
                        end
                        else if (month_tens == 4'd1 && month_ones == 4'd0) begin
                            month_ones <= 4'd9;
                            month_tens <= 4'd0;
                        end
                        else begin
                            month_ones <= month_ones - 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule