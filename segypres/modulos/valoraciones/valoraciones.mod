<?php

define ('ID_ROL_VALORAC', 3);
define ('VALORAC_LISTAR', 'valoraciones/listar/');
define ('VALORAC_NUEVO', 'valoraciones/nuevo');
define ('VALORAC_MOSTRAR', 'valoraciones/mostrar/');
define ('VALORAC_EDITAR', 'valoraciones/editar/');
define ('VALORAC_ELIMINAR', 'valoraciones/eliminar/');

function iniciarModulo_valoraciones() {
	global $PARAMETROS;
	$id = parametros(3);
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'listar') {
		return listarValoraciones();
	} elseif ($PARAMETROS['accion'] == 'mostrar') {
		return mostrarValorac($id);
	} elseif ($PARAMETROS['accion'] == 'editar') {
		return editarValorac($id);
	} elseif ($PARAMETROS['accion'] == 'nuevo') {
		return editarValorac('0');
	} elseif ($PARAMETROS['accion'] == 'eliminar') {
		return eliminarValorac($id);
	}
}

function listarValoraciones() {
	global $BD;
	$BD->query("SELECT co.id_obra, co.nombre, co.tipo_proy, "
		. "cv.id_val, cv.descripcion, cv.valor, cv.valoracion, cv.obs "
		. "FROM con_valoracion cv "
		. "inner join con_obras co on (cv.obra = co.id_obra) "
		. "order by nombre, tipo_proy");
	$html = "<div id=\"div_lista_valoraciones\">\n<h1>Listado de valoraciones</h1>\n";
	if (tienePermiso(ID_ROL_VALORAC, 'nuevo')) {
		$html .= "<h2>" . enlace('?r=' . VALORAC_NUEVO, 'Nuevo', "Registrar una nueva valoracion") . "</h2>";
	}
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>OBRA</th>\n"
			. "<th>TIPO</th>\n"
			. "<th>VALOR</th>\n"
			. "<th>VALORACI&Oacute;N</th>\n"
			. "<th>OBSERVACIONES</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_val'];
			$acciones = array();
			if (tienePermiso(ID_ROL_VALORAC, 'ver')) {
				$acciones[] = enlace('?r=' . VALORAC_MOSTRAR . $id, 'Ver', "Ver los datos de la valoraci&oacute;n");
			}
			if (tienePermiso(ID_ROL_VALORAC, 'modificar')) {
				$acciones[] = enlace('?r=' . VALORAC_EDITAR . $id, 'Editar', "Editar los datos de la valoraci&oacute;n");
			}
			if (tienePermiso(ID_ROL_VALORAC, 'eliminar')) {
				$acciones[] = enlace('?r=' . VALORAC_ELIMINAR . $id, 'Eliminar', "Eliminar la valoraci&oacute;n");
			}
			$html .= "<tr>\n"
			. "<td>{$reg['nombre']}</td>"
			. "<td>{$reg['tipo_proy']}</td>"
			. "<td>{$reg['valor']}</td>"
			. "<td>{$reg['valoracion']}</td>"
			. "<td>{$reg['obs']}</td>"
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

function mostrarValorac($id) {
	global $BD;
	$BD->query("SELECT co.id_obra, co.nombre, co.tipo_proy, "
		. "cv.id_val, cv.descripcion, cv.valor, cv.valoracion, cv.obs "
		. "FROM con_valoracion cv "
		. "inner join con_obras co on (cv.obra = co.id_obra) "
		. "where (cv.id_val = $id)");
	$reg = $BD->getNext();
	$link_ret = enlace('?r=' . VALORAC_LISTAR, 'Regresar', 'Regresar al listado de valoraciones');

	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de valoraciones</h1>\n
			<table class="tbl_formulario">
			    <tr>
			        <td><label class="etiqueta">Nombre de la obra:</label></td>
			        <td>{$reg['nombre']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Tipo de obra:</label></td>
			        <td>{$reg['tipo_proy']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Valor:</label></td>
			        <td>{$reg['valor']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Valoraci&oacute;n:</label></td>
			        <td>{$reg['valoracion']}</td>
			    </tr>
			    <tr>
			        <td colspan="2"><label class="etiqueta">Observaciones:</label></td>
			    </tr>
			    <tr>
			        <td colspan="2">{$reg['obs']}</td>
			    </tr>
			</table>
		</div>
		<div class="div_normal">$link_ret</div>
MOSTREG;
	return $html;
}

function editarValorac($id) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
	
	if (!isset($PARAMETROS['id_reg'])) {
		return formEdValorac($id);
	} else {
		if (!existenErroresValorac($PARAMETROS)) {
			return guardarValorac($PARAMETROS);
		} else {
			return formEdValorac($id, true);
		}
	}
}

function formEdValorac($id, $errores = false) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
	
	if (!$errores) {
		$BD->query("SELECT co.id_obra, co.nombre, co.tipo_proy, "
		. "cv.id_val, cv.descripcion, cv.valor, cv.valoracion, cv.obs "
		. "FROM con_valoracion cv "
		. "inner join con_obras co on (cv.obra = co.id_obra) "
		. "where (cv.id_val = $id)");
		$reg = $BD->getNext();
	} else {
		$reg = array();
		
		$reg['id_obra'] = $PARAMETROS['id_obra'];
		$reg['id_val'] = $PARAMETROS['id_reg'];
		$reg['valor'] = $PARAMETROS['valor'];
		$reg['valoracion'] = $PARAMETROS['valoracion'];
		$reg['obs'] = $PARAMETROS['obs'];
	}
	$link_ret = enlace('?r=' . VALORAC_LISTAR, 'Cancelar', 'Regresar al listado de valoraciones', 'enlace_boton');
	$lint_ed = VALORAC_EDITAR;
	$listaObrasHTML = listaDeObrasValorac($reg['id_obra']);
	$listaValores = listaDeValoresValorac($reg['valor']);
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de valoraciones</h1>\n
			<form method="post" action="?r={$lint_ed}$id" name="form_edt_valorac">
			<input type="hidden" value="$id" name="id_reg">
			<table class="tbl_formulario" border="0">
			
				<tr>
			        <td><label class="etiqueta" for="id_obra">Obra:</label></td>
			        <td colspan="3"><select name="id_obra" class="select_form">$listaObrasHTML</select></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="valor">Valor:</label></td>
			        <td colspan="3"><select name="valor" class="select_form">$listaValores</select></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="valoracion">Valoraci&oacute;n:</label></td>
			        <td colspan="3"><input type="text" name="valoracion" value="{$reg['valoracion']}" 
			        	maxlength="100" size="60" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td colspan="4"><label class="etiqueta" for="obs">Observaciones:</label></td>
			    </tr>
			    <tr>
			        <td colspan="4"><textarea class="textarea_form" name="obs" 
			        	maxlength="100" cols="80" rows="6">{$reg['obs']}</textarea></td>
			    </tr>
			    <tr>
			    	<td colspan="4" align="center"><div class="separador"></div></td>
			    </tr>
			    <tr>
			    	<td colspan="2" align="center">
			    		<input type="submit" value="Guardar" class="boton">
			    	</td>
			    	<td colspan="2" align="center">
						$link_ret
			    	</td>
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

function existenErroresValorac($form) {
	$result = false;
	if (trim($form['valoracion']) == '') {
		registrarError('Debe ingresar la valoraci&oacute;n.');
		$result = true;
	}
	return $result;
}

function guardarValorac($form) {
	global $BD;
    global $USR;
	if ((trim($form['id_reg']) != '') && (trim($form['id_reg']) != '0')) {
		$cons = "update con_valoracion "
		. "set "
		. "descripcion = 'descripcion', "
		. "valor = {$form['valor']}, "
		. "valoracion = '{$form['valoracion']}', "
		. "obs = '{$form['obs']}', "
		. "obra = {$form['id_obra']} "
		. "where (id_val = {$form['id_reg']})";
	} else {		
		$cons = "insert into con_valoracion (descripcion, valor, valoracion, obs, "
		. "obra) "
		. "values ('', '{$form['valor']}', '{$form['valoracion']}', '{$form['obs']}', "
		. "'{$form['id_obra']}')";
	}
	if ($BD->query($cons)) {
		registrarMensaje('Se ha guardado la valoraci&oacute;n correctamente.');
        registrarLog($USR['id'], 'valoracion', 'con_valoracion',
            obtenerAccionesDeQuery($cons, 'Valoraci&oacute;n', $form['id_reg']));
	} else {
		registrarError("No se ha podido guardar la valoraci&oacute;n. <br />{$BD->error}");
	}
	return '@' . VALORAC_LISTAR;
}

function eliminarValorac($id) {
	global $BD;
	global $PARAMETROS;
    global $USR;
	
	$link_ret = enlace('?r=' . VALORAC_LISTAR, 'Cancelar', 'Regresar al listado de valoraciones');
	$link_elim = VALORAC_ELIMINAR;
	$form = <<<FORMELIMFORM
		<form method="post" action="?r=$link_elim$id" name="form_elim_valorac">
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
		$cons = "delete from con_valoracion where (id_val = $id)";
		$BD->query($cons);
        registrarLog($USR['id'], 'valoracion', 'con_valoracion',
            "Valoraci&oacute;n eliminada: [ID: $id]");
		return '@' . VALORAC_LISTAR;
	}
}

function listaDeObrasValorac($id) {
	require_once('inc/bd_metds.inc');
	
	$html = "";
	$nbd = conectarBD();
	$nbd->query("SELECT * FROM con_obras order by tipo_proy, nombre");
	$reg = $nbd->getNext();
	do {
		$tipo = $reg['tipo_proy'];
		$html .= "<optgroup label=\"$tipo\">\n";
		while ($tipo == $reg['tipo_proy']) {
			if ($reg['id_obra'] == $id) {
				$selected = "selected=\"selected\"";
			} else {
				$selected = "";
			}
			$html .= "<option value=\"{$reg['id_obra']}\" $selected>{$reg['nombre']}</option>";
			$reg = $nbd->getNext();
		}
		$html .= "</optgroup>\n";
	} while ($reg);
	return $html;
}

function listaDeValoresValorac($val) {
	$html = "";
	for ($i = 1; $i <= 10; $i++) {
		$selected = "";
		if ($i == $val) {
			$selected = "selected=\"selected\"";
		}
		$html .= "<option value=\"$i\" $selected>$i</option>";
	}
	return $html;
}
