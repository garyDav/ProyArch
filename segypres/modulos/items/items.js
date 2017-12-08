$(document).ready(function () {

    $('#pu,#rend').change(function() {   
        operacion();
    });
    
    $("#unidad").change(function() {
        operacion();
    });


    function operacion(){
        var unidad  = $("#unidad").val();
        var pu = IsNumeric($("#pu").val())? $("#pu").val() : 0;
        var rend = IsNumeric($("#rend").val())? $("#rend").val() : 0;
        var resultado=0;
        if( unidad === '%' ){
            resultado = (parseFloat(rend) * parseFloat(pu))/100;    
        }else{            
            resultado = parseFloat(rend) * parseFloat(pu);    
        }                        
        $("#total").val( xRound(resultado) );
    }

    function xRound( value ){
        return value = Math.round(value * 100) / 100;
    }
    
    
     function IsNumeric(input)
    {
        return (input - 0) == input && (''+input).replace(/^\s+|\s+$/g, "").length > 0;
    }
    
});

