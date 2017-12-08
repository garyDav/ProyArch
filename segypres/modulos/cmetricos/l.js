$(document).ready(function () {
    
    $('#numveces,#volumen').change(function() {         
        var numveces = IsNumeric($("#numveces").val())? $("#numveces").val() : 0;
        var peso = IsNumeric($("#volumen").val())? $("#volumen").val() : 0;
        var resultado = parseFloat(numveces) * parseFloat(peso);
        resultado = Math.round(resultado * 100) / 100;
        $("#parcial").val(resultado);
    });
   
    function IsNumeric(input)
    {
        return (input - 0) == input && (''+input).replace(/^\s+|\s+$/g, "").length > 0;
    }

});