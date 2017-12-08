<?php

define ('ID_ROL_SEGUI', 4);
define ('SEGUI_SEL_OBRA', 'seguimiento/selobr/');
define ('SEGUI_LISTAR', 'seguimiento/listar/');
define ('SEGUI_MOSTRAR', 'seguimiento/mostrar/');
define ('SEGUI_EDITAR', 'seguimiento/editar/');
define ('SEGUI_ESTADO_OBRA', 'clean/seguimiento/estado_avance/');
define ('SEGUI_ESTADO_OBRA_HTML', 'clean/seguimiento/estado_avance_html/');

function iniciarModulo_seguimiento() {
	global $PARAMETROS;
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'selobr') {
		return seleccionarObraSegui();
	} else {
		$id_obra = parametros(3);
		$id = parametros(4);
		if ($PARAMETROS['accion'] == 'listar') {
			return listarSeguis($id_obra);
		} elseif ($PARAMETROS['accion'] == 'mostrar') {
			return mostrarSegui($id);
		} elseif ($PARAMETROS['accion'] == 'editar') {
			return editarSegui($id);
		} elseif ($PARAMETROS['accion'] == 'estado_avance') {
			return estadoAvanceObra($id_obra);
		} elseif ($PARAMETROS['accion'] == 'estado_avance_html') {
			return estadoAvanceObra($id_obra, false);
		}
	}
}

function seleccionarObraSegui() {
	global $BD;
	$BD->query("select id_obra, nombre, tipo_proy "
		. "from con_obras "
		. "order by tipo_proy, nombre");
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
			if (tienePermiso(ID_ROL_SEGUI, 'ver')) {
				$acciones[] = enlace('?r=' . SEGUI_LISTAR . $id, 'Seleccionar', "Ver las actividades de la obra: {$reg['nombre']}");
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

function listarSeguis($pIDObra) {
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
	
	$BD->query("SELECT ca.*, caf.id_avan_fis, caf.unidad, caf.programado as programado_fis, caf.ejecutado as ejecutado_fis, caf.precio, "
		. "cafn.id_avan_fin, cafn.programado as programado_fin, cafn.ejecutado as ejecutado_fin, cafn.saldo "
		. "FROM con_actividad ca "
		. "left outer join con_avance_fisico caf on (ca.id_act = caf.actividad) "
		. "left outer join con_avance_financiero cafn on (ca.id_act = cafn.actividad) "
		. "where (ca.obra = $pIDObra)");
	$html .= "<div id=\"div_lista_actividades\">\n<h1>Listado de actividades y seguimiento</h1>\n";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>ACTIVIDAD</th>\n"
			. "<th>TIPO</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_act'];
			$acciones = array();
			if (tienePermiso(ID_ROL_SEGUI, 'ver')) {
				$acciones[] = enlace('?r=' . SEGUI_MOSTRAR . "$pIDObra/$id", 'Ver seguimiento', "Ver el seguimiento de la actividad");
			}
			if (tienePermiso(ID_ROL_SEGUI, 'modificar')) {
				$acciones[] = enlace('?r=' . SEGUI_EDITAR . "$pIDObra/$id", 'Actualizar seguimiento', "Actualizar el seguimiento de la actividad");
			}
			$html .= "<tr>\n"
			. "<td>{$reg['descripcion']}</td>"
			. "<td>{$reg['tipo']}</td>"
			. "<td align=\"center\">" . implode('|', $acciones)
			. "</td>"
			. "</tr>\n";
		}
		$html .= "</table>";
		if (tienePermiso(ID_ROL_SEGUI, 'ver')) {
			$link_estado_obra = enlace('?r=' . SEGUI_ESTADO_OBRA . $pIDObra, 
				'Estado de la obra', 
				'Ver el estado del seguimiento al avance f&iacute;sico y financiero de la obra',
				'', '_BLANK');
			$link_estado_obra_html = enlace('?r=' . SEGUI_ESTADO_OBRA_HTML . $pIDObra, 
				'HTML', 
				'Ver el estado del seguimiento al avance f&iacute;sico y financiero de la obra',
				'', '_BLANK');
			//http://localhost/pdf/htmltopdf/dompdf.php?base_path=www%2Ftest%2F&input_file=www%2Ftest%2Fphp_test.php
			/*$link_estado_obra = enlace("lib/dompdf/dompdf.php?base_path=&input_file=?r=" . SEGUI_ESTADO_OBRA . $pIDObra,
				'Estado de la obra', 
				'Ver el estado del seguimiento al avance f&iacute;sico y financiero de la obra',
				'', '_BLANK');*/
		} else {
			$link_estado_obra = '';
			$link_estado_obra_html = '';
		}
		$html .= "<div class=\"div_normal\"><p><h1>$link_estado_obra | $link_estado_obra_html</h1></p></div>";
	} else {
		$html .= mensajeNoExistenRegistros();
	};
	$html .= "</div>";
	return $html;
}

