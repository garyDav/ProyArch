$(document).ready(function () {
   
/**
 * Cuando el valor del input date #fecha_inicio o del input number #duración cambie de valor
 * se suman X dias a la fecha de inicio para formar la fecha final
 * */
$( "#obr_fecha_ini,#obr_plazo_ejec" ).change(function() {
    
    if( $("#obr_fecha_ini").val().length > 0 )
    {
        var f1 = $("#obr_fecha_ini").val();
        var arr_f1 = f1.split("-");
        //convierte a fecha
        var fecha1 = new Date( arr_f1[0]+"/"+arr_f1[1]+"/"+arr_f1[2] );
        //
        if( $("#obr_plazo_ejec").val().length > 0)
        {
            x = $("#obr_plazo_ejec").val();
        }
        else
        {
            $("#obr_plazo_ejec").val("5");
            x = $("#obr_plazo_ejec").val();
        }
        //se suman X dias  a fecha final 
        var fecha2 = new Date(fecha1.getTime() + (x * 24 * 3600 * 1000));    
        //fecha en pantalla 
        $("#obr_fecha_conc").val( fecha2.yyyymmdd() );            
    }
});

   /*
   * Funion que convierte un string a fecha DATE
   * @returns {String}
   */
   Date.prototype.yyyymmdd = function() {                                         
        var yyyy = this.getFullYear().toString();                                    
        var mm = (this.getMonth()+1).toString(); // getMonth() is zero-based         
        var dd  = this.getDate().toString();             
                            
        return yyyy + '-' + (mm[1]?mm:"0"+mm[0]) + '-' + (dd[1]?dd:"0"+dd[0]);
   };  
   
});