<?php

/**
 * inicio.inc -> crearPagina()
 */
function existeSesion() {
	require_once('metodos.inc');
	global $BD;
	global $ExpiracionDeSession;
	global $GlobalIDSesion;
	
	session_name("SYS_SESS_ID");
	session_set_cookie_params(5200, '', '', false, false);
	session_start();
	$sesion = session_id();
	$GlobalIDSesion = $sesion;
	$BD->query("select * from sys_sesion where (id_sesion = '$sesion')");
	$ret = (boolean) ($BD->numRows() > 0);
	if (!$ret) {		
		$BD->query("insert into sys_sesion (id_sesion, expiracion, ip_origen, usuario) "
			. "values ('$sesion', '0000-00-00 0:0:0', '" . $_SERVER["REMOTE_ADDR"] . "', null)");
		return $ret;
	} else {
		$sesion_usr = $BD->getNext();
		$ses_exp = "" . $sesion_usr['expiracion'];
		if (($sesion_usr['usuario'] == '') || ($ses_exp == '0000-00-00 00:00:00')) {
			return true;
		} else {
			$fecha_st = date("Y-m-d H:i:s");
			if (strcmp($fecha_st, $ses_exp) >= 0) {
				$BD->query("delete from sys_sesion where (id_sesion = '$sesion')");
				return false;
			} else {
				$ahora = getdate();
				global $ExpiracionDeSession;
				$fecha_exp = (int)($ahora['0']) + $ExpiracionDeSession;
				$fecha_exp = date("Y-m-d H:i:s", $fecha_exp);
				$BD->query(
					"update sys_sesion set expiracion = '$fecha_exp' "
					. "where (id_sesion = '$sesion')");
				
				global $USR;	
				$USR['id'] = $sesion_usr['usuario'];
				$USR['id_sesion'] = $sesion;
				obtenerPermisos();
				return true;
			}
		}
	}
}

/**
 * Funcion que obtiene el menu de usuario segun sus permisos
 */
function obtenerPermisos() {
	global $USR;
	global $BD;
	global $Permisos;
	if ( isset($USR['id_sesion']) ) 
        {
            $id_ses = $USR['id_sesion'];
	} 
        else 
        {
	    $id_ses = 'patroclo'; #???
	}
	$BD->query(" SELECT srp.id_perf, srp.nuevo, srp.modif, srp.elim, sr.* "
		. "from sys_sesion ss "
		. "inner join sys_usuario su on (ss.usuario = su.id) "
		. "inner join sys_rol_perf srp on (su.perfil = srp.id_perf) "
		. "inner join sys_rol sr on (srp.id_rol = sr.id_rol) "
		. "where (ss.id_sesion = '$id_ses') "
		. "order by orden");
	$Permisos = $BD->getAll();
	return $Permisos;
}

/**
 * Funcion que comprueba los permisos de un usuario
 * @return BOOLEAN 
 */
function tienePermiso( $rol, $tipo = 'ver' ) {
	global $Permisos;
	global $USR;
	$base = conectarBD();
	$base->query("select srp.id_perf, srp.nuevo, srp.modif, srp.elim, sr.* "
		. "from sys_sesion ss "
		. "inner join sys_usuario su on (ss.usuario = su.id) "
		. "inner join sys_rol_perf srp on (su.perfil = srp.id_perf) "
		. "inner join sys_rol sr on (srp.id_rol = sr.id_rol) "
		. "where (ss.id_sesion = '{$USR['id_sesion']}') "
		. "and (sr.id_rol = $rol)");
	if ( $base->numRows() > 0 ) {
		$reg = $base->getNext();
		switch ($tipo) {
			case 'ver':	return true;
			case 'nuevo': return ($reg['nuevo'] == '1');
			case 'modificar': return ($reg['modif'] == '1');
			case 'eliminar': return ($reg['elim'] == '1');
		}
	} else {
		return false;
	}
}
