module top_checkered (
    input  wire clk_25mhz,
    input  wire [6:0] btn,
    output wire oled_csn,
    output wire oled_clk,
    output wire oled_mosi,
    output wire oled_dc,
    output wire oled_resn
);
    //                  checkered      red   green  blue     red    green blue
    wire [15:0] color = x[4] ^ y[4] ? {5'd0, 6'd63, 5'd0} : {5'd31, 6'd0, 5'd0};
    wire [7:0] x;
    wire [7:0] y;

    lcd_video #(
        .c_clk_mhz(25),
        .c_init_file("st7789_init.mem"),
        .c_init_size(36)
    ) lcd_video_inst (
        .clk(clk_25mhz),
        .reset(~btn[0]),
        .x(x),
        .y(y),
        .color(color),
        .oled_csn(oled_csn),
        .oled_clk(oled_clk),
        .oled_mosi(oled_mosi),
        .oled_dc(oled_dc),
        .oled_resn(oled_resn)
    );

endmodule