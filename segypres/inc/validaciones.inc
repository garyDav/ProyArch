<?php

/**
 * Valida fechas con la forma 00/00/0000
 */
function fechaValida($cad) {
	$dia = trim(substr($cad, 0, 2));
	$mes = trim(substr($cad, 3, 2));
	$anio = trim(substr($cad, 6, 4));
	
	if (settype($dia, "integer") && settype($mes, "integer") && settype($anio, "integer")) {
		return checkdate($mes, $dia, $anio);
	} else {
		return false;
	}
}

/** 
 * Valida fechas con la forma 2013-11-20
 *                            0123456789 
 */
function fechaValida2( $cad )
{/*
    $anio = trim(substr($cad, 0, 4));
    $mes = trim(substr($cad, 4, 2));
    $dia = trim(substr($cad, 7, 2));
    */
    $f = explode("-", $cad);
    $anio = $f[0];
    $mes = $f[1];
    $dia = $f[2];
    
	if (settype($dia, "integer") && settype($mes, "integer") && settype($anio, "integer")) {
		return checkdate($mes, $dia, $anio);
	} else {
		return false;
	}
}


function esNumeroEntero($cad) {
	if (is_numeric($cad)) {
		return ((int)$cad) == ((double)$cad);
	} else {
		return false;
	}
}
