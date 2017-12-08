$(document).ready(function () {
    
    $('#numveces').change(function() {         
        var resultado = IsNumeric($("#numveces").val())? $("#numveces").val() : 0;
        $("#parcial").val( parseFloat(resultado) );
    });
   
    function IsNumeric(input)
    {
        return (input - 0) == input && (''+input).replace(/^\s+|\s+$/g, "").length > 0;
    }

});