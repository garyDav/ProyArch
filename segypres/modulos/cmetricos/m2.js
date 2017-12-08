$(document).ready(function () {
    
    $('#ancho,#altura').change(function() {         
        var ancho = IsNumeric($("#ancho").val())? $("#ancho").val() : 0;
        var alto = IsNumeric($("#altura").val())? $("#altura").val() : 0;
        var resultado = parseFloat(ancho) * parseFloat(alto);
        resultado = Math.round(resultado * 100) / 100;
        $("#parcial").val(resultado);
    });
   
    function IsNumeric(input)
    {
        return (input - 0) == input && (''+input).replace(/^\s+|\s+$/g, "").length > 0;
    }

});