<?php
define ('ID_ROL_USR', 1);
define ('USR_LISTAR', 'usuario/listar/');
define ('USR_NUEVO', 'usuario/nuevo');
define ('USR_MOSTRAR', 'usuario/mostrar/');
define ('USR_EDITAR', 'usuario/editar/');
define ('USR_ELIMINAR', 'usuario/eliminar/');
define ('USR_CAMB_PASS', 'usuario/campass/');

/**
 * 
 */
function iniciarModulo_usuario() {
	global $PARAMETROS;
	$id = parametros(3);
	if ( $PARAMETROS['accion'] == 'ini_ses' ) 
        {
	    return iniciarSesion();            
	} 
        elseif ( $PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'listar' ) 
        {
		return listarUsuarios();
	} elseif ($PARAMETROS['accion'] == 'mostrar') {
		return mostrarUsuario($id);
	} elseif ($PARAMETROS['accion'] == 'editar') {
		return editarUsuario( $id );
	} elseif ($PARAMETROS['accion'] == 'nuevo') {
		//return editarUsuario('0');
                return nuevoUsuario();
	} elseif ($PARAMETROS['accion'] == 'eliminar') {
		return eliminarUsuario($id);
	} elseif ($PARAMETROS['accion'] == 'campass') {
		return cambiarClaveUsuario($id);
	} elseif ($PARAMETROS['accion'] == 'salir') {
		return cerrarSesion();
	}
}

/**
 * Inicio de sesion
 */
function iniciarSesion() {
	global $PARAMETROS;
	global $GlobalIDSesion;
	//print_r($PARAMETROS);            
        //echo '<br/>' . $GlobalIDSesion . '<br/>';
        
        
$formulario = <<<FORMA
        <div id="div_ini_ses">abc
        <form action="?r=usuario/ini_ses" method="post" name="form_ini_ses" id="">
			<div class="h11">Iniciar Sesi&oacute;n</div>
			<div>
				<input type="text" placeholder="Nombre de usuario" required="" id="sys_usr"  name="sys_usr" value=""  />
			</div>
			<div>
				<input type="password" placeholder="Password" required="" id="sys_pass"  name="sys_pass" value="" />
			</div>
			<div style="height:60px; width: 200px; margin: 0 auto;">		           
  			   <input type="submit" value="Iniciar sesi&oacute;n" />
			</div>
                <input type="hidden" name="usr_sess_id" value="{$GlobalIDSesion}">
		</form>
    </div>        
FORMA;
        
         //print_r($PARAMETROS);         
                
        //si no exite variable "usr_sess_id" retorna codigo HTML -> formulario
	if ( !isset($PARAMETROS['usr_sess_id']) ) 
        {   
	     return $formulario;
	}
        else #consulta si usuario y password son correctos 
        {
//            print_r($PARAMETROS);            
		$usr = $PARAMETROS['sys_usr'];
		$pass = $PARAMETROS['sys_pass'];                
		$cons = "select * from sys_usuario where ((login = '$usr') and "
			. "(clave = '" . MD5($pass) . "') and (estado = 'A'))";
		global $BD;
		$BD->query($cons); // ejecuta consulta
		if ( $BD->numRows() > 0 ) 
                {
			$usr_reg = $BD->getNext();
			registrarSesion( $usr_reg['id'], $PARAMETROS['usr_sess_id'], $usr );
			obtenerPermisos();
			return "@paginas";
		}
                else #datos incorrectos
                {
			$cad = "<div id=\"div_error\">Autenticaci&oacute;n incorrecta.</div>";
			registrarLog(0, 'sesion', 'sesion', 
				"Inicio de sesion erroneo: [Usuario: $usr, Password: $pass, Host: " . $_SERVER["REMOTE_ADDR"] . "]");
			return $cad . $formulario;
		}
	}
}

function registrarSesion($idUsuario, $idSesion, $login) {
	global $BD;
	global $PARAMETROS;
	global $ExpiracionDeSession;
	$ahora = getdate();
	$fecha_exp = (int)($ahora['0']) + $ExpiracionDeSession;
	$fecha_exp = date("Y-m-d H:i:s", $fecha_exp);
	$BD->query(
		"update sys_sesion set usuario = $idUsuario, "
		. "expiracion = '$fecha_exp' "
		. "where (id_sesion = '$idSesion')");
	global $USR;
	$USR['id'] = $idUsuario;
	$USR['id_sesion'] = $idSesion;
	registrarLog($USR['id'], 'sesion', 'sesion', 
		"Inicio de sesion: [Usuario: $login, Sesion: $idSesion, Expiracion: $fecha_exp, Host: " . $_SERVER["REMOTE_ADDR"] . "]");
}

