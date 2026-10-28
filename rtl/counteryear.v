module counter_year (
    input  wire       clk_50Mhz,
    input  wire       rst,
    input  wire       tick_month,      
    input  wire       enable_6,       
    input  wire       up,             
    input  wire       down,          
    input  wire       mode,           
    output reg  [3:0] year_ones,
    output reg  [3:0] year_tens,
    output reg  [3:0] year_hundreds,
    output reg  [3:0] year_thousands
);

    always @(posedge clk_50Mhz or negedge rst) begin
        if (!rst) begin
            year_ones      <= 4'd4;
            year_tens      <= 4'd2;
            year_hundreds  <= 4'd0;
            year_thousands <= 4'd2; // Mac dinh nam 2024
        end
        else begin
            if (mode == 1'b0) begin
                if (tick_month) begin
                    if (year_ones == 4'd9) begin
                        year_ones <= 4'd0;
                        if (year_tens == 4'd9) begin
                            year_tens <= 4'd0;
                            if (year_hundreds == 4'd9) begin
                                year_hundreds <= 4'd0;
                                if (year_thousands == 4'd9) begin
                                    year_thousands <= 4'd0;
                                end
                                else begin
                                    year_thousands <= year_thousands + 1'b1;
                                end
                            end
                            else begin
                                year_hundreds <= year_hundreds + 1'b1;
                            end
                        end
                        else begin
                            year_tens <= year_tens + 1'b1;
                        end
                    end
                    else begin
                        year_ones <= year_ones + 1'b1;
                    end
                end
            end
            else begin
                if (enable_6) begin
                    if (up) begin
                        if (year_ones == 4'd9) begin
                            year_ones <= 4'd0;
                            if (year_tens == 4'd9) begin
                                year_tens <= 4'd0;
                                if (year_hundreds == 4'd9) begin
                                    year_hundreds <= 4'd0;
                                    if (year_thousands == 4'd9) begin
                                        year_thousands <= 4'd0;
                                    end
                                    else begin
                                        year_thousands <= year_thousands + 1'b1;
                                    end
                                end
                                else begin
                                    year_hundreds <= year_hundreds + 1'b1;
                                end
                            end
                            else begin
                                year_tens <= year_tens + 1'b1;
                            end
                        end
                        else begin
                            year_ones <= year_ones + 1'b1;
                        end
                    end
                    else if (down) begin 
                        if (year_ones == 4'd0) begin
                            year_ones <= 4'd9;
                            if (year_tens == 4'd0) begin 
                                year_tens <= 4'd9;
                                if (year_hundreds == 4'd0) begin
                                    year_hundreds <= 4'd9;
                                    if (year_thousands == 4'd0) begin
                                        year_thousands <= 4'd9; 
                                    end
                                    else begin
                                        year_thousands <= year_thousands - 1'b1;
                                    end
                                end
                                else begin
                                    year_hundreds <= year_hundreds - 1'b1;
                                end
                            end
                            else begin
                                year_tens <= year_tens - 1'b1;
                            end
                        end
                        else begin
                            year_ones <= year_ones - 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule