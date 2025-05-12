module test(
    SPI_if vif
);
//Virtual interface se refiere a un concepto en systemverilog, en OOP pasa un apuntador a la interfaz. Handle.
initial begin
  $display("Inicio.");

fork

    begin 
    reset();
    normal();
    //aleatoria();
   
 $finish;
    end
    
    begin
    
     //   check_db_tick();
    
    end 
    
//    begin 
    
//     read();
//    end

join 

 $display("Fin de la Simulacion.");
    $finish;
end

task automatic reset();

vif.reset_i='b1;
vif.din_i='b0;
vif.dvsr_i='d9;
vif.start_i='b0;
vif.cpol_i='b0;
vif.cpha_i='b0;
vif.miso_i = 'b0; 
repeat(2) @(vif.cb);
vif.cb.reset_i <= 'b0;
repeat(4)@(vif.cb); // espera 4 flancos de subida y ejecuta lo de abajo
endtask:reset


task automatic normal ();
@(vif.cb); // Espera un ciclo de reloj para sincronizar.

vif.cb.din_i <= 'haa;
//vif.cb.dvsr_i <= 'b0; // 'deteccion de cantidad de bits
vif.cb.start_i <= 0;
vif.cb.cpol_i <= 0;
vif.cb.cpha_i <= 0;

@(vif.cb); //espera 1 flanco de bajada y ejecuta lo de abajo
vif.cb.start_i <= 1;
@(vif.cb);// 
vif.cb.start_i <= 0;
repeat(250) @(vif.cb);

vif.cb.din_i <= 'h01;
vif.cb.start_i <= 0;
vif.cb.cpol_i <= 0;
vif.cb.cpha_i <= 0;

@(vif.cb); //espera 1 flanco de bajada y ejecuta lo de abajo
vif.cb.start_i <= 1;
@(vif.cb);// 
vif.cb.start_i <= 0;
repeat(250) @(vif.cb);
endtask: normal 

task automatic aleatoria();
int din_r, dvsr_r;


for (int i = 0; i< 4 ; i++ )begin

  din_r = $urandom_range(0,255);
  $display("[INFO] %4t: iter = %3d, din_r = %10d", $realtime, i, din_r);

  vif.din_i <= din_r;

//repeat(100)@(vif.cb)

@(vif.cb); //espera 1 flanco de bajada y ejecuta lo de abajo
vif.cb.start_i <= 1;
 @(vif.cb);// 
vif.cb.start_i <= 0;

repeat(250) @(vif.cb); // mejor utilizar la bandera de done_tick
end
endtask: aleatoria 

task automatic check_db_tick();
  int tick_counter = 0;
forever begin
    fork
       begin: wd_timer_fork
          fork: tick_done_wd_timer
            begin
            wait(vif.cb.spi_done_tick_o !=1);
            @(vif.cb iff (vif.cb.spi_done_tick_o ==1 )); // esperamos un flanco de subida donde tick_o 1
            tick_counter++;
            $display("[INFO] %4t: posedge db_tick_o, num_pulse %4d",$realtime, tick_counter);
            end
          
          begin
            repeat(500) @vif.cb ;
                  $display("[INFO] %4t: Timed out!", $realtime);
                  $display("[INFO] %4t: tick_counter: %4d,", $realtime,  tick_counter);
                  $finish;
            end
          join_any :tick_done_wd_timer
            disable fork; // desactiva el padre wd_timer_fork
       end:wd_timer_fork
    
    join

end

endtask: check_db_tick 

endmodule









