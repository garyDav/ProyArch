<?php

function obtenerLogin($pIDUsuario) {
	global $BD;
	$BD->query("select login from sys_usuario where (id = $pIDUsuario)");
	$reg = $BD->getNext();
	return $reg['login'];
}

function registrarLog($pUsuario, $pTipo, $pTabla, $pAcciones) {
	global $BD;
	
	$fecha = date('Y-m-d');
	$hora = date('H:i:s');
	$consulta = "INSERT INTO sys_bitacora (usuario, fecha, hora, tipo, tabla, acciones) "
		. "VALUES ($pUsuario, '$fecha', '$hora', '$pTipo', '$pTabla', '$pAcciones')";
	$BD->query( $consulta );
}

function obtenerAccionesDeQuery($pConsulta, $pNombre, $pID = '') {
    $accion = obtenerSentencia($pConsulta);
    $acciones = "";
    switch ($accion) {
        case 'INSERT': {
            $acciones .= "$pNombre registrado(a): [ID: (Nuevo), ";
            $acciones .= detalleAccionesIns($pConsulta) . ']';
        } break;
        case 'UPDATE': {
            $acciones .= "$pNombre actualizado(a): [ID: $pID, ";
            $acciones .= detalleAccionesUpd($pConsulta) . ']';
        } break;
        case 'DELETE': {
            $acciones .= "$pNombre eliminado(a): [ID: $pID, ";
        } break;
    }
    return $acciones;
}

function obtenerSentencia($pConsulta) {
    $tokens = explode(' ', $pConsulta);
    return strtoupper($tokens[0]);
}

function detalleAccionesUpd($pConsulta) {
    $posSET = stripos($pConsulta, 'set');
    $posWHERE = stripos($pConsulta, 'where');
    $accionesSet = trim(substr($pConsulta, $posSET + 4, $posWHERE - $posSET - 4));
    return addslashes( $accionesSet );
}

function detalleAccionesIns($pConsulta) {
    $posINTO = stripos($pConsulta, '(') + 1;
    $posVALUES = stripos($pConsulta, 'values') + 6;
    $campos = trim(substr($pConsulta, $posINTO, $posVALUES - $posINTO - 8));
    $ultimo = strlen($pConsulta) - $posVALUES - 2;
    $valores = trim(substr($pConsulta, $posVALUES + 2, $ultimo - 1));
    $campos = explode(',', $campos);
    $valores = explode(',', $valores);
    $accionesIns = array();
    foreach ($campos as $id => $campo) {
        $accionesIns[] = "$campo = " . $valores[ $id ];
    }
    return addslashes( implode(', ', $accionesIns ));
}