function mostrarSegui($id) {
	verificarSegui($id);
	global $BD;
	$BD->query("SELECT * "
		. "FROM con_actividad "
		. "where (id_act = $id)");
	$reg = $BD->getNext();
	$descActi = $reg['descripcion'];
	$tipoActi = $reg['tipo'];
	$link_ret = enlace('?r=' . SEGUI_LISTAR . $reg['obra'], 'Regresar', 'Regresar al listado de actividades');

	$BD->query("SELECT ca.*, caf.id_avan_fis, caf.unidad, caf.programado as programado_fis, caf.ejecutado as ejecutado_fis, caf.precio, "
		. "cafn.id_avan_fin, cafn.programado as programado_fin, cafn.ejecutado as ejecutado_fin, cafn.saldo "
		. "FROM con_actividad ca "
		. "left outer join con_avance_fisico caf on (ca.id_act = caf.actividad) "
		. "left outer join con_avance_financiero cafn on (ca.id_act = cafn.actividad) "
		. "where (ca.id_act = $id)");
	$reg = $BD->getNext();
	$precio = number_format($reg['precio'], 2);
	$prog_fis = number_format($reg['programado_fis'], 2);
	$ejec_fis = number_format($reg['ejecutado_fis'], 2);
	$prog_fin = number_format($reg['programado_fin'], 2);
	$ejec_fin = number_format($reg['ejecutado_fin'], 2);
	$saldo_fin = number_format($reg['saldo'], 2);
	if ($prog_fin > 0) {
		$porc = number_format($ejec_fin / $prog_fin * 100, 2);
	} else {
		$porc = number_format(0.0, 2);
	}
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Seguimiento de actividades</h1>\n
			<table class="tbl_formulario">
				<tr>
			        <td><label class="etiqueta">Actividad:</label></td>
			        <td colspan="3">$descActi</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Tipo de actividad:</label></td>
			        <td colspan="3">$tipoActi</td>
			    </tr>
			    <tr>
			        <td colspan="4"><h1>SEGUIMIENTO FISICO</h1></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Unidad:</label></td>
			        <td>{$reg['unidad']}</td>
			        <td><label class="etiqueta">Precio:</label></td>
			        <td>$precio</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Programado:</label></td>
			        <td>$prog_fis</td>
			        <td><label class="etiqueta">Ejecutado:</label></td>
			        <td>$ejec_fis</td>
			    </tr>
			    <tr>
			        <td colspan="4"><h1>SEGUIMIENTO FINANCIERO</h1></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Programado:</label></td>
			        <td>$prog_fin</td>
			        <td><label class="etiqueta">Ejecutado:</label></td>
			        <td>$ejec_fin</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Saldo:</label></td>
			        <td>$saldo_fin</td>
			        <td><label class="etiqueta">%:</label></td>
			        <td>$porc</td>
			    </tr>
			</table>
		</div>
		<div class="div_normal">$link_ret</div>
MOSTREG;
	return $html;
}

function editarSegui($id) {
	global $PARAMETROS;
	
	if (!isset($PARAMETROS['id_reg'])) {
		return formEdSegui($id);
	} else {
		if (!existenErroresSegui($PARAMETROS)) {
			return guardarSegui($PARAMETROS);
		} else {
			return formEdSegui($id, true);
		}
	}
}

/**
 * Formulario para editar seguimiento
 */
