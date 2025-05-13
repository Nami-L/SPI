module test (
    SPI_if vif
);
  //Virtual interface se refiere a un concepto en systemverilog, en OOP pasa un apuntador a la interfaz. Handle.
  byte datos[$];  //para almacenar los datos generados de entrada
  bit [7:0] salida_MOSI[$];  // almacenar la palabra generada por el MOSI
  bit [7:0] luis[$];


  task automatic pulso_start();
    @(vif.cb);
    vif.cb.start_i <= 1;
    @(vif.cb);
    vif.cb.start_i <= 0;
    repeat (250) @(vif.cb);
  endtask : pulso_start

  initial begin
    $display("Inicio");

    fork

      begin
        reset();  // Tarea de reset, para iniciar todos los valores en 0
        normal(); // Generar datos manualmente, simplemente para verificar el funcionamiento del SPI
        aleatoria();  // Generar datos aleatoriamente, utilizando herramientas de sv
        compare(); // Comparar los datos generados de entrada,con los datos de salida del MOSI, para comprobar que se esta enviando los datos correctos.
        $finish;
      end

      begin
        check_db_tick();  // Tarea para contar, las veces que se ha realizado una escritura
      end

      begin
        // read(); // Tarea para leer los datos enviador desde el MISO(esclavo) al MOSI (maestro)
      end

      begin
        suma(); // Tarea para leer los dos datos anteriores en el MISO(esclavo) y mostrarlos en el MOSI(maestro)
      end

      begin
        check_mosi(); // Tarea para comprobar que los datos enviados de entrada, son los mismo que salen del MOSI(mestro). MONITOREO

      end

    join



  end

  task automatic reset();

    vif.reset_i = 'b1;
    vif.din_i   = 'b0;
    vif.dvsr_i  = 'd9;
    vif.start_i = 'b0;
    vif.cpol_i  = 'b0;
    vif.cpha_i  = 'b0;
    vif.miso_i  = 'b0;
    repeat (2) @(vif.cb);
    vif.cb.reset_i <= 'b0;
    repeat (4) @(vif.cb);  // espera 4 flancos de subida y ejecuta lo de abajo
  endtask : reset


  task automatic normal();
    @(vif.cb);  // Espera un ciclo de reloj para sincronizar.

    vif.cb.din_i <= 'h00;
    datos.push_back('h00);  // Guardar en la cola
    //vif.cb.dvsr_i <= 'b0; // 'deteccion de cantidad de bits
    vif.cb.start_i <= 0;
    vif.cb.cpol_i  <= 0;
    vif.cb.cpha_i  <= 0;

    pulso_start();  // Tarea definida al inicio
    ///////////////////////////////////////////////////////////////
    vif.cb.din_i <= 'h01;
    datos.push_back('h01);  // Guardar en la cola
    vif.cb.start_i <= 0;
    vif.cb.cpol_i  <= 0;
    vif.cb.cpha_i  <= 0;

    pulso_start();  // Tarea definida al inicio
    /////////////////////////////////////////////////////
    vif.cb.din_i <= 'h02;
    datos.push_back('h02);  // Guardar en la cola

    vif.cb.start_i <= 0;
    vif.cb.cpol_i  <= 0;
    vif.cb.cpha_i  <= 0;

    pulso_start();  // Tarea definida al inicio
    /////////////////////////////////////////////////////////////////////
    vif.cb.din_i <= 'h03;
    datos.push_back('h03);  // Guardar en la cola

    vif.cb.start_i <= 0;
    vif.cb.cpol_i  <= 0;
    vif.cb.cpha_i  <= 0;

    pulso_start();  // Tarea definida al inicio
    ///////////////////////////////////////////////////////////////////////
    vif.cb.din_i <= 'h04;
    datos.push_back('h04);  // Guardar en la cola

    vif.cb.start_i <= 0;
    vif.cb.cpol_i  <= 0;
    vif.cb.cpha_i  <= 0;

    pulso_start();  // Tarea definida al inicio
    ///////////////////////////////////////////////////////////////////////
    vif.cb.din_i <= 'h05;
    datos.push_back('h05);  // Guardar en la cola

    vif.cb.start_i <= 0;
    vif.cb.cpol_i  <= 0;
    vif.cb.cpha_i  <= 0;
    pulso_start();
    //pulso_start();  // Tarea definida al inicio
    //  pulso_start();  // Tarea definida al inicio
    //  pulso_start();  // Tarea definida al inicio
    //  pulso_start();  // Tarea definida al inicio
    //  pulso_start();  // Tarea definida al inicio

  endtask : normal


  task automatic aleatoria();
    int din_r;


    for (int i = 0; i < 2; i++) begin

      din_r = $urandom_range(0, 5);
      $display("[WRITE] %4t: iter = %3d, din_r[%d] = %10d", $realtime, i + 1, i + 1, din_r);
      @(vif.cb);  // Espera un ciclo de reloj para sincronizar.

      vif.cb.din_i <= din_r;
      datos.push_back(din_r);  // Guardar en la cola
      vif.cb.start_i <= 0;
      vif.cb.cpol_i  <= 0;
      vif.cb.cpha_i  <= 0;
      //repeat(250)@(vif.cb)

      //      @(vif.cb);  //espera 1 flanco de bajada y ejecuta lo de abajo
      //      vif.cb.start_i <= 1;
      //      @(vif.cb);  // 
      //      vif.cb.start_i <= 0;
      //      repeat (250) @(vif.cb);  // mejor utilizar la bandera de done_tick
      pulso_start();
    end
  endtask : aleatoria

  task automatic read();
    int data = $urandom_range(0, 255);
    $display("[READ] %4t: dato = %8b", $realtime, data[7:0]);

    for (int i = 0; i <= 7; i++) begin  // 0-7
      $display("i %d, bit[%d] = %b", i, i, data[i]);
    end
    //waits risign edge of start
    wait (vif.start_i != 1);  // espera a que el start sea diferente de 1
    @(vif.cb iff (vif.start_i == 1)); // Esperamos un ciclo de subida de cb y que el start este n 1, para sincronizar
    vif.miso_i = data[7];  // toma el bits más significativo
    for (int i = 6; i >= 0; i--) begin  //Y vamos decrementando hasta 0
      wait (vif.sclk_o != 0);  // esperamos a que el divisor sea diferente de 0
      @(vif.cb iff (vif.sclk_o == 0));  //sincronizados
      vif.miso_i = data[i];  //toma el valor de 6 y decrementa
    end

  endtask : read

  task automatic suma();

    logic [7:0] valor_inicial = 0;  //valor inicial
    logic [7:0] valor_actual;  // valor nuevo
    logic [7:0] valor_sumado;  //enviar la suma 
    int         index = 0;

    forever begin
      if (index < datos.size()) begin  // datos.size es de tamaño 2
        valor_actual = datos[index];  // estan almacenados todos los datos de entrada
        index++;
      end else begin
        $display("[READ] Sin datos en cola");
      end

      valor_sumado = valor_inicial + valor_actual;
      $display("[SUMA] %4t: Dato actual = %0d, Dato anterior = %0d, Dato enviado = %0d", $realtime,
               valor_actual, valor_inicial, valor_sumado);
      valor_inicial = valor_actual;

      for (int i = 0; i <= 7; i++) begin  // 0-7
        $display("i %d, bit[%d] = %b", i, i, valor_sumado[i]);
      end

      wait (vif.start_i != 1);  // espera a que el start sea diferente de 1
      @(vif.cb iff (vif.start_i == 1)); // Esperamos un ciclo de subida de cb y que el start este n 1, para sincronizar
      vif.miso_i = valor_sumado[7];  // toma el bit más significativo
      for (int i = 6; i >= 0; i--) begin  //Y vamos decrementando hasta 0
        wait (vif.sclk_o != 0);  // esperamos a que el divisor sea diferente de 0
        @(vif.cb iff (vif.sclk_o == 0));  //sincronizados
        vif.miso_i = valor_sumado[i];  //toma el valor de 6 y decrementa
      end

      if (index >= datos.size()) begin
        $display("[INFO] Todos los datos han sido procesados.");
        break;
      end
    end

  endtask : suma


  task automatic check_db_tick();
    int tick_counter = 0;
    forever begin
      fork
        begin : wd_timer_fork
          fork : tick_done_wd_timer
            begin
              wait (vif.cb.spi_done_tick_o != 1);
              @(vif.cb iff (vif.cb.spi_done_tick_o == 1));  // esperamos un flanco de subida donde tick_o 1
              tick_counter++;
              $display("[PULSE] %4t: posedge db_tick_o, num_pulse %4d", $realtime, tick_counter);
            end

            begin
              repeat (500) @vif.cb;
              $display("[PULSE] %4t: Timed out!", $realtime);
              $display("[PULSE] %4t: tick_counter: %4d,", $realtime, tick_counter);
              $finish;
            end
          join_any : tick_done_wd_timer
          disable fork;  // desactiva el padre wd_timer_fork, siempre es necesario que este dentro de otro fork
        end : wd_timer_fork

      join

    end

  endtask : check_db_tick

  task automatic check_mosi();

    bit [7:0] palabra = 0;

    forever begin
      //En modo 0, el dato se transmite en el flanco de bajada y se captura en el flanco de subida del reloj.
      //Como esta en la configuracion CPLO =0 CPHA=0, los datos se envian en el flanco ascendente y los puedo leer en el flanco descendente.
      //Iniciar la transmisión 
      wait (vif.start_i != 1);  // espera a que el start sea diferente de 1
      @(vif.cb iff (vif.start_i == 1)); // Esperamos un ciclo de subida de cb y que el start este n 1, para sincronizar

      for (int i = 7; i >= 0; i--) begin  //Y vamos decrementando hasta 0
        wait (vif.sclk_o != 1);  // esperamos a que el divisor sea 0 porque el mosi cambia en bajo, 
        @(vif.cb iff (vif.sclk_o == 1));  // Ahora que esperamos que el divisor sea igual 1, donde el valor ya esta capturado y es estable
        palabra[i] = vif.mosi_o;  // se almacenara cada bit en un queue , para guardar todos los bits
      end

      salida_MOSI.push_back(palabra);  // Terminando el For, me arroja los 8 bits de una palabra.
      $display("[CHECK_MOSI]Palabra recibida: %b", palabra);

    end

  endtask : check_mosi


  task automatic compare();
    // foreach(salida_MOSI[i]) begin
    for (int i = 0; i < salida_MOSI.size(); i++) begin
      if (salida_MOSI[i] == datos[i]) begin
        $display("[COMPARE] Son iguales los datos del MISO: %b y de entrada: %b  en el indice %d",
                 salida_MOSI[i], datos[i], i + 1);
        luis.push_back(salida_MOSI[i]);  // Copia el dato a luis
        $display("Dato agregado a luis: %b", salida_MOSI[i]);

      end
    end
  endtask : compare


endmodule
