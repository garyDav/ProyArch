<?php

define ('ID_ROL_ACTI', 5);
define ('ACTI_SEL_OBRA', 'actividades/selobr/');
define ('ACTI_LISTAR', 'actividades/listar/');
define ('ACTI_NUEVO', 'actividades/nuevo/');
define ('ACTI_MOSTRAR', 'actividades/mostrar/');
define ('ACTI_EDITAR', 'actividades/editar/');
define ('ACTI_ELIMINAR', 'actividades/eliminar/');

function iniciarModulo_actividades() {
	global $PARAMETROS;
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'selobr') {
		return seleccionarObraActi();
	} else {
		$id_obra = parametros(3);
		$id = parametros(4);
		if ($PARAMETROS['accion'] == 'listar') {
			return listarActividades($id_obra);
		} elseif ($PARAMETROS['accion'] == 'mostrar') {
			return mostrarActividad($id);
		} elseif ($PARAMETROS['accion'] == 'editar') {
			return editarActividad($id);
		} elseif ($PARAMETROS['accion'] == 'nuevo') {
			return editarActividad('0');
		} elseif ($PARAMETROS['accion'] == 'eliminar') {
			return eliminarActi($id);
		}
	}
}

/**
 * Seleccionar Obra
 */
function seleccionarObraActi() {
	global $BD;
	$BD->query("select id_obra, nombre, tipo_proy "
		. " FROM con_obras "                
		. " ORDER BY tipo_proy, nombre");
	$html = "<div id=\"div_sele_obra_act\">\n<h1>Seleccionar obra</h1>\n";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>OBRA</th>\n"
			. "<th>TIPO</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_obra'];
			$acciones = array();
			if (tienePermiso(ID_ROL_ACTI, 'ver')) {
				$acciones[] = enlace('?r=' . ACTI_LISTAR . $id, 'Seleccionar', "Ver las actividades de la obra: {$reg['nombre']}");
			}
			$html .= "<tr>\n"
			. "<td>{$reg['nombre']}</td>"
			. "<td>{$reg['tipo_proy']}</td>"
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
 * Listado de actividades
 * @param $pIDObra
 */
function listarActividades( $pIDObra ) {
	global $BD;
	$BD->query("select id_obra, nombre, tipo_proy "
		. "from con_obras "
		. "where (id_obra = $pIDObra)");
	$reg = $BD->getNext();
	$nombreObra = $reg['nombre'];
	$tipoProy = $reg['tipo_proy'];
	$html = "<div id=\"div_datos_obra\">\n"
		. "<p><label class=\"etiqueta\">Nombre de la obra:</label>$nombreObra</p>\n"
		. "<p><label class=\"etiqueta\">Tipo de proyecto:</label>$tipoProy</p>\n"
		. "</div>";
	
	$BD->query("SELECT * FROM con_actividad where (obra = $pIDObra)");
	$html .= "<div id=\"div_lista_actividades\">\n<h1>Listado de actividades</h1>\n";
	if (tienePermiso(ID_ROL_ACTI, 'nuevo')) {
		$html .= "<h2>" . enlace('?r=' . ACTI_NUEVO . $pIDObra, 'Nuevo', "Registrar una nueva actividad") . "</h2>";
	}
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>ACTIVIDAD</th>\n"
			. "<th>TIPO</th>\n"
                        . "<th>PRESUPUESTADO</th>\n"
			. "<th>OBSERVACIONES</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_act'];
			$acciones = array();
			if (tienePermiso(ID_ROL_ACTI, 'ver')) {
				$acciones[] = enlace('?r=' . ACTI_MOSTRAR . "$pIDObra/$id", 'Ver', "Ver los datos de la actividad");
			}
			if (tienePermiso(ID_ROL_ACTI, 'modificar')) {
				$acciones[] = enlace('?r=' . ACTI_EDITAR . "$pIDObra/$id", 'Editar', "Editar los datos de la actividad");
			}
			if (tienePermiso(ID_ROL_ACTI, 'eliminar')) {
				$acciones[] = enlace('?r=' . ACTI_ELIMINAR . "$pIDObra/$id", 'Eliminar', "Eliminar la actividad");
			}
			$html .= "<tr>\n"
			. "<td>{$reg['descripcion']}</td>"
			. "<td>{$reg['tipo']}</td>"
                        . "<td>{$reg['presupuestado']}</td>"
			. "<td>{$reg['observaciones']}</td>"
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
 * Mostrar Actividad
 * @param $id Identificador de actividad
 */
function mostrarActividad($id) {
	global $BD;
	$BD->query("SELECT * "
		. "FROM con_actividad "
		. "where (id_act = $id)");
	$reg = $BD->getNext();
	$link_ret = enlace('?r=' . ACTI_LISTAR . $reg['obra'], 'Regresar', 'Regresar al listado de actividades');

	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de actividades</h1>\n
			<table class="tbl_formulario">
			    <tr>
			        <td><label class="etiqueta">Descripci&oacute;n:</label></td>
			        <td>{$reg['descripcion']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Tipo de actividad:</label></td>
			        <td>{$reg['tipo']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Presupuestado:</label></td>
			        <td>{$reg['presupuestado']}</td>
			    </tr>                                
			    <tr>
			        <td colspan="2"><label class="etiqueta">Observaciones:</label></td>
			    </tr>
			    <tr>
			        <td colspan="2">{$reg['observaciones']}</td>
			    </tr>
			</table>
		</div>
		<div class="div_normal">$link_ret</div>
MOSTREG;
	return $html;
}

function editarActividad($id) {
	global $PARAMETROS;
	
	if (!isset($PARAMETROS['id_reg'])) {
		return formEdActi($id);
	} else {
		if (!existenErroresActi($PARAMETROS)) {
			return guardarActi($PARAMETROS);
		} else {
			return formEdActi($id, true);
		}
	}
}

/**
 * Formulario edicion de actividad
 * @param $id
 * @param $errores
 */
function formEdActi($id, $errores = false) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
	
	if (!$errores) { //Si no existen errores
		$BD->query("SELECT * "
		. "FROM con_actividad "
		. "where (id_act = $id)");
		if ($BD->numRows() > 0) {
			$reg = $BD->getNext();
		} else {
			$reg['id_act'] = '0';
			$reg['descripcion'] = '';
			$reg['tipo'] = '';
			$reg['observaciones'] = '';
			$reg['obra'] = parametros(3);
		}
	} else {
		$reg = array();
		
		$reg['id_act'] = $PARAMETROS['id_reg'];
		$reg['descripcion'] = $PARAMETROS['descripcion'];
		$reg['obra'] = $PARAMETROS['obra'];		
		$reg['tipo'] = $PARAMETROS['tipo'];
		$reg['observaciones'] = $PARAMETROS['observaciones'];
	};
	$link_ret = enlace('?r=' . ACTI_LISTAR . $reg['obra'], 'Cancelar', 'Regresar al listado de actividades', 'enlace_boton');
	
        $lint_ed = ACTI_EDITAR . $reg['obra'] . '/' . $id;
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de actividades</h1>\n
			<form method="post" action="?r={$lint_ed}" name="form_edt_acti">
			<input type="hidden" value="$id" name="id_reg">
			<input type="hidden" value="{$reg['obra']}" name="obra">
			<table class="tbl_formulario">
			
				<tr>
			        <td><label class="etiqueta" for="descripcion">Descripci&oacute;n:</label></td>
			        <td><input type="text" name="descripcion" value="{$reg['descripcion']}" 
			        	maxlength="500" size="70" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="tipo">Tipo:</label></td>
			        <td><input type="text" name="tipo" value="{$reg['tipo']}" 
			        	maxlength="50" size="35" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="Presupuestado">Presupuestado:</label></td>
			        <td>
                                    <input name="presupuestado" type="checkbox" value="Si" checked="checked" />
                                </td>
			    </tr>                                
			    <tr>
			        <td colspan="2"><label class="etiqueta" for="observaciones">Observaciones:</label></td>
			    </tr>
			    <tr>
			        <td colspan="2"><textarea class="textarea_form" name="observaciones" 
			        	maxlength="500" cols="80" rows="6">{$reg['observaciones']}</textarea></td>
			    </tr>
			    <tr>
			    	<td colspan="2" align="center">
			    		<div class="separador">&nbsp</div>
			    		<input type="submit" value="Guardar" class="boton">
			    		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    		$link_ret
			    	</td>
			    </tr>
			</table>
			</form>
		</div>
MOSTREG;
	return $html;
}

function existenErroresActi($form) {
	$result = false;
	if (trim($form['descripcion']) == '') {
		registrarError('Debe ingresar la descripci&oacute;n.');
		$result = true;
	}
	if (trim($form['tipo']) == '') {
		registrarError('Debe ingresar el tipo.');
		$result = true;
	}
	return $result;
}

/**
 * Guarda una nueva actividad en la base de datos
 * @param $form
 */
function guardarActi($form) {
    
    global $BD;
    global $USR;
	if ((trim($form['id_reg']) != '') && (trim($form['id_reg']) != '0')) {
		$cons = "update con_actividad "
		. "set "
		. "descripcion = '{$form['descripcion']}', "
		. "tipo = '{$form['tipo']}', "
		. "observaciones = '{$form['observaciones']}' "
		. "where (id_act = {$form['id_reg']})";
	} else {
            //registra nueva actividad            
            $p = ($form['presupuestado']=='Si')?'Si':'No';
            $cons = "insert into con_actividad (descripcion, tipo,presupuestado, observaciones, obra) "
		. "values ('{$form['descripcion']}', '{$form['tipo']}', '{$p}' , '{$form['observaciones']}', "
		. "'{$form['obra']}')";
	}
	if ($BD->query($cons)) {
		registrarMensaje('Se ha guardado la actividad correctamente.');
        registrarLog($USR['id'], 'actividades', 'con_actividad',
            obtenerAccionesDeQuery($cons, 'Actividad', $form['id_reg']));
	} else {
		registrarError("No se ha podido guardar la actividad. <br />{$BD->error}");
	}
	return '@' . ACTI_LISTAR . $form['obra'];
}

function eliminarActi($id) {
	global $BD;
	global $PARAMETROS;
	$idObra = parametros(3);
	$link_ret = enlace('?r=' . ACTI_LISTAR . $idObra, 'Cancelar', 'Regresar al listado de actividades');
	$link_elim = ACTI_ELIMINAR . "$idObra/$id";
	$form = <<<FORMELIMFORM
		<form method="post" action="?r=$link_elim" name="form_elim_acti">
			<input type="hidden" value="$id" name="id_reg">
			<input type="hidden" value="$idObra" name="obra">
			<div id="div_normal">Realmente desea eliminar el registro?</div>
			<input type="submit" value="Eliminar" class="boton">
		</form>
		<div class="div_normal">$link_ret</div>
FORMELIMFORM;
	if (!isset($PARAMETROS['id_reg'])) {
		return $form;
	} else {
		global $BD;
        global $USR;
		$cons = "delete from con_actividad where (id_act = $id)";
		if ($BD->query($cons)) {
			registrarMensaje("Se ha eliminado el registro correctamente.");
            registrarLog($USR['id'], 'actividades', 'con_actividad',
            "Actividad eliminada:  [ID: $id]");
		} else {
			registrarError("No se ha podido eliminar el registro:<br />{$BD->error}");
		}
		return '@' . ACTI_LISTAR . $form['obra'];
	}
}
