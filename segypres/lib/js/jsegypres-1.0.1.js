$(function(){	

/**
 * Cuando el valor del input date #fecha_inicio o del input number #duración cambie de valor
 * se suman X dias a la fecha de inicio para formar la fecha final
 * */
$( "#fecha_inicio,#duracion" ).change(function() {
    
    if( $("#fecha_inicio").val().length > 0 )
    {
        var f1 = $("#fecha_inicio").val();
        var arr_f1 = f1.split("-");
        //convierte a fecha
        var fecha1 = new Date( arr_f1[0]+"/"+arr_f1[1]+"/"+arr_f1[2] );
        //
        if( $("#duracion").val().length > 0)
        {
            x = $("#duracion").val();
        }
        else
        {
            $("#duracion").val("5");
            x = $("#duracion").val();
        }
        //se suman X dias  a fecha final 
        var fecha2 = new Date(fecha1.getTime() + (x * 24 * 3600 * 1000));    
        //fecha en pantalla 
        $("#fecha_fin").val( fecha2.yyyymmdd() );            
    }
});



//http://blog.justin.kelly.org.au/simple-javascript-function-to-format-the-date-as-yyyy-mm-dd/
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
//http://jcesar.artelogico.com/2010/05/sumarrestar-fechas-con-javascript/


})//--> FIN JQUERY	