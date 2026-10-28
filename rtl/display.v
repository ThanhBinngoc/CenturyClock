module seven_seg_decoder (
    input  wire [3:0] bcd,
    input  wire       blank, 
    output reg  [6:0] seg   
);

    always @(*) begin
        if (blank) begin
            seg = 7'b111_1111;
        end
        else begin
            case (bcd)
                4'd0: seg = 7'b100_0000; // 0
                4'd1: seg = 7'b111_1001; // 1
                4'd2: seg = 7'b010_0100; // 2
                4'd3: seg = 7'b011_0000; // 3
                4'd4: seg = 7'b001_1001; // 4
                4'd5: seg = 7'b001_0010; // 5
                4'd6: seg = 7'b000_0010; // 6
                4'd7: seg = 7'b111_1000; // 7
                4'd8: seg = 7'b000_0000; // 8
                4'd9: seg = 7'b001_0000; // 9
                default: seg = 7'b111_1111;
            endcase
        end
    end

endmodule

module display (
    input  wire       sw_dis,      
    input  wire       blink,         
    input  wire       enable_1,       
    input  wire       enable_2,       
    input  wire       enable_3,      
    input  wire       enable_4,    
    input  wire       enable_5,    
    input  wire       enable_6,
    input  wire [3:0] sec_ones,
    input  wire [3:0] sec_tens,
    input  wire [3:0] min_ones,
    input  wire [3:0] min_tens,
    input  wire [3:0] hour_ones,
    input  wire [3:0] hour_tens,
    input  wire [3:0] day_ones,
    input  wire [3:0] day_tens,
    input  wire [3:0] month_ones,
    input  wire [3:0] month_tens,
    input  wire [3:0] year_ones,
    input  wire [3:0] year_tens,
    input  wire [3:0] year_hundreds,
    input  wire [3:0] year_thousands,
    output wire [6:0] hex7,
    output wire [6:0] hex6,
    output wire [6:0] hex5,
    output wire [6:0] hex4,
    output wire [6:0] hex3,
    output wire [6:0] hex2,
    output wire [6:0] hex1,
    output wire [6:0] hex0
);

    reg [3:0] d7, d6, d5, d4, d3, d2, d1, d0;
    reg       b7, b6, b5, b4, b3, b2, b1, b0;

    always @(*) begin
        if (sw_dis == 1'b0) begin

            d7 = hour_tens;
            d6 = hour_ones;
            b7 = enable_3 & blink;
            b6 = enable_3 & blink;

            d5 = min_tens;
            d4 = min_ones;
            b5 = enable_2 & blink;
            b4 = enable_2 & blink;

            d3 = sec_tens;
            d2 = sec_ones;
            b3 = enable_1 & blink;
            b2 = enable_1 & blink;

            d1 = 4'd0;
            d0 = 4'd0;
            b1 = 1'b1;
            b0 = 1'b1;
        end
        else begin
            d7 = day_tens;
            d6 = day_ones;
            b7 = enable_4 & blink;
            b6 = enable_4 & blink;

            d5 = month_tens;
            d4 = month_ones;
            b5 = enable_5 & blink;
            b4 = enable_5 & blink;

            d3 = year_thousands;
            d2 = year_hundreds;
            d1 = year_tens;
            d0 = year_ones;
            b3 = enable_6 & blink;
            b2 = enable_6 & blink;
            b1 = enable_6 & blink;
            b0 = enable_6 & blink;
        end
    end

    seven_seg_decoder u_seg7 (.bcd(d7), .blank(b7), .seg(hex7));
    seven_seg_decoder u_seg6 (.bcd(d6), .blank(b6), .seg(hex6));
    seven_seg_decoder u_seg5 (.bcd(d5), .blank(b5), .seg(hex5));
    seven_seg_decoder u_seg4 (.bcd(d4), .blank(b4), .seg(hex4));
    seven_seg_decoder u_seg3 (.bcd(d3), .blank(b3), .seg(hex3));
    seven_seg_decoder u_seg2 (.bcd(d2), .blank(b2), .seg(hex2));
    seven_seg_decoder u_seg1 (.bcd(d1), .blank(b1), .seg(hex1));
    seven_seg_decoder u_seg0 (.bcd(d0), .blank(b0), .seg(hex0));

endmodule