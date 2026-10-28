module century_clock #(
    parameter CLK_FREQ   = 50_000_000, 
    parameter BLINK_FREQ = 2
)(
    input  wire       clk_50Mhz,       
    input  wire       rst,            
    input  wire       mode,            
    input  wire [1:0] se,              
    input  wire       btn_up,      
    input  wire       btn_down,      
    input  wire       sw_dis,          
    // Cac dau ra hien thi LED 7 doan (Active-Low)
    output wire [6:0] hex7,
    output wire [6:0] hex6,
    output wire [6:0] hex5,
    output wire [6:0] hex4,
    output wire [6:0] hex3,
    output wire [6:0] hex2,
    output wire [6:0] hex1,
    output wire [6:0] hex0,
    // Cac dau ra BCD phuc vu giam sat / mo phong / mo rong
    output wire [3:0] sec_ones,
    output wire [3:0] sec_tens,
    output wire [3:0] min_ones,
    output wire [3:0] min_tens,
    output wire [3:0] hour_ones,
    output wire [3:0] hour_tens,
    output wire [3:0] day_ones,
    output wire [3:0] day_tens,
    output wire [3:0] month_ones,
    output wire [3:0] month_tens,
    output wire [3:0] year_ones,
    output wire [3:0] year_tens,
    output wire [3:0] year_hundreds,
    output wire [3:0] year_thousands,
    output wire       is_leap_year
);

    wire       tick_1hz;
    wire       b_hz;
    wire       enable_1, enable_2, enable_3, enable_4, enable_5, enable_6;
    wire       up_pulse, down_pulse;
    wire       blink;
    wire       tick_second, tick_minutes, tick_hour, tick_day, tick_month;
    wire [3:0] max_days_ones, max_days_tens;

    clk_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BLINK_FREQ(BLINK_FREQ)
    ) u_clk_gen (
        .clk_50Mhz (clk_50Mhz),
        .rst       (rst),
        .tick_1hz  (tick_1hz),
        .b_hz      (b_hz)
    );

    controller u_controller (
        .clk_50Mhz  (clk_50Mhz),
        .rst        (rst),
        .mode       (mode),
        .sw_dis     (sw_dis),
        .se         (se),
        .btn_up     (btn_up),
        .btn_down   (btn_down),
        .b_hz       (b_hz),
        .enable_1   (enable_1),
        .enable_2   (enable_2),
        .enable_3   (enable_3),
        .enable_4   (enable_4),
        .enable_5   (enable_5),
        .enable_6   (enable_6),
        .up_pulse   (up_pulse),
        .down_pulse (down_pulse),
        .blink      (blink)
    );

    counter_second u_counter_second (
        .clk_50Mhz   (clk_50Mhz),
        .rst         (rst),
        .tick        (tick_1hz),
        .mode        (mode),
        .enable_1    (enable_1),
        .up          (up_pulse),
        .down        (down_pulse),
        .sec_ones    (sec_ones),
        .sec_tens    (sec_tens),
        .tick_second (tick_second)
    );

    counter_minutes u_counter_minutes (
        .clk_50Mhz    (clk_50Mhz),
        .rst          (rst),
        .tick_second  (tick_second),
        .enable_2     (enable_2),
        .mode         (mode),
        .up           (up_pulse),
        .down         (down_pulse),
        .min_ones     (min_ones),
        .min_tens     (min_tens),
        .tick_minutes (tick_minutes)
    );

    counter_hour u_counter_hour (
        .clk_50Mhz    (clk_50Mhz),
        .rst          (rst),
        .tick_minutes (tick_minutes),
        .mode         (mode),
        .enable_3     (enable_3),
        .up           (up_pulse),
        .down         (down_pulse),
        .hour_ones    (hour_ones),
        .hour_tens    (hour_tens),
        .tick_hour    (tick_hour)
    );

    year_detect u_year_detect (
        .month_ones     (month_ones),
        .month_tens     (month_tens),
        .year_ones      (year_ones),
        .year_tens      (year_tens),
        .year_hundreds  (year_hundreds),
        .year_thousands (year_thousands),
        .max_days_ones  (max_days_ones),
        .max_days_tens  (max_days_tens),
        .is_leap_year   (is_leap_year)
    );

    counter_day u_counter_day (
        .clk_50Mhz     (clk_50Mhz),
        .rst           (rst),
        .tick_hour     (tick_hour),
        .mode          (mode),
        .enable_4      (enable_4),
        .up            (up_pulse),
        .down          (down_pulse),
        .max_days_ones (max_days_ones),
        .max_days_tens (max_days_tens),
        .day_ones      (day_ones),
        .day_tens      (day_tens),
        .tick_day      (tick_day)
    );

    counter_month u_counter_month (
        .clk_50Mhz    (clk_50Mhz),
        .rst          (rst),
        .tick_day     (tick_day),
        .enable_5     (enable_5),
        .mode         (mode),
        .up           (up_pulse),
        .down         (down_pulse),
        .month_ones   (month_ones),
        .month_tens   (month_tens),
        .tick_month   (tick_month)
    );

    counter_year u_counter_year (
        .clk_50Mhz      (clk_50Mhz),
        .rst            (rst),
        .tick_month     (tick_month),
        .enable_6       (enable_6),
        .up             (up_pulse),
        .down           (down_pulse),
        .mode           (mode),
        .year_ones      (year_ones),
        .year_tens      (year_tens),
        .year_hundreds  (year_hundreds),
        .year_thousands (year_thousands)
    );

    display u_display (
        .sw_dis         (sw_dis),
        .blink          (blink),
        .enable_1       (enable_1),
        .enable_2       (enable_2),
        .enable_3       (enable_3),
        .enable_4       (enable_4),
        .enable_5       (enable_5),
        .enable_6       (enable_6),
        .sec_ones       (sec_ones),
        .sec_tens       (sec_tens),
        .min_ones       (min_ones),
        .min_tens       (min_tens),
        .hour_ones      (hour_ones),
        .hour_tens      (hour_tens),
        .day_ones       (day_ones),
        .day_tens       (day_tens),
        .month_ones     (month_ones),
        .month_tens     (month_tens),
        .year_ones      (year_ones),
        .year_tens      (year_tens),
        .year_hundreds  (year_hundreds),
        .year_thousands (year_thousands),
        .hex7           (hex7),
        .hex6           (hex6),
        .hex5           (hex5),
        .hex4           (hex4),
        .hex3           (hex3),
        .hex2           (hex2),
        .hex1           (hex1),
        .hex0           (hex0)
    );

endmodule