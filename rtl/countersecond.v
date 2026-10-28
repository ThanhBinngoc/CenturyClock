module counter_second (
    input  wire       clk_50Mhz,
    input  wire       rst,
    input  wire       tick,         
    input  wire       mode,         
    input  wire       enable_1,      
    input  wire       up,            
    input  wire       down,     
    output reg  [3:0] sec_ones,
    output reg  [3:0] sec_tens,
    output wire       tick_second    
);

    assign tick_second = (mode == 1'b0) && tick && (sec_tens == 4'd5) && (sec_ones == 4'd9);

    always @(posedge clk_50Mhz or negedge rst) begin
        if (!rst) begin
            sec_ones <= 4'd0;
            sec_tens <= 4'd0;
        end
        else begin
            if (mode == 1'b0) begin
                if (tick) begin
                    if (sec_ones == 4'd9) begin
                        sec_ones <= 4'd0;
                        if (sec_tens == 4'd5) begin
                            sec_tens <= 4'd0;
                        end
                        else begin
                            sec_tens <= sec_tens + 1'b1;
                        end
                    end
                    else begin
                        sec_ones <= sec_ones + 1'b1;
                    end
                end
            end
            else begin
                if (enable_1) begin
                    if (up) begin
                        if (sec_ones == 4'd9) begin
                            sec_ones <= 4'd0;
                            if (sec_tens == 4'd5) begin
                                sec_tens <= 4'd0;
                            end
                            else begin
                                sec_tens <= sec_tens + 1'b1;
                            end
                        end
                        else begin
                            sec_ones <= sec_ones + 1'b1;
                        end
                    end
                    else if (down) begin
                        if (sec_ones == 4'd0) begin
                            sec_ones <= 4'd9;
                            if (sec_tens == 4'd0) begin
                                sec_tens <= 4'd5;
                            end
                            else begin
                                sec_tens <= sec_tens - 1'b1;
                            end
                        end
                        else begin
                            sec_ones <= sec_ones - 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule