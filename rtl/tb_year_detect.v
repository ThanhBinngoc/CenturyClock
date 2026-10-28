`timescale 1ns / 1ps

module tb_year_detect;

    // Tín hiệu kết nối với DUT
    reg  [3:0] month_ones;
    reg  [3:0] month_tens;
    reg  [3:0] year_ones;
    reg  [3:0] year_tens;
    reg  [3:0] year_hundreds;
    reg  [3:0] year_thousands;

    wire [3:0] max_days_ones;
    wire [3:0] max_days_tens;
    wire       is_leap_year;

    // Biến đếm kết quả
    integer pass_count = 0;
    integer fail_count = 0;

    // Khởi tạo DUT
    year_detect dut (
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

    // =========================================================================
    // TASK THỰC THI & SO SÁNH TEST CASE (Self-Checking Task)
    // =========================================================================
    task run_testcase(
        input [8*45:1] tc_name,     // Tên kịch bản test
        input integer  year_val,    // Năm (0 -> 9999)
        input integer  month_val,   // Tháng (1 -> 12)
        input [3:0]    exp_tens,    // Giá trị kỳ vọng max_days_tens
        input [3:0]    exp_ones,    // Giá trị kỳ vọng max_days_ones
        input          exp_leap     // Giá trị kỳ vọng is_leap_year
    );
        begin
            // Tách BCD cho Năm
            year_thousands = (year_val / 1000) % 10;
            year_hundreds  = (year_val / 100) % 10;
            year_tens      = (year_val / 10) % 10;
            year_ones      = year_val % 10;

            // Tách BCD cho Tháng
            month_tens     = (month_val / 10) % 10;
            month_ones     = month_val % 10;

            // Đợi 1ns cho mạch tổ hợp tính toán xong
            #1;

            // Đối soát kết quả với Golden Value
            if (is_leap_year === exp_leap &&
                max_days_tens === exp_tens &&
                max_days_ones === exp_ones) begin
                
                $display("[PASS] %-35s | Nam: %04d/Thang %02d | Out: %0d%0d ngay, Leap=%0b", 
                         tc_name, year_val, month_val, max_days_tens, max_days_ones, is_leap_year);
                pass_count = pass_count + 1;
            end 
            else begin
                $display("[FAIL] %-35s | Nam: %04d/Thang %02d | KY VONG: %0d%0d ngay, Leap=%0b | THUC TE: %0d%0d ngay, Leap=%0b", 
                         tc_name, year_val, month_val, exp_tens, exp_ones, exp_leap, max_days_tens, max_days_ones, is_leap_year);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // =========================================================================
    // KHỐI KỊCH BẢN THỰC THI (Kích hoạt các Test Case)
    // =========================================================================
    initial begin
        $display("=====================================================================================");
        $display("             BAT DAU THUC THI TAC VU KIEM THU CUD DINH (DIRECTED TEST)               ");
        $display("=====================================================================================");

        // --- NHÓM 1: KIỂM THỬ LOGIC NĂM NHUẬN (is_leap_year) ---
        $display("\n--- [NHOM 1] Kiem tra Logic Nam Nhuan ---");
        run_testcase("TC 1.1: Nam thuong (2023)",               2023, 1, 3, 1, 1'b0);
        run_testcase("TC 1.2: Nam nhuan thuong (2024)",          2024, 1, 3, 1, 1'b1);
        run_testcase("TC 1.3a: Nam the ky KHONG nhuan (1900)",    1900, 1, 3, 1, 1'b0);
        run_testcase("TC 1.3b: Nam the ky KHONG nhuan (2100)",    2100, 1, 3, 1, 1'b0);
        run_testcase("TC 1.4a: Nam the ky NHUAN (2000)",          2000, 1, 3, 1, 1'b1);
        run_testcase("TC 1.4b: Nam the ky NHUAN (2400)",          2400, 1, 3, 1, 1'b1);

        // --- NHÓM 2: KIỂM THỬ SỐ NGÀY TỐI ĐA TRONG THÁNG ---
        $display("\n--- [NHOM 2] Kiem tra Max Days cac Thang ---");
        run_testcase("TC 2.1: Thang 2 - Nam nhuan (2024)",       2024, 2, 2, 9, 1'b1);
        run_testcase("TC 2.2: Thang 2 - Nam thuong (2023)",      2023, 2, 2, 8, 1'b0);
        run_testcase("TC 2.3: Thang 2 - The ky khong nhuan(2100)", 2100, 2, 2, 8, 1'b0);
        run_testcase("TC 2.4: Thang 2 - The ky nhuan (2000)",     2000, 2, 2, 9, 1'b1);
        
        // Kiểm tra tập hợp các tháng 31 ngày (Tháng 1, 3, 5, 7, 8, 10, 12)
        run_testcase("TC 2.5a: Thang 1 (31 ngay)",               2024, 1,  3, 1, 1'b1);
        run_testcase("TC 2.5b: Thang 3 (31 ngay)",               2024, 3,  3, 1, 1'b1);
        run_testcase("TC 2.5c: Thang 5 (31 ngay)",               2024, 5,  3, 1, 1'b1);
        run_testcase("TC 2.5d: Thang 7 (31 ngay)",               2024, 7,  3, 1, 1'b1);
        run_testcase("TC 2.5e: Thang 8 (31 ngay)",               2024, 8,  3, 1, 1'b1);
        run_testcase("TC 2.5f: Thang 10 (31 ngay)",              2024, 10, 3, 1, 1'b1);
        run_testcase("TC 2.5g: Thang 12 (31 ngay)",              2024, 12, 3, 1, 1'b1);

        // Kiểm tra tập hợp các tháng 30 ngày (Tháng 4, 6, 9, 11)
        run_testcase("TC 2.6a: Thang 4 (30 ngay)",               2024, 4,  3, 0, 1'b1);
        run_testcase("TC 2.6b: Thang 6 (30 ngay)",               2024, 6,  3, 0, 1'b1);
        run_testcase("TC 2.6c: Thang 9 (30 ngay)",               2024, 9,  3, 0, 1'b1);
        run_testcase("TC 2.6d: Thang 11 (30 ngay)",              2024, 11, 3, 0, 1'b1);

        // --- NHÓM 3: KIỂM THỬ TRƯỜNG HỢP RANH GIỚI (CORNER CASES) ---
        $display("\n--- [NHOM 3] Kiem tra Ranh gio boundary ---");
        run_testcase("TC 3.1: Nam nho nhat (0000/02)",            0,    2, 2, 9, 1'b1);
        run_testcase("TC 3.2: Nam lon nhat (9999/02)",            9999, 2, 2, 8, 1'b0);

        // --- BÁO CÁO TỔNG KẾT ---
        $display("\n=====================================================================================");
        $display("                            KET QUA KIEM THU (SIGN-OFF)                              ");
        $display("   TONG SO TEST CASE : %0d", pass_count + fail_count);
        $display("   SO TEST CASE PASS : %0d", pass_count);
        $display("   SO TEST CASE FAIL : %0d", fail_count);
        if (fail_count == 0)
            $display("   >>> TAT CA CAC TESTCASE TRONG TESTPLAN DA DAT (100%% PASS)! <<<");
        else
            $display("   >>> CO LOI PHAT HIEN TRONG MODULE DUOC KIEM THU! <<<");
        $display("=====================================================================================");

        $finish;
    end

endmodule