function cerrarSesion() {
	global $BD;
	global $USR;
	$BD->query("delete from sys_sesion where (usuario = {$USR['id']})");
	$usr = 
	registrarLog($USR['id'], 'sesion', 'sesion', 
		"Sesion cerrada: [ID: {$USR['id']}, Usuario: $usr, Host: " . $_SERVER["REMOTE_ADDR"] . "]");
	$USR = array();
	obtenerPermisos();
	return '@usuario/ini_ses';
}

/**
 * Lista usuarios en un a tabla
 */
function listarUsuarios() {
	global $BD;
        
	$BD->query("SELECT su.* , sp.desc "
		. "FROM sys_usuario su inner join sys_perfil sp on (su.perfil = sp.id_perfil) "
		. "where (id > 1) "
		. "order by login");
	$html = "<div id=\"div_lista_usuarios\">\n<h1>Listado de usuarios</h1>\n";
        
        //si usuario tiene permiso -> muestra menu de opciones CREAR NUEVO USUARIO
	if (tienePermiso(ID_ROL_USR, 'nuevo')) {
		$html .= "<h2>" . enlace('?r=' . USR_NUEVO, 'Nuevo Usuario', "Registrar un nuevo usuario") . "</h2>";
	}
        //si existen datos
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>USUARIO</th>\n"
			. "<th>PERFIL</th>\n"
			. "<th>ESTADO</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id'];
			$acciones = array();
			if (tienePermiso(ID_ROL_USR, 'ver')) {
				$acciones[] = enlace('?r=' . USR_MOSTRAR . $id, 'Ver', "Ver los datos del usuario");
			}
			if (tienePermiso(ID_ROL_USR, 'modificar')) {
				$acciones[] = enlace('?r=' . USR_EDITAR . $id, 'Editar', "Editar los datos del usuario");
			}
			if (tienePermiso(ID_ROL_USR, 'eliminar')) {
				$acciones[] = enlace('?r=' . USR_ELIMINAR . $id, 'Eliminar', "Eliminar el usuario");
			}
			$estado = '';
			switch ($reg['estado']) {
				case 'A':	$estado = 'ACTIVO'; break;
				case 'I':	$estado = 'INACTIVO'; break;
			}
			$html .= "<tr>\n"
			. "<td>Nick: {$reg['login']} <hr/>Nombre: {$reg['nombre']} </td>"
			. "<td>{$reg['desc']}</td>"
			. "<td>$estado</td>"
			. "<td>" . implode('|', $acciones)
			. "</td>"
			. "</tr>\n";
		}
		$html .= "</table>";
	} else {
		$html .= mensajeNoExistenRegistros();
	}
	$html .= "</div>";
	return $html;
}

/**
 * Modulo mara mostrar datos de usuario
 */