function formEdSegui($id, $errores = false) {
	verificarSegui($id);
	
	global $BD;
	global $PARAMETROS;
	$BD->query("SELECT * "
		. "FROM con_actividad "
		. "where (id_act = $id)");
	$reg = $BD->getNext();
	$idObra = $reg['obra'];
	$descActi = $reg['descripcion'];
	$tipoActi = $reg['tipo'];
	$link_ret = enlace('?r=' . SEGUI_LISTAR . $idObra, 'Cancelar', 'Regresar al listado de actividades', 'enlace_boton');
	$link_ed = SEGUI_EDITAR . $idObra . '/' . $id;
		
	if (!$errores) {
		$BD->query("SELECT caf.id_avan_fis, caf.unidad, caf.programado as programado_fis, caf.ejecutado as ejecutado_fis, "
		. "caf.precio, cafn.id_avan_fin, cafn.programado as programado_fin, cafn.ejecutado as ejecutado_fin, cafn.saldo "
		. "FROM con_actividad ca "
		. "left outer join con_avance_fisico caf on (ca.id_act = caf.actividad) "
		. "left outer join con_avance_financiero cafn on (ca.id_act = cafn.actividad) "
		. "where (ca.id_act = $id)");
		$reg = $BD->getNext();
		$precio = number_format($reg['precio'], 2);
		$prog_fis = number_format($reg['programado_fis'], 2);
		$ejec_fis = number_format($reg['ejecutado_fis'], 2);
		$prog_fin = number_format($reg['programado_fin'], 2);
		$ejec_fin = number_format($reg['ejecutado_fin'], 2);
		$saldo_fin = number_format($reg['saldo'], 2);
		if ($prog_fin > 0) {
			$porc = number_format($ejec_fin / $prog_fin * 100, 2);
		} else {
			$porc = number_format(0.0, 2);
		}
	} else {
		$reg = array();
		$reg['id_act'] = $PARAMETROS['id_reg'];
		$reg['id_avan_fis'] = $PARAMETROS['id_avan_fis'];
		$reg['id_avan_fin'] = $PARAMETROS['id_avan_fin'];
		$reg['unidad'] = $PARAMETROS['unidad'];
		$reg['programado_fis'] = $PARAMETROS['programado_fis'];		
		$reg['ejecutado_fis'] = $PARAMETROS['ejecutado_fis'];
		$reg['precio'] = $PARAMETROS['precio'];
		$reg['programado_fin'] = $PARAMETROS['programado_fin'];		
		$reg['ejecutado_fin'] = $PARAMETROS['ejecutado_fin'];
		$reg['saldo'] = $PARAMETROS['saldo'];
		
		$precio = $reg['precio'];
		$prog_fis = $reg['programado_fis'];
		$ejec_fis = $reg['ejecutado_fis'];
		$prog_fin = $reg['programado_fin'];
		$ejec_fin = $reg['ejecutado_fin'];
		$saldo_fin = $reg['saldo'];
		$porc = $PARAMETROS['porcentaje'];
	};
	
        //--
        $option = "<option value=\"m2\" ".(('m2'==$reg['unidad'])?'selected="selected"':'') .">m2</option>
                   <option value=\"m3\" ". (('m3'==$reg['unidad'])?'selected="selected"':'').">m3</option>
                   <option value=\"glb\" ". (('glb'==$reg['unidad'])?'selected="selected"':'').">glb</option>
                   <option value=\"pieza\" ".(('pieza'==$reg['unidad'])?'selected="selected"':'').">pieza</option>
                   <option value=\"ml\" ". (('ml'==$reg['unidad'])?'selected="selected"':'').">ml</option>
                   <option value=\"lt\" ". (('lt'==$reg['unidad'])?'selected="selected"':'').">lt</option>
                   <option value=\"un\" ". (('un'==$reg['unidad'])?'selected="selected"':'').">un</option>";
        //--
        
        
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Seguimiento de actividades</h1>\n
			<form method="post" action="?r={$link_ed}" name="form_edt_segui">
			<input type="hidden" value="$id" name="id_reg">
			<input type="hidden" value="{$reg['id_avan_fis']}" name="id_avan_fis">
			<input type="hidden" value="{$reg['id_avan_fin']}" name="id_avan_fin">
			<input type="hidden" value="$prog_fin" name="programado_fin">
			<input type="hidden" value="$saldo_fin" name="saldo">
			<input type="hidden" value="$porc" name="porcentaje">
			<input type="hidden" value="$idObra" name="obra">
			<table class="tbl_formulario">
				<tr>
			        <td><label class="etiqueta">Actividad:</label></td>
			        <td colspan="3"><label class="etiqueta">$descActi</label></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Tipo de actividad:</label></td>
			        <td colspan="3"><label class="etiqueta">$tipoActi</label></td>
			    </tr>
			    <tr>
			        <td colspan="4"><h2>Seguimiento f&iacute;sico</h2></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="unidad">Unidad:</label></td>
			        <td>
                                    <select name="unidad">{$option}</select>
                                
                                    <!--<input type="text" name="unidad" value="{$reg['unidad']}" 
			        	maxlength="5" size="5" class="edt_form"/>-->
                                    </td>
			        <td><label class="etiqueta" for="precio">Precio/Unidad:</label></td>
			        <td><input type="text" name="precio" value="$precio" 
			        	maxlength="10" size="10" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="programado_fis">Programado:</label></td>
			        <td><input type="text" name="programado_fis" value="$prog_fis" 
			        	maxlength="10" size="10" class="edt_form"/></td>
			        <td><label class="etiqueta" for="ejecutado_fis">Ejecutado:</label></td>
			        <td>
                                    <input type="text" name="ejecutado_fis" value="$ejec_fis" 
			        	maxlength="10" size="10" class="edt_form"/>
                                            </td>
			    </tr>
			    <tr>
			        <td colspan="4"><h2>Seguimiento financiero</h2></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="programado_fin">Programado:</label></td>
			        <td><input type="text" name="programado_fin_ed" value="$prog_fin" 
			        	maxlength="10" size="10" class="edt_form_disabled" disabled="true"/></td>
			        <td><label class="etiqueta" for="ejecutado_fin">Ejecutado:</label></td>
			        <td><input type="text" name="ejecutado_fin" class="edt_form_disabled" value="$ejec_fin" 
			        	maxlength="10" size="10" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="saldo">Saldo:</label></td>
			        <td><input type="text" name="saldo_ed" value="$saldo_fin" 
			        	maxlength="10" size="10" class="edt_form_disabled" disabled="true" /></td>
			        <td><label class="etiqueta" for="porcentaje">%:</label></td>
			        <td><input type="text" name="porcentaje_ed" value="$porc" 
			        	maxlength="10" size="10" class="edt_form_disabled" disabled="true" /></td>
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
			</table>
			</form>
		</div>
MOSTREG;
	return $html;
}

