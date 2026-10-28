module controller (
    input  wire       clk_50Mhz,
    input  wire       rst,
    input  wire       mode,    
    input  wire       sw_dis,      
    input  wire [1:0] se,         
    input  wire       btn_up,      
    input  wire       btn_down,    
    input  wire       b_hz,       
    output reg        enable_1, 
    output reg        enable_2,   
    output reg        enable_3,   
    output reg        enable_4,  
    output reg        enable_5,    
    output reg        enable_6,    
    output wire       up_pulse,    
    output wire       down_pulse,  
    output wire       blink       
);

    always @(*) begin
        enable_1 = 1'b0;
        enable_2 = 1'b0;
        enable_3 = 1'b0;
        enable_4 = 1'b0;
        enable_5 = 1'b0;
        enable_6 = 1'b0;

        if (mode == 1'b1) begin 
            if (sw_dis == 1'b0) begin
                case (se)
                    2'b00: enable_3 = 1'b1; // O 1: Gio
                    2'b01: enable_2 = 1'b1; // O 2: Phut
                    2'b10: enable_1 = 1'b1; // O 3: Giay
                    default: ;
                endcase
            end
            else begin
                case (se)
                    2'b00: enable_4 = 1'b1; // O 1: Ngay
                    2'b01: enable_5 = 1'b1; // O 2: Thang
                    2'b10: enable_6 = 1'b1; // O 3: Nam
                    default: ;
                endcase
            end
        end
    end

    reg btn_up_d1, btn_up_d2;
    reg btn_down_d1, btn_down_d2;

    always @(posedge clk_50Mhz or negedge rst) begin
        if (!rst) begin
            btn_up_d1   <= 1'b0;
            btn_up_d2   <= 1'b0;
            btn_down_d1 <= 1'b0;
            btn_down_d2 <= 1'b0;
        end
        else begin
            btn_up_d1   <= btn_up;
            btn_up_d2   <= btn_up_d1;
            btn_down_d1 <= btn_down;
            btn_down_d2 <= btn_down_d1;
        end
    end

    assign up_pulse   = (mode == 1'b1) ? (btn_up_d1 & ~btn_up_d2) : 1'b0;
    assign down_pulse = (mode == 1'b1) ? (btn_down_d1 & ~btn_down_d2) : 1'b0;


    assign blink = (mode == 1'b1) ? b_hz : 1'b0;

endmodule