function mostrarUsuario($id) {
	global $BD;
	$BD->query("SELECT su.* , sp.desc "
		. "FROM sys_usuario su inner join sys_perfil sp on (su.perfil = sp.id_perfil) "
		. "where (id = $id) "
		. "order by login");
	$reg = $BD->getNext();
	$link_ret = enlace('?r=' . USR_LISTAR, 'Regresar', 'Regresar al listado de usuarios');
	$estado = '';
	switch ($reg['estado']) {
		case 'A':	$estado = 'ACTIVO'; break;
		case 'I':	$estado = 'INACTIVO'; break;
	}
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de usuario</h1>\n
			<table class="tbl_formulario">
			    <tr>
			        <td><label class="etiqueta">Nick:</label></td>
			        <td>{$reg['login']}</td>
			    </tr>
                            <tr>
			        <td><label class="etiqueta">Nombre de usuario:</label></td>
			        <td>{$reg['nombre']}</td>
			    </tr>
                            <tr>
			        <td><label class="etiqueta">Password:</label></td>
			        <td>******</td>
			    </tr>                                
			    <tr>
			        <td><label class="etiqueta">Perfil:</label></td>
			        <td>{$reg['desc']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Estado:</label></td>
			        <td>$estado</td>
			    </tr>
			</table>
		</div>
		<div class="div_normal">$link_ret</div>
MOSTREG;
	return $html;
}



/**
 * Nuevo usuario
 */
function nuevoUsuario(){
    global $BD;
    global $PARAMETROS;        
    if ( !isset( $PARAMETROS['id_reg'] ) ) {
            return formNewUsuario();
	} 
        else
        {
            if ( !existenErroresUsuario($PARAMETROS) ) { //si no existen errores
		return guardarUsuario($PARAMETROS);
            } else {
		return formNewUsuario();
            }
	}
}

/**
 * Edicion de registro de usuario
 * @param $id Identificador unico de usuario -> llave primaria
 */
function editarUsuario( $id ) {
	global $BD;
	global $PARAMETROS;	
	if ( !isset( $PARAMETROS['id_reg'] ) ) {
            return formEdUsuario( $id );
	} 
        else
        {
            if ( !existenErroresEdUsuario($PARAMETROS) ) { //si no existen errores
		return guardarUsuario($PARAMETROS);
            } else {
		return formEdUsuario($id, true);
            }
	}
}

/**
 * Formualrio nuevo usuario
 */
function formNewUsuario()
{
	global $BD;
	global $PARAMETROS;    
 //Si no existen errores 
	if ( !$errores ) {
		$BD->query("SELECT su.* , sp.desc "
		. "FROM sys_usuario su inner join sys_perfil sp on (su.perfil = sp.id_perfil) "
		. "where (id = $id) "
		. "order by login");
		$reg = $BD->getNext();
	} else {
		$reg = array();
		
		$reg['id'] = $PARAMETROS['id_reg'];
		$reg['login'] = $PARAMETROS['login'];
		$reg['clave'] = $PARAMETROS['clave'];
		$reg['perfil'] = $PARAMETROS['perfil'];
		$reg['estado'] = $PARAMETROS['estado'];
	}
        //enlace de retorno
	$link_ret = enlace('?r=' . USR_LISTAR, 'Cancelar', 'Regresar al listado de usuarios', 'enlace_boton');
	$lint_ed = USR_NUEVO;
	$listaPerfiles = listaDePerfilesUsr( $reg['perfil'] );
	$listaEstados = listaDeEstadosUsr( $reg['estado'] );
        
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de usuarios</h1>\n
			<form method="post" action="?r={$lint_ed}$id" name="form_edt_usr">
			<input type="hidden" value="$id" name="id_reg">
			<table class="tbl_formulario" border="0">
			
				<tr>
			        <td><label class="etiqueta" for="login">Nombre de usuario:</label></td>
			        <td colspan="3"><input type="text" name="login" value="{$reg['login']}" 
			        	maxlength="15" size="10" class="edt_form"/></td>
			    </tr>
				<tr>
			        <td><label class="etiqueta" for="nombre">Nombre completo:</label></td>
			        <td colspan="3"><input type="text" name="nombre" value="{$reg['nombre']}" 
			        	maxlength="50" size="30" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="clave">Contrase&ntilde;a:</label></td>
			        <td colspan="3"><input type="password" name="clave" value="" 
			        	maxlength="15" size="15" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="rep_clave">Repita la contrase&ntilde;a:</label></td>
			        <td colspan="3"><input type="password" name="rep_clave" value="" 
			        	maxlength="15" size="15" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="perfil">Perfil:</label></td>
			        <td colspan="3"><select name="perfil" class="select_form">$listaPerfiles</select></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="estado">Estado:</label></td>
			        <td colspan="3"><select name="estado" class="select_form">$listaEstados</select></td>
			    </tr>
			    <tr>
			    	<td colspan="4" align="center">Todos los datos son obligatorios</td>
			    </tr>
			    <tr>
			    	<td colspan="4" align="center"><div class="separador"></div></td>
			    </tr>                                        
			    <tr>
			    	<td colspan="2" align="center">
			    		<input type="submit" value="Guardar" class="boton">
			    	</td>
			    	<td colspan="2" align="center">$link_ret</td>
			    </tr>
			    <tr>
			    	<td width="25%">&nbsp;</td>
			    	<td width="25%">&nbsp;</td>
			    	<td width="25%">&nbsp;</td>
			    	<td width="25%">&nbsp;</td>
			    </tr>
			</table>
			</form>
		</div>
MOSTREG;
	return $html;    
}


/**
 * Formulario HTML para la edicion de datos de usuarios
 * @param $id identificador de usuario
 * @param $errores boolean TRUE|FALSE
 */
function formEdUsuario($id, $errores = false) {
	global $BD;
	global $PARAMETROS;
	
        //Si no existen errores 
	if ( !$errores ) {
		$BD->query("SELECT su.* , sp.desc "
		. "FROM sys_usuario su inner join sys_perfil sp on (su.perfil = sp.id_perfil) "
		. "where (id = $id) "
		. "order by login");
		$reg = $BD->getNext();
	} else {
		$reg = array();
		
		$reg['id'] = $PARAMETROS['id_reg'];
		$reg['login'] = $PARAMETROS['login'];
		$reg['clave'] = $PARAMETROS['clave'];
                $reg['nombre'] = $PARAMETROS['nombre'];
		$reg['perfil'] = $PARAMETROS['perfil'];
		$reg['estado'] = $PARAMETROS['estado'];                
	}
        //enlace de retorno
	$link_ret = enlace('?r=' . USR_LISTAR, 'Cancelar', 'Regresar al listado de usuarios', 'enlace_boton');
	$lint_ed = USR_EDITAR;
	$listaPerfiles = listaDePerfilesUsr( $reg['perfil'] );
	$listaEstados = listaDeEstadosUsr( $reg['estado'] );
        
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de usuarios</h1>\n
			<form method="post" action="?r={$lint_ed}$id" name="form_edt_usr">
			<input type="hidden" value="$id" name="id_reg">
			<table class="tbl_formulario" border="0">
			
				<tr>
			        <td><label class="etiqueta" for="login">Nombre de usuario:</label></td>
			        <td colspan="3"><input type="text" name="login" value="{$reg['login']}" 
			        	maxlength="15" size="10"  class="edt_form"/></td>
			    </tr>
				<tr>
			        <td><label class="etiqueta" for="nombre">Nombre completo:</label></td>
			        <td colspan="3"><input type="text" name="nombre" value="{$reg['nombre']}" 
			        	maxlength="50" size="30" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="clave">Contrase&ntilde;a:</label></td>
			        <td colspan="3"><input type="password" name="clave" value="" maxlength="15" size="15" class="edt_form"/>
                                    <input type="checkbox" name="oki" value="yes" /> Cambiar contraseña
                                    </td>
			    </tr>
			    <!--<tr>
			        <td><label class="etiqueta" for="rep_clave">Repita la contrase&ntilde;a:</label></td>
			        <td colspan="3"><input type="password" name="rep_clave" value="" 
			        	maxlength="15" size="15" class="edt_form"/></td>
			    </tr>-->
			    <tr>
			        <td><label class="etiqueta" for="perfil">Perfil:</label></td>
			        <td colspan="3"><select name="perfil" class="select_form">$listaPerfiles</select></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="estado">Estado:</label></td>
			        <td colspan="3"><select name="estado" class="select_form">$listaEstados</select></td>
			    </tr>
			    <tr>
			    	<td colspan="4" align="center">Si desea cambiar contraseña de usuario, habilite la opción, caso contrario deje sin marcar.</div></td>
			    </tr>
                            <tr>
			    	<td colspan="4" align="center"><div class="separador"></div></td>
			    </tr>
			    <tr>
			    	<td colspan="2" align="center">
			    		<input type="submit" value="Guardar" class="boton">
			    	</td>
			    	<td colspan="2" align="center">$link_ret</td>
			    </tr>
			    <tr>
			    	<td width="25%">&nbsp;</td>
			    	<td width="25%">&nbsp;</td>
			    	<td width="25%">&nbsp;</td>
			    	<td width="25%">&nbsp;</td>
			    </tr>
			</table>
			</form>
		</div>
MOSTREG;
	return $html;
}

/**
 * Gestion de errores
 * @param $form array con los valores del formulario
 */
function existenErroresUsuario( $form ) {
	$result = false;
	if (trim($form['login']) == '') {
		registrarError('Debe ingresar el nombre de usuario.');
		$result = true;
	}
        
	if (trim($form['clave']) != '') {
		if ($form['clave'] != $form['rep_clave']) {
			registrarError('Las contrase&ntilde;as son diferentes.');
			$result = true;
		}
	}
	return $result;
}

/**
 * Controla los errores de usuario en el formulario de edicion
 * @param $form array
 */
function existenErroresEdUsuario( $form )
{
    $result = false;
    if (trim($form['login']) == '') {
        registrarError('Debe ingresar el nombre de usuario del sistema.');
	$result = true;
    }
    if (trim($form['nombre']) == '') {
        registrarError('Debe ingresar el nombre completo de usuario.');
	$result = true;
    }    
    if( trim($form['oki']) == 'yes' ) //opcion para cambio de contraseña habilitado
    {
        if (trim($form['clave']) == '') {
            registrarError('Debe ingresar nueva contraseña.');
            $result = true;
        }        
    }
    return $result;
}

/**
 * Registra nuevo usuario en la base de datos
 * @param $form 
 */
function guardarUsuario( $form ) {
	global $BD;
        //actualizacion de datos
	if ( (trim($form['id_reg']) != '') && (trim($form['id_reg']) != '0') ) {
                //consulta SQL para actualizar registro
		$cons = "update sys_usuario "
		. "set "
		. "login = '{$form['login']}', "
		. "clave = '" . MD5($form['clave']) . "', "
		. "nombre = '{$form['nombre']}', "
                . "perfil = '{$form['perfil']}', "
		. "estado = '{$form['estado']}' "
		. "where (id = {$form['id_reg']})";
	} else { // registro de nuevo usuario
		global $USR;
                //consulta SQL para insertar nuevo registro
		$cons = "insert into sys_usuario  (login, clave, nombre, perfil, estado, ult_acc) "
		. "values ('{$form['login']}', '" . MD5($form['clave']) . "', '{$form['nombre']}', '{$form['perfil']}', "
		. "'{$form['estado']}', '0000-00-00')";
	}
        //gestion de errores
	if ($BD->query($cons)) {
		registrarMensaje('Se ha guardado el registro correctamente.');
	} else {
		registrarError("No se ha podido guardar el registro. <br />{$BD->error}");
	}
	return '@' . USR_LISTAR;
}

function eliminarUsuario($id) {
	global $BD;
	global $PARAMETROS;
	
	$link_ret = enlace('?r=' . USR_LISTAR, 'Cancelar', 'Regresar al listado de usuarios');
	$link_elim = USR_ELIMINAR;
	$form = <<<FORMELIMFORM
		<form method="post" action="?r=$link_elim$id" name="form_elim_usuario">
			<input type="hidden" value="$id" name="id_reg">
			<div id="div_normal">Realmente desea eliminar el registro?</div>
			<input type="submit" value="Eliminar" class="boton">
		</form>
		<div class="div_normal">$link_ret</div>
FORMELIMFORM;
	if (!isset($PARAMETROS['id_reg'])) {
		return $form;
	} else {
		global $BD;
		$cons = "delete from sys_usuario where (id = $id)";
		if ($BD->query($cons)) {
			registrarMensaje('Se ha eliminado el registro correctamente.');
		} else {
			registrarError("No se ha podido eliminar el registro. <br />{$BD->error}");
		}
		return '@' . USR_LISTAR;
	}
}

function listaDePerfilesUsr($perf_sele) {
	require_once('inc/bd_metds.inc');
	
	$html = "";
	$nbd = conectarBD();
	$nbd->query("SELECT * FROM sys_perfil order by `desc`");
	while ($reg = $nbd->getNext()) {
		if ($reg['id_perfil'] == $perf_sele) {
			$selected = "selected=\"selected\"";
		} else {
			$selected = "";
		}
		$html .= "<option value=\"{$reg['id_perfil']}\" $selected>{$reg['desc']}</option>";
	}
	return $html;
}

function listaDeEstadosUsr($estado) {
	$html = "";
	if ($estado == 'A') {
		$selected = "selected=\"selected\"";
	} else {
		$selected = "";
	}
	$html .= "<option value=\"A\" $selected>ACTIVO</option>";
	if ($estado == 'I') {
		$selected = "selected=\"selected\"";
	} else {
		$selected = "";
	}
	$html .= "<option value=\"I\" $selected>INACTIVO</option>";
	return $html;
}

function cambiarClaveUsuario($id) {
	global $PARAMETROS;
	if (!isset($PARAMETROS['id_usr'])) {
		return formCamPassUsuario($id);
	} else {
		if (!existenErroresCamPassUsuario($PARAMETROS)) {
			return cambiarPassUsuario($PARAMETROS);
		} else {
			return formCamPassUsuario($id, true);
		}
	}
}

function formCamPassUsuario($id, $errores = false) {
	global $BD;
	global $PARAMETROS;
	
	if ($errores) {
		$reg = array();
		
		$reg['actual'] = $PARAMETROS['actual'];
		$reg['nueva'] = $PARAMETROS['nueva'];
		$reg['rep_nueva'] = $PARAMETROS['rep_nueva'];
	}
	$link_ret = enlace('?r=paginas', 'Cancelar', 'Regresar al inicio', 'enlace_boton');
	$lint_ed = USR_CAMB_PASS;
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Cambiar contrase&ntilde;a de usuario</h1>\n
			<form method="post" action="?r={$lint_ed}$id" name="form_cam_pass_usr">
			<input type="hidden" value="$id" name="id_usr">
			<table class="tbl_formulario" border="0">
			
				<tr>
					<td></td>
			        <td><label class="etiqueta" for="actual">Contrase&ntilde;a actual:</label></td>
			        <td colspan="3"><input type="password" name="actual" value="" 
			        	maxlength="15" size="15" class="edt_form"/></td>
			        <td></td>
			    </tr>
			    <tr>
			    	<td></td>
			        <td><label class="etiqueta" for="nueva">Contrase&ntilde;a nueva:</label></td>
			        <td colspan="3"><input type="password" name="nueva" value="" 
			        	maxlength="15" size="15" class="edt_form"/></td>
			        <td></td>
			    </tr>
			    <tr>
			    	<td></td>
			        <td><label class="etiqueta" for="rep_nueva">Repetir contrase&ntilde;a:</label></td>
			        <td colspan="3"><input type="password" name="rep_nueva" value="" 
			        	maxlength="15" size="15" class="edt_form"/></td>
			        <td></td>
			    </tr>
			    <tr>
			    	<td colspan="4" align="center"><div class="separador"></div></td>
			    </tr>
			    <tr>
			    	<td colspan="2" align="center">
			    		<input type="submit" value="Cambiar" class="boton">
			    	</td>
			    	<td colspan="2" align="center">$link_ret</td>
			    </tr>
			    <tr>
			    	<td width="25%">&nbsp;</td>
			    	<td width="25%">&nbsp;</td>
			    	<td width="25%">&nbsp;</td>
			    	<td width="25%">&nbsp;</td>
			    </tr>
			</table>
			</form>
		</div>
MOSTREG;
	return $html;
}

/**
 * @param array $form 
 */
function existenErroresCamPassUsuario($form) {
	$result = false;
	global $USR;
	$usr = $USR['id'];
	$pass = $form['actual'];
	$cons = "select * from sys_usuario where ((id = $usr) and "
			. "(clave = '" . MD5($pass) . "') and (estado = 'A'))";
	global $BD;
	$BD->query($cons);
	if ($BD->numRows() == 0) {
		registrarError('Las contrase&ntilde;a actual es incorrecta.');
		$result = true;
	}
	if (trim($form['nueva']) == '') {
		registrarError('Las contrase&ntilde;a nueva no debe estar en blanco.');
		$result = true;
	} elseif (trim($form['nueva']) != trim($form['rep_nueva'])) {
		registrarError('Las contrase&ntilde;as no coinciden.');
		$result = true;
	}
	return $result;
}

/**
 * @param array $form 
 */
function cambiarPassUsuario($form) {
	global $BD;
	$cons = "update sys_usuario "
		. "set "
		. "clave = '" . MD5($form['nueva']) . "' "
		. "where (id = {$form['id_usr']})";
	if ($BD->query($cons)) {
		registrarMensaje('Se ha cambiado la contrase&ntilde;a correctamente.');
		$usr = obtenerLogin($form['id_usr']);
		registrarLog($form['id_usr'], 'sesion', 'usuario', "El usuario ha cambiado su clave [Usuario: $usr]");
	} else {
		registrarError("No se ha podido cambiar la contrase&ntilde;a. <br />{$BD->error}");
	}
	return '@paginas';
}
?>