function existenErroresSegui($form) {
	$result = false;
	if (trim($form['unidad']) == '') {
		registrarError('Debe ingresar la unidad.');
		$result = true;
	}
	if (!is_numeric($form['precio'])) {
		registrarError('El precio debe ser un valor num&eacute;rico.');
		$result = true;
	}
	if (!is_numeric($form['programado_fis'])) {
		registrarError('El monto programado del seguimiento f&iacute;sico debe ser un valor num&eacute;rico.');
		$result = true;
	}
	if (!is_numeric($form['ejecutado_fis'])) {
		registrarError('El monto ejecutado del seguimiento f&iacute;sico debe ser un valor num&eacute;rico.');
		$result = true;
	}
	if (!is_numeric($form['ejecutado_fin'])) {
		registrarError('El monto ejecutado del seguimiento financiero debe ser un valor num&eacute;rico.');
		$result = true;
	}
	return $result;
}

function guardarSegui($form) {
	global $BD;
    global $USR;
	$precio = (float) $form['precio'];
	$prog_fis = (float) $form['programado_fis'];
	$ejec_fis = (float) $form['ejecutado_fis'];
	$prog_fin = $precio * $prog_fis;
	$ejec_fin = (float) $form['ejecutado_fin'];
	$saldo_fin = $prog_fin - $ejec_fin;
	$id_fis = $form['id_avan_fis'];
	$id_fin = $form['id_avan_fin'];
	
	$cons = "update con_avance_fisico "
		. "set "
		. "unidad = '{$form['unidad']}', "
		. "programado = $prog_fis, "
		. "ejecutado = $ejec_fis, "
		. "precio = $precio "
		. "where (id_avan_fis = $id_fis)";
    $BD->query($cons);
    registrarLog($USR['id'], 'seguimiento', 'con_avance_fisico',
            obtenerAccionesDeQuery($cons, 'Seguimiento Fis.', $id_fis));
    $cons = "update con_avance_financiero "
		. "set "
		. "programado = $prog_fin, "
		. "ejecutado = $ejec_fin, "
		. "saldo = $saldo_fin "
		. "where (id_avan_fin = $id_fin)";
	$BD->query($cons);
    registrarLog($USR['id'], 'seguimiento', 'con_avance_financiero',
            obtenerAccionesDeQuery($cons, 'Seguimiento Fin.', $id_fin));
	return '@' . SEGUI_LISTAR . $form['obra'];
}

