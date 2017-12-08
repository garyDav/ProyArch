$(document).ready(function () {
    
    $('#numveces,#peso').change(function() {         
        var numveces = IsNumeric($("#numveces").val())? $("#numveces").val() : 0;
        var peso = IsNumeric($("#peso").val())? $("#peso").val() : 0;
        var resultado = parseFloat(numveces) * parseFloat(peso);
        resultado = Math.round(resultado * 100) / 100;
        $("#parcial").val(resultado);
    });
   
    function IsNumeric(input)
    {
        return (input - 0) == input && (''+input).replace(/^\s+|\s+$/g, "").length > 0;
    }

});