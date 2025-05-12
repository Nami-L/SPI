//Conexión de la interfaz con el DUT

`timescale 1ns / 100ps

module tb;

  //Clock signal
  parameter time ClkPeriod = 20ns;
  logic clk_i = 0;

  always #(ClkPeriod / 2) clk_i = ~clk_i;

  //Definir la interfaz
  SPI_if vif (clk_i);

  //Test

  test top_test (vif);

  //Instanciar con la interfaz


  //DUt
  SPI dut (
      .clk_i(vif.clk_i),
      .reset_i(vif.reset_i),
      .din_i(vif.din_i),
      .dvsr_i(vif.dvsr_i),
      .start_i(vif.start_i),
      .cpol_i(vif.cpol_i),
      .cpha_i(vif.cpha_i),
      .dout_o(vif.dout_o),
      .spi_done_tick_o(vif.spi_done_tick_o),
      .ready_o(vif.ready_o),
      .sclk_o(vif.sclk_o),
      .miso_i(vif.miso_i),
      .mosi_o(vif.mosi_o)
  );

  initial begin

  end


endmodule