function verificarSegui($id) {
	verificarSeguiFis($id);
	verificarSeguiFin($id);
}

function verificarSeguiFis($id) {
	global $BD;
	$BD->query("select id_avan_fis from con_avance_fisico where (actividad = $id)");
	if ($BD->numRows() == 0) {
		$BD->query("insert into con_avance_fisico "
			. "(unidad, programado, ejecutado, precio, actividad) "
			. "values ('-', 0.0, 0.0, 0.0, $id)");
	}
}

function verificarSeguiFin($id){
	global $BD;
	$BD->query("select id_avan_fin from con_avance_financiero where (actividad = $id)");
	if ($BD->numRows() == 0) {
		$BD->query("insert into con_avance_financiero "
			. "(programado, ejecutado, saldo, actividad) "
			. "values (0.0, 0.0, 0.0, $id)");
	}
}

function estadoAvanceObra($id_obra, $en_pdf = true) {
	global $BD;
	$BD->query("select nombre, tipo_proy, modalidad, contratista, nro_contrato "
		. "from con_obras where (id_obra = $id_obra)");
	$reg = $BD->getNext();
	$nombreObra = $reg['nombre'];
	$tipoProy = $reg['tipo_proy'];
	$modalidad = $reg['modalidad'];
	$contratista = $reg['contratista'];
	$nroContrato = $reg['nro_contrato'];
	$BD->query("SELECT ca.descripcion, caf.unidad, caf. programado as programado_fis, caf.ejecutado as ejecutado_fis, "
	. "caf.precio, cav.programado as programado_fin, cav.ejecutado as ejecutado_fin, cav.saldo "
	. "FROM con_actividad ca "
	. "left outer join con_avance_fisico caf on (ca.id_act = caf.actividad) "
	. "left outer join con_avance_financiero cav on (ca.id_act = cav.actividad) "
	. "where (ca.obra = $id_obra) "
	. "order by ca.id_act");
	$tblDatos = "";
	$i = 1;
	$sProg = 0.0;
	$sEjec = 0.0;
	while ($reg = $BD->getNext()) {
		$tblDatos .= "<tr>"
		. "<td align=\"center\" class=\"borde\">$i</td>"
		. "<td class=\"borde\" width=\"180\">{$reg['descripcion']}</td>"
		. "<td  align=\"center\" class=\"borde\">{$reg['unidad']}</td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($reg['programado_fis'], 2, '.', '') . "</td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($reg['ejecutado_fis'], 2, '.', '') . "</td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($reg['precio'], 2, '.', '') . "</td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($reg['programado_fin'], 2, '.', '') . "</td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($reg['ejecutado_fin'], 2, '.', '') . "</td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($reg['ejecutado_fin'] / $reg['programado_fin'] * 100.0, 2, '.', '') . "%</td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($reg['saldo'], 2, '.', '') . "</td>"
		. "</tr>";
		$sProg += $reg['programado_fin'];
		$sEjec += $reg['ejecutado_fin'];
		$i++;
	}
	$tblDatos .= "<tr>"
		. "<td></td>"
		. "<td></td>"
		. "<td></td>"
		. "<td align=\"right\"></td>"
		. "<td align=\"right\"></td>"
		. "<td align=\"right\"></td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($sProg, 2, '.', '') . "</td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($sEjec, 2, '.', '') . "</td>"
		. "<td align=\"right\" class=\"borde\">" . number_format($sEjec / $sProg * 100.0, 2, '.', '') . "%</td>"
		. "<td align=\"right\"></td>"
		. "</tr>";
	$tblAvance = 
	"<table border=\"1\" class=\"reporte\" width=\"100%\" cellspacing=\"0\">\n"
	. "<tr>"
		. "<td colspan=\"5\" align=\"center\" class=\"borde\"><strong>AVANCE F&Iacute;SICO</strong></td>"
	    . "<td colspan=\"5\" align=\"center\" class=\"borde\"><strong>AVANCE FINANCIERO</strong></td>"
	. "</tr>"
	. "<tr>"
	    . "<td colspan=\"2\" rowspan=\"2\" align=\"center\" class=\"borde\"><strong>DETALLE</strong></td>"
	    . "<td rowspan=\"2\" align=\"center\" class=\"borde\"><strong>UNIDAD</strong></td>"
	    . "<td colspan=\"2\" align=\"center\" class=\"borde\"><strong>CANTIDAD</strong></td>"
	    . "<td rowspan=\"1\" colspan=\"1\" align=\"center\" class=\"borde\"><strong>PRECIO UNIT.</strong></td>"
	    . "<td colspan=\"2\" align=\"center\" class=\"borde\"><strong>PRESUPUESTO</strong></td>"
	    . "<td rowspan=\"2\" align=\"center\" class=\"borde\"><strong>%</strong></td>"
	    . "<td rowspan=\"2\" align=\"center\" class=\"borde\"><strong>SALDO</strong></td>"
	. "</tr>"
	. "<tr>"
	    . "<td align=\"center\" class=\"borde\"><strong>Progra.</strong></td>"
	    . "<td align=\"center\" class=\"borde\"><strong>Ejecut.</strong></td>"
	    . "<td align=\"center\" class=\"borde\"></td>"
	    . "<td align=\"center\" class=\"borde\"><strong>Programado</strong></td>"
	    . "<td align=\"center\" class=\"borde\"><strong>Ejecutado</strong></td>"
	. "</tr>"
	. "$tblDatos"
	. "</table>";
	$html = <<<REPORTE
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" lang="es" xml:lang="es"> 
	<head>
    	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    	<title>Seguimiento de obras</title>  
		<style>
			body {
				margin: 50px 30px auto 30px;
			}
			table {
				border-spacing: 0px;
				font-size: 7px;
			}
			td {
				border-width: 2px;
  				padding: 2px;
			}
			td.borde {border-style: solid; border-color: black;}
		</style>		
	</head>
	<body>
	<table border="0" width="100%" class="tbl_titulos">
		<tr>
			<td colspan="4"><img src="imagenes/logo_reportes.png"></td>
		</tr>
	    <tr>
	        <td><strong>Obra:</strong></td>
	        <td>$nombreObra</td>
	        <td><strong>Tipo de proyecto:</strong></td>
	        <td>$tipoProy</td>
	    </tr>
	    <tr>
	        <td><strong>Modalidad:</strong></td>
	        <td>$modalidad</td>
	        <td><strong>Contratista:</strong></td>
	        <td>$contratista</td>
	    </tr>
	    <tr>
	        <td><strong>Nro. de contrato:</strong></td>
	        <td>$nroContrato</td>
	        <td>&nbsp;</td>
	        <td>&nbsp;</td>
	    </tr>
	</table>
	$tblAvance
	</body>
	</html>
REPORTE;

	if ($en_pdf) {
		require_once('lib/dompdf/dompdf_config.inc.php');
		$dompdf = new DOMPDF();
		$dompdf->load_html($html);
		//$dompdf->set_paper('letter', 'landscape');
		$dompdf->set_paper('letter', 'portrait');
		$dompdf->render();
		$dompdf->stream("seguimiento_$id_obra.pdf");
		exit(0);
	}
  	
	return $html;
}
