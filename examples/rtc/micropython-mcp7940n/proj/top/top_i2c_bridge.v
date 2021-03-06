`default_nettype none
module top_i2c_bridge
(
    input  wire clk_25mhz,
    input  wire [6:0] btn,
    output wire [7:0] led,
    //inout  wire shutdown,
    inout  wire gpdi_sda,
    inout  wire gpdi_scl,
    input  wire ftdi_txd,
    output wire ftdi_rxd,
    output wire wifi_en,
    input  wire wifi_txd,
    output wire wifi_rxd,
    inout  wire wifi_gpio17,
    inout  wire wifi_gpio16,
    output wire wifi_gpio0
);
    assign wifi_gpio0 = btn[0];
    assign wifi_en    = 1;
/*
  wire [3:0] clocks;
  ecp5pll
  #(
      .in_hz( 25*1000000),
    .out0_hz(  6*1000000), .out0_tol_hz(1000000)
  )
  ecp5pll_inst
  (
    .clk_i(clk_25mhz),
    .clk_o(clocks)
  );
    wire clk = clocks[0];
*/
    wire clk = clk_25mhz;

    // passthru to ESP32 micropython serial console
    assign wifi_rxd = ftdi_txd;
    assign ftdi_rxd = wifi_txd;

    // i2c bridge
    // slow clock enable pulse 5 MHz
    localparam bridge_clk_div = 3; // div = 1+2^n, 25/(1+2^2)=5 MHz
    reg [bridge_clk_div:0] bridge_cnt;
    always @(posedge clk) // 25 MHz
    begin
      if(bridge_cnt[bridge_clk_div])
        bridge_cnt <= 0;
      else
        bridge_cnt <= bridge_cnt + 1;
    end
    wire clk_bridge_en = bridge_cnt[bridge_clk_div];

    wire [1:0] i2c_sda_i = {gpdi_sda, wifi_gpio16};
    wire [1:0] i2c_sda_t;
    i2c_bridge i2c_sda_bridge_i
    (
      .clk(clk),
      .clk_en(clk_bridge_en),
      .i(i2c_sda_i),
      .t(i2c_sda_t)
    );
    assign gpdi_sda    = i2c_sda_t[1] ? 1'bz : 1'b0;
    assign wifi_gpio16 = i2c_sda_t[0] ? 1'bz : 1'b0;

    wire [1:0] i2c_scl_i = {gpdi_scl, wifi_gpio17};
    wire [1:0] i2c_scl_t;
    i2c_bridge i2c_scl_bridge_i
    (
      .clk(clk),
      .clk_en(clk_bridge_en),
      .i(i2c_scl_i),
      .t(i2c_scl_t)
    );
    assign gpdi_scl    = i2c_scl_t[1] ? 1'bz : 1'b0;
    assign wifi_gpio17 = i2c_scl_t[0] ? 1'bz : 1'b0;

    assign led[5:0] = 0;
    assign led[7:6] = {gpdi_sda,gpdi_scl};

endmodule
