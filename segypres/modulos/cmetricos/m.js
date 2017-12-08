$(document).ready(function () {
    
    $('#numveces,#longitud').change(function() { 
        var numveces = $("#numveces").val();
        var longitud = $("#longitud").val();
        var resultado = parseFloat(numveces) * parseFloat(longitud);
        resultado = Math.round(resultado * 100) / 100;
        $("#parcial").val(resultado);
    });
    
    });