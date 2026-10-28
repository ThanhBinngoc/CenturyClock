`timescale 1ns / 1ps

module tb_century_clock;

    parameter SIM_CLK_FREQ   = 4;
    parameter SIM_BLINK_FREQ = 1;

    reg        clk_50Mhz;
    reg        rst;
    reg        mode;
    reg  [1:0] se;
    reg        btn_up;
    reg        btn_down;
    reg        sw_dis;

    wire [6:0] hex7, hex6, hex5, hex4, hex3, hex2, hex1, hex0;
    wire [3:0] sec_ones, sec_tens;
    wire [3:0] min_ones, min_tens;
    wire [3:0] hour_ones, hour_tens;
    wire [3:0] day_ones, day_tens;
    wire [3:0] month_ones, month_tens;
    wire [3:0] year_ones, year_tens, year_hundreds, year_thousands;
    wire       is_leap_year;

    century_clock #(
        .CLK_FREQ(SIM_CLK_FREQ),
        .BLINK_FREQ(SIM_BLINK_FREQ)
    ) dut (
        .clk_50Mhz       (clk_50Mhz),
        .rst             (rst),
        .mode            (mode),
        .se              (se),
        .btn_up          (btn_up),
        .btn_down        (btn_down),
        .sw_dis          (sw_dis),
        .hex7            (hex7),
        .hex6            (hex6),
        .hex5            (hex5),
        .hex4            (hex4),
        .hex3            (hex3),
        .hex2            (hex2),
        .hex1            (hex1),
        .hex0            (hex0),
        .sec_ones        (sec_ones),
        .sec_tens        (sec_tens),
        .min_ones        (min_ones),
        .min_tens        (min_tens),
        .hour_ones       (hour_ones),
        .hour_tens       (hour_tens),
        .day_ones        (day_ones),
        .day_tens        (day_tens),
        .month_ones      (month_ones),
        .month_tens      (month_tens),
        .year_ones       (year_ones),
        .year_tens       (year_tens),
        .year_hundreds   (year_hundreds),
        .year_thousands  (year_thousands),
        .is_leap_year    (is_leap_year)
    );

    initial clk_50Mhz = 0;
    always #10 clk_50Mhz = ~clk_50Mhz;

    task press_up;
        input integer count;
        integer i;
        begin
            for (i = 0; i < count; i = i + 1) begin
                @(posedge clk_50Mhz);
                btn_up = 1;
                @(posedge clk_50Mhz);
                @(posedge clk_50Mhz);
                btn_up = 0;
                @(posedge clk_50Mhz);
                @(posedge clk_50Mhz);
            end
        end
    endtask

    task press_down;
        input integer count;
        integer i;
        begin
            for (i = 0; i < count; i = i + 1) begin
                @(posedge clk_50Mhz);
                btn_down = 1;
                @(posedge clk_50Mhz);
                @(posedge clk_50Mhz);
                btn_down = 0;
                @(posedge clk_50Mhz);
                @(posedge clk_50Mhz);
            end
        end
    endtask

    task set_time_date;
        input integer target_h;
        input integer target_m;
        input integer target_s;
        input integer target_d;
        input integer target_mon;
        input integer target_y;
        integer cur_h, cur_m, cur_s, cur_d, cur_mon, cur_y;
        begin
            mode = 1; 
            @(posedge clk_50Mhz);

            sw_dis = 1;
            se = 2'b10;
            cur_y = year_thousands * 1000 + year_hundreds * 100 + year_tens * 10 + year_ones;
            if (target_y > cur_y) press_up(target_y - cur_y);
            else if (target_y < cur_y) press_down(cur_y - target_y);

            sw_dis = 1;
            se = 2'b01;
            cur_mon = month_tens * 10 + month_ones;
            if (target_mon > cur_mon) press_up(target_mon - cur_mon);
            else if (target_mon < cur_mon) press_down(cur_mon - target_mon);

            sw_dis = 1;
            se = 2'b00;
            cur_d = day_tens * 10 + day_ones;
            if (target_d > cur_d) press_up(target_d - cur_d);
            else if (target_d < cur_d) press_down(cur_d - target_d);

            sw_dis = 0;
            se = 2'b00;
            cur_h = hour_tens * 10 + hour_ones;
            if (target_h > cur_h) press_up(target_h - cur_h);
            else if (target_h < cur_h) press_down(cur_h - target_h);

            sw_dis = 0;
            se = 2'b01;
            cur_m = min_tens * 10 + min_ones;
            if (target_m > cur_m) press_up(target_m - cur_m);
            else if (target_m < cur_m) press_down(cur_m - target_m);

            sw_dis = 0;
            se = 2'b10;
            cur_s = sec_tens * 10 + sec_ones;
            if (target_s > cur_s) press_up(target_s - cur_s);
            else if (target_s < cur_s) press_down(cur_s - target_s);

            @(posedge clk_50Mhz);
        end
    endtask

    task advance_seconds;
        input integer num_seconds;
        integer s;
        begin
            for (s = 0; s < num_seconds; s = s + 1) begin
                while (dut.u_clk_gen.tick_1hz) @(posedge clk_50Mhz);
                while (!dut.u_clk_gen.tick_1hz) @(posedge clk_50Mhz);
                @(posedge clk_50Mhz);
                #1;
            end
        end
    endtask

    task print_status;
        input [127:0] msg;
        begin
            $display("[TIME: %0t ns] %0s | %0d%0d:%0d%0d:%0d%0d  %0d%0d/%0d%0d/%0d%0d%0d%0d | LeapYear=%0b",
                $time, msg,
                hour_tens, hour_ones, min_tens, min_ones, sec_tens, sec_ones,
                day_tens, day_ones, month_tens, month_ones,
                year_thousands, year_hundreds, year_tens, year_ones,
                is_leap_year
            );
        end
    endtask

    integer pass_count = 0;
    integer fail_count = 0;

    task check_date_time;
        input integer exp_h, exp_m, exp_s, exp_d, exp_mon, exp_y;
        input exp_leap;
        integer cur_h, cur_m, cur_s, cur_d, cur_mon, cur_y;
        begin
            cur_h   = hour_tens * 10 + hour_ones;
            cur_m   = min_tens * 10 + min_ones;
            cur_s   = sec_tens * 10 + sec_ones;
            cur_d   = day_tens * 10 + day_ones;
            cur_mon = month_tens * 10 + month_ones;
            cur_y   = year_thousands * 1000 + year_hundreds * 100 + year_tens * 10 + year_ones;

            if (cur_h == exp_h && cur_m == exp_m && cur_s == exp_s &&
                cur_d == exp_d && cur_mon == exp_mon && cur_y == exp_y &&
                is_leap_year == exp_leap) begin
                $display("   [PASS] Thoi gian dung: %0d%0d:%0d%0d:%0d%0d  %0d%0d/%0d%0d/%0d%0d%0d%0d (Leap=%0b)",
                    hour_tens, hour_ones, min_tens, min_ones, sec_tens, sec_ones,
                    day_tens, day_ones, month_tens, month_ones,
                    year_thousands, year_hundreds, year_tens, year_ones, is_leap_year);
                pass_count = pass_count + 1;
            end
            else begin
                $display("   [FAIL] KY VONG: %0d:%0d:%0d %0d/%0d/%0d (Leap=%0b) | THUC TE: %0d%0d:%0d%0d:%0d%0d %0d%0d/%0d%0d/%0d%0d%0d%0d (Leap=%0b)",
                    exp_h, exp_m, exp_s, exp_d, exp_mon, exp_y, exp_leap,
                    hour_tens, hour_ones, min_tens, min_ones, sec_tens, sec_ones,
                    day_tens, day_ones, month_tens, month_ones,
                    year_thousands, year_hundreds, year_tens, year_ones, is_leap_year);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_century_clock);

        $display("================================================================================");
        $display("          BAT DAU KIEM TRA TOAN DIEN DONG HO THE KY (CENTURY CLOCK)             ");
        $display("================================================================================");

        rst      = 0;
        mode     = 0;
        se       = 2'b00;
        btn_up   = 0;
        btn_down = 0;
        sw_dis   = 0;

        #100;
        rst = 1;
        #40;

        print_status("1. Khoi tao sau Reset");
        check_date_time(0, 0, 0, 1, 1, 2024, 1'b1); 

        // --- TEST CASE 1.1: Suon cua GIAY trong PROG mode ---
        $display("\n--- TEST CASE 1.1: Suon cua GIAY trong PROG mode ---");
        set_time_date(0, 0, 59, 1, 1, 2024);
        mode   = 1;
        sw_dis = 0;
        se     = 2'b10; 
        press_up(1);
        $display("-> Tang giay tu 59 qua 00 (Phut/Gio phai giu nguyen 00:00:00):");
        check_date_time(0, 0, 0, 1, 1, 2024, 1'b1);

        press_down(1);
        $display("-> Giam giay tu 00 lui ve 59 (Phut/Gio phai giu nguyen 00:00:59):");
        check_date_time(0, 0, 59, 1, 1, 2024, 1'b1);


        // --- TEST CASE 1.2: Suon cua PHUT trong PROG mode ---
        $display("\n--- TEST CASE 1.2: Suon cua PHUT trong PROG mode ---");
        set_time_date(0, 59, 0, 1, 1, 2024);
        mode   = 1;
        sw_dis = 0;
        se     = 2'b01; 
        press_up(1);
        $display("-> Tang phut tu 59 qua 00 (Gio/Giay phai giu nguyen 00:00:00):");
        check_date_time(0, 0, 0, 1, 1, 2024, 1'b1);

        press_down(1);
        $display("-> Giam phut tu 00 lui ve 59 (Gio/Giay phai giu nguyen 00:59:00):");
        check_date_time(0, 59, 0, 1, 1, 2024, 1'b1);


        // --- TEST CASE 1.3: Suon cua GIO trong PROG mode ---
        $display("\n--- TEST CASE 1.3: Suon cua GIO trong PROG mode ---");
        set_time_date(23, 0, 0, 1, 1, 2024);
        mode   = 1;
        sw_dis = 0;
        se     = 2'b00; 
        press_up(1);
        $display("-> Tang gio tu 23 qua 00 (Ngay phai giu nguyen 01/01/2024):");
        check_date_time(0, 0, 0, 1, 1, 2024, 1'b1);

        press_down(1);
        $display("-> Giam gio tu 00 lui ve 23 (Ngay phai giu nguyen 01/01/2024):");
        check_date_time(23, 0, 0, 1, 1, 2024, 1'b1);


        $display("\n--- TEST CASE 1.4: Tu dong kep ngay (Auto-Clamp) khi doi thang trong PROG mode ---");
        set_time_date(0, 0, 0, 31, 1, 2024);
        mode   = 1;
        sw_dis = 1;
        se     = 2'b01; 
        press_up(1);
        $display("-> Nam nhuan 2024: 31/01 tang sang Thang 2 tu dong kep thanh 29/02/2024:");
        check_date_time(0, 0, 0, 29, 2, 2024, 1'b1);

        set_time_date(0, 0, 0, 31, 1, 2023);
        mode   = 1;
        sw_dis = 1;
        se     = 2'b01; 
        press_up(1);
        $display("-> Nam thuong 2023: 31/01 tang sang Thang 2 tu dong kep thanh 28/02/2023:");
        check_date_time(0, 0, 0, 28, 2, 2023, 1'b0);

        set_time_date(0, 0, 0, 31, 3, 2024);
        mode   = 1;
        sw_dis = 1;
        se     = 2'b01; 
        press_up(1);
        $display("-> 31/03 tang sang Thang 4 tu dong kep thanh 30/04/2024:");
        check_date_time(0, 0, 0, 30, 4, 2024, 1'b1);


        // --- TEST CASE 2.1: Chuyen giao PHUT trong RUN mode (00:00:59 -> 00:01:00) ---
        $display("\n--- TEST CASE 2.1: Chuyen giao PHUT trong RUN mode (00:00:59 -> 00:01:00) ---");
        set_time_date(0, 0, 59, 1, 1, 2024);
        mode   = 0; 
        sw_dis = 0;
        advance_seconds(1);
        print_status("Sau 1s: Chuyen sang 00:01:00");
        check_date_time(0, 1, 0, 1, 1, 2024, 1'b1);


        // --- TEST CASE 2.2: Chuyen giao GIO trong RUN mode (00:59:59 -> 01:00:00) ---
        $display("\n--- TEST CASE 2.2: Chuyen giao GIO trong RUN mode (00:59:59 -> 01:00:00) ---");
        set_time_date(0, 59, 59, 1, 1, 2024);
        mode   = 0; 
        sw_dis = 0;
        advance_seconds(1);
        print_status("Sau 1s: Chuyen sang 01:00:00");
        check_date_time(1, 0, 0, 1, 1, 2024, 1'b1);


        // --- TEST CASE 2.3: Chuyen giao NGAY trong RUN mode (24/08/2024 23:59:59 -> 25/08/2024 00:00:00) ---
        $display("\n--- TEST CASE 2.3: Chuyen giao NGAY trong RUN mode (24/08/2024 23:59:59 -> 25/08/2024 00:00:00) ---");
        set_time_date(23, 59, 59, 24, 8, 2024);
        mode   = 0; 
        sw_dis = 0;
        advance_seconds(1);
        print_status("Sau 1s: Chuyen sang ngay moi 25/08/2024 00:00:00");
        check_date_time(0, 0, 0, 25, 8, 2024, 1'b1);


        // --- TEST CASE 2.4: Chuyen giao CUOI NAM trong RUN mode (31/12/2024 23:59:59 -> 01/01/2025 00:00:00) ---
        $display("\n--- TEST CASE 2.4: Chuyen giao CUOI NAM trong RUN mode (31/12/2024 -> 01/01/2025) ---");
        set_time_date(23, 59, 59, 31, 12, 2024);
        mode   = 0; 
        sw_dis = 0;
        advance_seconds(1);
        print_status("Sau 1s: Chuyen sang nam moi 01/01/2025 00:00:00");
        check_date_time(0, 0, 0, 1, 1, 2025, 1'b0);


        // --- TEST CASE 2.5: Kiem tra logic NAM NHUAN 2024 (28/02 -> 29/02 -> 01/03) ---
        $display("\n--- TEST CASE 2.5: Nam nhuan 2024 (28/02 -> 29/02 -> 01/03) ---");
        set_time_date(23, 59, 59, 28, 2, 2024);
        mode   = 0;
        sw_dis = 0;
        advance_seconds(1);
        print_status("Sau 1s: Nam nhuan 2024 nhay sang 29/02/2024");
        check_date_time(0, 0, 0, 29, 2, 2024, 1'b1);

        set_time_date(23, 59, 59, 29, 2, 2024);
        mode   = 0;
        sw_dis = 0;
        advance_seconds(1);
        print_status("Sau 1s: Het 29/02 nam nhuan chuyen sang 01/03/2024");
        check_date_time(0, 0, 0, 1, 3, 2024, 1'b1);


        // --- TEST CASE 2.6: Kiem tra logic NAM KHONG NHUAN 2023 (28/02/2023 -> 01/03/2023) ---
        $display("\n--- TEST CASE 2.6: Nam khong nhuan 2023 (28/02/2023 -> 01/03/2023) ---");
        set_time_date(23, 59, 59, 28, 2, 2023);
        mode   = 0;
        sw_dis = 0;
        advance_seconds(1);
        print_status("Sau 1s: Nam thuong 2023 tu 28/02 nhay thang sang 01/03/2023");
        check_date_time(0, 0, 0, 1, 3, 2023, 1'b0);


        // --- TEST CASE 2.7: Kiem tra NAM THE KY KHONG NHUAN 2100 (28/02/2100 -> 01/03/2100) ---
        $display("\n--- TEST CASE 2.7: Nam the ky KHONG NHUAN 2100 (28/02/2100 -> 01/03/2100) ---");
        set_time_date(23, 59, 59, 28, 2, 2100);
        mode   = 0;
        sw_dis = 0;
        advance_seconds(1);
        print_status("Sau 1s: Nam 2100 (khong nhuan the ky) tu 28/02 nhay thang sang 01/03/2100");
        check_date_time(0, 0, 0, 1, 3, 2100, 1'b0);


        // KIEM TRA HIEN THI LED 7 DOAN & MUX
        $display("\n--- TEST CASE 3: Kiem tra MUX Display (sw_dis) ---");
        mode   = 0;
        sw_dis = 0; 
        #20;
        $display("HEX display Mode Gio: hex7-6 (Hour), hex5-4 (Min), hex3-2 (Sec), hex1-0 (Blank)");
        $display("   HEX7=%b, HEX6=%b, HEX5=%b, HEX4=%b, HEX3=%b, HEX2=%b, HEX1=%b, HEX0=%b", 
                 hex7, hex6, hex5, hex4, hex3, hex2, hex1, hex0);

        sw_dis = 1; 
        #20;
        $display("HEX display Mode Ngay: hex7-6 (Day), hex5-4 (Month), hex3-0 (Year)");
        $display("   HEX7=%b, HEX6=%b, HEX5=%b, HEX4=%b, HEX3=%b, HEX2=%b, HEX1=%b, HEX0=%b",
                 hex7, hex6, hex5, hex4, hex3, hex2, hex1, hex0);

        $display("\n================================================================================");
        $display("                      KET QUA KIEM TRA HE THONG                                 ");
        $display("   SO TEST CASES DAT : %0d                                                      ", pass_count);
        $display("   SO TEST CASES LOI : %0d                                                      ", fail_count);
        if (fail_count == 0) begin
            $display("   >>> TAT CA CAC TESTBENCH DA VUOT QUA THANH CONG (100%% PASS)! <<<            ");
        end else begin
            $display("   >>> CO TESTBENCH BI THAT BAI! <<<                                            ");
        end
        $display("================================================================================");

        $finish;
    end

endmodule