module test (
    SPI_if vif
);
  //Virtual interface se refiere a un concepto en systemverilog, en OOP pasa un apuntador a la interfaz. Handle.
  byte datos[$];  //para almacenar los datos generao
  task automatic pulso_start();
    @(vif.cb);
    vif.cb.start_i <= 1;
    @(vif.cb);
    vif.cb.start_i <= 0;
    repeat (250) @(vif.cb);
  endtask : pulso_start
  initial begin
    $display("Inicio.");

    fork

      begin
        reset();
        normal();
        aleatoria();
        $finish;
      end

      begin
        check_db_tick();
      end

      begin
        // read();
      end

      begin
        suma();
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


    for (int i = 0; i < 5; i++) begin

      din_r = $urandom_range(0, 4);
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
      wait (vif.cb.sclk_o != 1);  //Esperamos a que el dividor del reloj, sea diferente de 1
      @(vif.cb iff (vif.cb.sclk_o == 1));  // ahora sincronizamos
      wait (vif.cb.sclk_o != 0);  // esperamos a que el divisor sea diferente de 0
      @(vif.cb iff (vif.cb.sclk_o == 0));  //sincronizados
      vif.miso_i = data[i];  //toma el valor de 6 y decrementa
    end

  endtask : read

  task automatic suma();

    logic [7:0] sp = 0;  //valor inicial
    logic [7:0] sn;  // valor nuevo
    logic [7:0] ed;  //enviar la suma 
    int index = 0;

    forever begin
      if (index < datos.size()) begin  // datos.size es de tamaño 2
        sn = datos[index];
        index++;
      end else begin
        $display("[READ] Sin datos en cola");
      end

      ed = sp + sn;
      $display("[SUMA] %4t: Dato actual = %0d, Dato anterior = %0d, Dato enviado = %0d", $realtime,
               sn, sp, ed);
      sp = sn;

      for (int i = 0; i <= 7; i++) begin  // 0-7
        $display("i %d, bit[%d] = %b", i, i, ed[i]);
      end


      wait (vif.start_i != 1);  // espera a que el start sea diferente de 1
      @(vif.cb iff (vif.start_i == 1)); // Esperamos un ciclo de subida de cb y que el start este n 1, para sincronizar
      vif.miso_i = ed[7];  // toma el bits más significativo
      for (int i = 6; i >= 0; i--) begin  //Y vamos decrementando hasta 0
        wait (vif.cb.sclk_o != 1);  //Esperamos a que el dividor del reloj, sea diferente de 1
        @(vif.cb iff (vif.cb.sclk_o == 1));  // ahora sincronizamos
        wait (vif.cb.sclk_o != 0);  // esperamos a que el divisor sea diferente de 0
        @(vif.cb iff (vif.cb.sclk_o == 0));  //sincronizados
        vif.miso_i = ed[i];  //toma el valor de 6 y decrementa
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




endmodule
