<?php

function cadenaAFecha($cadena) {
	$anyo = (int)substr($cadena, 0, 4);
	$mes = (int)substr($cadena, 5, 2);
	$dia = (int)substr($cadena, 8, 2);
	
	return mktime(0, 0, 0, $mes, $dia, $anyo);
}

/**
 * metodo para 
 */
function cadenaAFecha2($cadena) {
	$dia = (int)substr($cadena, 0, 2);
	$mes = (int)substr($cadena, 3, 2);
	$anyo = (int)substr($cadena, 6, 4);

	return mktime(0, 0, 0, $mes, $dia, $anyo);
}

/**
 * Convierte una cadena a fecha
 * @param String $cadena de la forma yyyy-mm-dd
 */
function cadenaAFecha3( $cadena ) {
	/*$dia = (int)substr($cadena, 0, 2);
	$mes = (int)substr($cadena, 3, 2);
	$anyo = (int)substr($cadena, 6, 4);*/
    $f = explode("-", $cadena);
    $anio = $f[0];
    $mes = $f[1];
    $dia = $f[2];
    return mktime(0, 0, 0, $mes, $dia, $anio);
}