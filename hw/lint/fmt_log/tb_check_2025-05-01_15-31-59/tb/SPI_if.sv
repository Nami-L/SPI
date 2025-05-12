interface SPI_if (  //todo en minuscula
    input logic clk_i
);
  //Entradas
  logic reset_i;
  logic [7:0] din_i;
  logic [15:0] dvsr_i;
  logic start_i;
  logic cpol_i;
  logic cpha_i;
  //Salidas    
  logic [7:0] dout_o;
  logic spi_done_tick_o;
  logic ready_o;  //Bandera Para transmitir
  logic sclk_o;  //Reloj para la transmision de datos
  logic miso_i;  //
  logic mosi_o;  //Salida de datos.

  clocking cb @(posedge clk_i);  //clocking block agrupa señales de entrada y salida que están sincronizadas con un reloj específico
    default input #1ns output #10ns;  // output debe ser la mitad del Periodo para al momento de mandar a escribir con el CB haga el cambio en un flanco de bajada.

    output reset_i;
    output din_i;
    output dvsr_i;
    output start_i;
    output cpol_i;
    output cpha_i;
    /////
    input dout_o;
    input spi_done_tick_o;
    input ready_o;
    input sclk_o;
    output miso_i;
    input mosi_o;
  endclocking

  //modport :se utilizan para definir las direcciones de las señales

  //
  modport dvr(clocking cb, output reset_i, output din_i, output dvsr_i, output start_i, output cpol_i, output cpha_i, output miso_i);

endinterface : SPI_if
;
