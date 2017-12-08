<?php
include ('conf.php');
require_once 'bd/anyDB.php';
require_once 'bd/addon/DBHelper.php';
require_once 'bd/addon/QueryHelper.php';

global $BD;

/**
 * conectarConBD()
 */
function inicializarBD()
{
	global $BD;
	global $Servidor;
	global $NombreBD;
	global $Usuario;
	global $Clave;
	global $TipoBD;
	global $Persistente;
	global $BD;
	global $Errores;
	
	$BD = anyDB::getLayer($TipoBD, '', $TipoBD);
	$BD->connect($Servidor, $NombreBD, $Usuario, $Clave, $Persistente);
}

/**
 * inicio.inc -> existeConexionBD()
 */
function conectarConBD() {
	global $BD;	
	inicializarBD();	
	return $BD;
}

function conectarBD() {
	global $Servidor;
	global $NombreBD;
	global $Usuario;
	global $Clave;
	global $TipoBD;
	global $Persistente;
	global $BD;
	global $Errores;
	
	$base = anyDB::getLayer($TipoBD, '', $TipoBD);
	$base->connect($Servidor, $NombreBD, $Usuario, $Clave, $Persistente);
	
	return $base;
}
