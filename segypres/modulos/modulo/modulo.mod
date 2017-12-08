<?php

define ('ID_ROL_MOD', 8);
define ('MOD_SEL_CONV', 'modulo/selconc/');
define ('MOD_LISTAR', 'modulo/listar/');
define ('MOD_NUEVO', 'modulo/nuevo/');
define ('MOD_MOSTRAR', 'modulo/mostrar/');
define ('MOD_EDITAR', 'modulo/editar/');
define ('MOD_ELIMINAR', 'modulo/eliminar/');
define ('MOD_ADD_ITEM_MOD', 'modulo/item/nuevo/');

define ('MOD_ADD_ITEMS_MOD', 'modulo/item/nuevos/');

define ('MOD_EDT_ITEM_MOD', 'modulo/item/editar/');
define ('MOD_DEL_ITEM_MOD', 'modulo/item/eliminar/');
define ('MOD_IMP_PRESUP', 'modulo/presupuesto/imprimir/');
define ('MOD_IMP_PRESUP_HTML', 'modulo/presupuesto/imprimir_html/');

define ('CONV_ASIGNAR', 'modulo/asignarmodsconvs/');



function iniciarModulo_modulo() {
	global $PARAMETROS;
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'selconc') {
		return seleccionarConvMod();
	} else {
		$id_conv = parametros(3);
		$id = parametros(4);
		if ($PARAMETROS['accion'] == 'listar') {
			return listarMods($id_conv);
		} elseif ($PARAMETROS['accion'] == 'mostrar') {
			return mostrarMod($id);
		} elseif ($PARAMETROS['accion'] == 'editar') {
			return editarMod($id);
		} elseif ($PARAMETROS['accion'] == 'nuevo') {
			return editarMod('0');
		} elseif ($PARAMETROS['accion'] == 'eliminar') {
			return eliminarMod($id);
		} elseif ($PARAMETROS['accion'] == 'presupuesto') {
			if ($id_conv == 'imprimir') {
				return presupuestoDeConvocatoria($id);
			} elseif ($id_conv == 'imprimir_html') {
				return presupuestoDeConvocatoria($id, false);
			}
		} elseif ($PARAMETROS['accion'] == 'item') {
			$acc = parametros(3);
			$id_mod = parametros(4);
			if ($acc == 'nuevo') { //DEPRECATED
				//return nuevoItemMod($id_conv, $id_mod);
			}elseif ($acc == 'nuevos') {
                            return nuevoItemsMod($id_conv, $id_mod);
                        }
                        elseif ($acc == 'editar') {
				$id_item = parametros(5);
				return editarItemMod($id_mod, $id_item);
			} elseif ($acc == 'eliminar') {
				$id_item = parametros(5);
				return elimItemMod($id_mod, $id_item);
			}					
		}elseif ($PARAMETROS['accion'] == 'asignarmodsconvs') {
                    return asignarModsConvs();
                }
	}
}


/* NUEVOS METODOS */
/**
 * Muestra un listado de convocatorias
 */
function asignarModsConvs(){
	global $BD;
	$BD->query("SELECT * FROM con_convocatoria order by tipo, entidad");
	$html = "<div id=\"div_sele_conv_mod\">\n<h1>Seleccionar convocatoria para continuar</h1>\n";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>ENTIDAD</th>\n"
			. "<th>OBJETO</th>\n"
			. "<th>TIPO</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_conv'];
			$acciones = array();
			if (tienePermiso(ID_ROL_MOD, 'ver')) {
				$acciones[] = enlace('?r=' . MOD_LISTAR . $id, 'Seleccionar', 
				"Ver los m&oacute;dulos de la convocatoria: {$reg['entidad']} | {$reg['objeto']}");
			}
			if (tienePermiso(ID_ROL_MOD, 'ver')) {
				$acciones[] = enlace('?r=' . MOD_IMP_PRESUP . $id, 'Presupuesto', 
				"Imprimir el presupuesto de la convocatoria: {$reg['entidad']} | {$reg['objeto']}");
			}
			$html .= "<tr>\n"
			. "<td>{$reg['entidad']}</td>"
			. "<td>{$reg['objeto']}</td>"
			. "<td>{$reg['tipo']}</td>"
			. "<td>" . implode('|', $acciones) . "</td>"
			. "</tr>\n";
		}
		$html .= "</table>";
	} else {
		$html .= mensajeNoExistenRegistros();
	}
	$html .= "</div>";
	return $html;
}

/* fin nuevos metodos */



/**
 * lista de convocatorias
 */
function seleccionarConvMod() {
	global $BD;
	$BD->query("SELECT * FROM con_convocatoria order by tipo, entidad");
	$html = "<div id=\"div_sele_conv_mod\">\n<h1>MODULOS - Seleccionar convocatoria</h1>\n";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>ENTIDAD</th>\n"
			. "<th>OBJETO</th>\n"
			. "<th>TIPO</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_conv'];
			$acciones = array();
			if (tienePermiso(ID_ROL_MOD, 'ver')) {
				$acciones[] = enlace('?r=' . MOD_LISTAR . $id, 'Seleccionar', 
				"Ver los m&oacute;dulos de la convocatoria: {$reg['entidad']} | {$reg['objeto']}");
			}
			if (tienePermiso(ID_ROL_MOD, 'ver')) {
				$acciones[] = enlace('?r=' . MOD_IMP_PRESUP . $id, 'Presupuesto', 
				"Imprimir el presupuesto de la convocatoria: {$reg['entidad']} | {$reg['objeto']}");
			}
			$html .= "<tr>\n"
			. "<td>{$reg['entidad']}</td>"
			. "<td>{$reg['objeto']}</td>"
			. "<td>{$reg['tipo']}</td>"
			. "<td>" . implode('|', $acciones) . "</td>"
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
 * Lista en una tabla los modulos que pertenecen a una determinada convocatoria dada su ID
 * @param $pIDConv Identificador principal de convocatoria
 */
function listarMods( $pIDConv ) {
	global $BD;
	$BD->query("select entidad, objeto, tipo "
		. "from con_convocatoria "
		. "where (id_conv = $pIDConv)");
	$reg = $BD->getNext();
	$entidad = $reg['entidad'];
	$objeto = $reg['objeto'];
	$tipo = $reg['tipo'];
	$html = "<div id=\"div_datos_obra\">\n"
		. "<p><label class=\"etiqueta\">Entidad: </label>$entidad</p>\n"
		. "<p><label class=\"etiqueta\">Objeto: </label>$objeto</p>\n"
		. "<p><label class=\"etiqueta\">Tipo: </label>$tipo</p>\n"
		. "</div>";
	
	$BD->query("SELECT * FROM con_modulo where (convocatoria = $pIDConv)");
	$html .= "<div id=\"div_lista_modulos\">\n<h1>Listado de m&oacute;dulos</h1>\n";
	if (tienePermiso(ID_ROL_MOD, 'nuevo')) {
		$html .= "<h2>" . enlace('?r=' . MOD_NUEVO . $pIDConv, 'Nuevo', "Registrar un nuevo m&oacute;dulo") . "</h2>";
	}
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>DESCRIPCI&Oacute;N</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_modulo'];
			$acciones = array();
			if (tienePermiso(ID_ROL_MOD, 'ver')) {
				$acciones[] = enlace('?r=' . MOD_MOSTRAR . "$pIDConv/$id", 'Ver', "Ver los datos del m&oacute;dulo");
			}
			if (tienePermiso(ID_ROL_MOD, 'modificar')) {
				$acciones[] = enlace('?r=' . MOD_EDITAR . "$pIDConv/$id", 'Editar', "Editar los datos del m&oacute;dulo");
			}
			if (tienePermiso(ID_ROL_MOD, 'eliminar')) {
				$acciones[] = enlace('?r=' . MOD_ELIMINAR . "$pIDConv/$id", 'Eliminar', "Eliminar el m&oacute;dulo");
			}
			$html .= "<tr>\n"
			. "<td>{$reg['descripcion']}</td>"
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

function mostrarMod($id) {
    
	$items_modulo = mostrarListaItemsMod($id);
	global $BD;
	$BD->query("SELECT * "
		. "FROM con_modulo "
		. "where (id_modulo = $id)");
	$reg = $BD->getNext();
	$link_ret = enlace('?r=' . MOD_LISTAR . $reg['convocatoria'], 'Regresar', 'Regresar al listado de m&oacute;dulos');

	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de m&oacute;dulos</h1>\n
			<table class="tbl_formulario">
			    <tr>
			        <td><label class="etiqueta">Descripci&oacute;n:</label></td>
			        <td>{$reg['descripcion']}</td>
			    </tr>
			    <tr>
			    	<td colspan="2">$items_modulo</td>
			    </tr>
			</table>
		</div>
		<div class="div_normal">$link_ret</div>
MOSTREG;
	return $html;
}

/**
 * Edita los datoa de modulo
 * @param $id Identificador de modulo
 */
function editarMod( $id ) {
	global $PARAMETROS;
	if (!isset($PARAMETROS['id_reg'])) {
		return formEdMod($id);
	} else {
		if (!existenErroresMod($PARAMETROS)) {
			return guardarMod($PARAMETROS);
		} else {
			return formEdMod($id, true);
		}
	}
}

/**
 * 
 */
function formEdMod($id, $errores = false) {
    
	if ($id != '0') {
		$items_modulo = editarListaItemsMod($id);
	} else {
		$items_modulo = "";
	}
	
	global $BD;
	global $PARAMETROS;
	
	if (!$errores) {
		$BD->query("SELECT * "
		. "FROM con_modulo "
		. "where (id_modulo = $id)");
		if ($BD->numRows() > 0) {
			$reg = $BD->getNext();
		} else {
			$reg['id_mod'] = '0';
			$reg['descripcion'] = '';
			$reg['convocatoria'] = parametros(3);
		}
	} else {
		$reg = array();
		
		$reg['id_mod'] = $PARAMETROS['id_reg'];
		$reg['descripcion'] = $PARAMETROS['descripcion'];
		$reg['convocatoria'] = $PARAMETROS['convocatoria'];		
	};
	
        //$link_ret = enlace('?r=' . MOD_LISTAR . $reg['convocatoria'], 'Cancelar', 'Regresar al listado de m&oacute;dulos', 'enlace_boton');
        $link_ret = "<a href=\"?r=". MOD_LISTAR . $reg['convocatoria'] ."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
        
	$lint_ed = MOD_EDITAR . $reg['convocatoria'] . '/' . $id;
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de m&oacute;dulos</h1>\n
			<form method="post" action="?r={$lint_ed}" name="form_edt_acti">
			<input type="hidden" value="$id" name="id_reg">
			<input type="hidden" value="{$reg['convocatoria']}" name="convocatoria">
                        <div class="conv_1">  			
                        <table class="tbl_formulario">
			
				<tr>
			        <td><label class="etiqueta" for="descripcion">Descripci&oacute;n:</label></td>
			        <td><input type="text" name="descripcion" value="{$reg['descripcion']}" 
			        	maxlength="200" size="70" class="edt_form" /></td>
			    </tr>
			    <tr>
			    	<td colspan="2" align="center">			    		
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
			    <tr><td colspan="2">$items_modulo</td></tr>
			</table>
                        </div>
			</form>
		</div>
MOSTREG;
	return $html;
}

function existenErroresMod($form) {
	$result = false;
	if (trim($form['descripcion']) == '') {
		registrarError('Debe ingresar la descripci&oacute;n.');
		$result = true;
	}
	return $result;
}

function guardarMod($form) {
	global $BD;
    global $USR;
	if ((trim($form['id_reg']) != '') && (trim($form['id_reg']) != '0')) {
		$cons = "update con_modulo "
		. "set "
		. "descripcion = '{$form['descripcion']}' "
		. "where (id_modulo = {$form['id_reg']})";
	} else {
		$cons = "insert into con_modulo (descripcion, convocatoria) "
		. "values ('{$form['descripcion']}', {$form['convocatoria']})";
	}
	if ($BD->query($cons)) {
	    registrarLog($USR['id'], 'modulo', 'con_modulo',
            obtenerAccionesDeQuery($cons, 'Modulo', $form['id_reg']));
		registrarMensaje('Se ha guardado el m&oacute;dulo correctamente.');
	} else {
		registrarError("No se ha podido guardar el m&oacute;dulo. <br />{$BD->error}");
	}
	return '@' . MOD_LISTAR . $form['convocatoria'];
}

/**
 * Elimina un modulo
 * @param int $id identificador unico de modulo
 */
function eliminarMod( $id ) {
	global $BD;
	global $PARAMETROS;
	$idConv = parametros(3);
	
        //$link_ret = enlace('?r=' . MOD_LISTAR . $idConv, 'Cancelar', 'Regresar al listado de m&oacute;dulos');
        $link_ret = "<a href=\"?r=".MOD_LISTAR . $idConv."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
        
	$link_elim = MOD_ELIMINAR . "$idConv/$id";
	$form = <<<FORMELIMFORM
                <div class="conv_1">  
                <form method="post" action="?r=$link_elim" name="form_elim_mod">
                <input type="hidden" value="$id" name="id_reg">
		<input type="hidden" value="$idConv" name="obra">                
                <div style="width: 300px; margin: 0 auto;">
                <table border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <td colspan="2"><div class="del_txt">Realmente desea eliminar el registro?</div></td>
                    </tr>
                    <tr>
                      <td><input type="submit" value="Eliminar" class="boton"></td>
                      <td>$link_ret</td>
                    </tr>
                  </table>
                </div>
		</form>  
                </div>		
FORMELIMFORM;
	if (!isset($PARAMETROS['id_reg'])) {
		return $form;
	} else {
		global $BD;
        global $USR;
		$cons = "DELETE FROM con_modulo WHERE (id_modulo = $id)";
		if ($BD->query($cons)) {
                        //ELIMINA REGISTROS RELACIONADOS
                        $cons = "DELETE FROM con_computo_metrico WHERE id_im IN (
                                    SELECT id_it_mod FROM con_item_modulo WHERE modulo=$id )";    
                        $BD->query($cons);                        
                        $cons = "DELETE FROM con_item_modulo WHERE (modulo = $id)";    
                        $BD->query($cons);                        
                        
			registrarMensaje("Se ha eliminado el m&oacute;dulo correctamente.");
                        registrarLog($USR['id'], 'modulo', 'con_modulo', "Modulo eliminado: [ID: $id]");
		} else {
			registrarError("No se ha podido eliminar el registro:<br />{$BD->error}");
		}
		return '@' . MOD_LISTAR . $form['convocatoria'];
	}
}

/**
 * Obtiene un listado de los items asignados a un modulo
 * @param int $id_mod Identificador unico de modulo
 */
function mostrarListaItemsMod($id_mod) {
	global $BD;
	$BD->query("SELECT cim.id_it_mod, ci.descripcion, ci.unidad, "
		. "cim.cantidad, cim.precio "
		. "FROM con_item_modulo cim "
		. "inner join con_item ci on (cim.item = ci.item_id) "
		. "where (cim.modulo = $id_mod) "
		. "order by cim.id_it_mod");
        
	$html = "<div id=\"div_lista_items_mod\">\n<strong>Items del módulo</strong>\n";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n";
		$html .= "<tr>\n"
			. "<th>ITEM</th>\n"
			. "<th>UNIDAD</th>\n"
			. "<th>CANTIDAD</th>\n"
			. "<th>PRECIO</th>\n"
			. "<th>SUBTOTAL</th>\n"
			. "</tr>\n";
                $total = 0;
		while ($reg = $BD->getNext()) {
			$cant = number_format($reg['cantidad'], 2, '.', '');
			$precio = number_format($reg['precio'], 2, '.', '');
			$subtot = number_format($cant * $precio, 2, '.', '');
			$html .= "<tr>\n"
			. "<td>{$reg['descripcion']}</td>"
			. "<td>{$reg['unidad']}</td>"
			. "<td align=\"right\">$cant</td>"
			. "<td align=\"right\">$precio</td>"
			. "<td align=\"right\">$subtot</td>"
			. "</tr>\n";
                        $total += $subtot;
		}
                
                $html .= "<tr>"
                        . "<td><strong>TOTAL</strong></td>\n"
			. "<td></td>"
			. "<td></td>"
			. "<td></td>"
			. "<td align=\"right\">{$total}</td>"
                         ."</tr>";
		$html .= "</table>";
	} else {
		$html .= mensajeNoExistenRegistros();
	}
	$html .= "</div>";
	return $html;
}

function editarListaItemsMod($id_mod) {
	global $BD;
	$BD->query("SELECT cim.id_it_mod, ci.descripcion, ci.unidad, "
		. "cim.cantidad, cim.precio "
		. "FROM con_item_modulo cim "
		. "inner join con_item ci on (cim.item = ci.item_id) "
		. "where (cim.modulo = $id_mod) "
		. "order by cim.id_it_mod");
	
	$html = "<div id=\"div_lista_items_mod\">\n<h4>Listado de items</h4>\n";
	if ( tienePermiso(ID_ROL_MOD, 'modificar') ) {
		//$html .= "<h4>" . enlace('?r=' . MOD_ADD_ITEM_MOD . $id_mod, 'A&ntilde;adir item', "Registrar un nuevo item en el m&oacute;dulo") . "</h4>";
                $html .= "<h4>" . enlace('?r=' . MOD_ADD_ITEMS_MOD . $id_mod, 'A&ntilde;adir items', "Registrar nuevos items en el m&oacute;dulo") . "</h4>";
	}
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n";
		$html .= "<tr>\n"
			. "<th>ITEM</th>\n"
			. "<th>UNIDAD</th>\n"
			. "<th>CANTIDAD</th>\n"
			. "<th>PRECIO</th>\n"
			. "<th>SUBTOTAL</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
                $total =0;
		while ($reg = $BD->getNext()) {
			$cant = number_format($reg['cantidad'], 2, '.', '');
			$precio = number_format($reg['precio'], 2, '.', '');
			$subtot = number_format($cant * $precio, 2, '.', '');
			$id = $reg['id_it_mod'];
			$acciones = array();
			if (tienePermiso(ID_ROL_MOD, 'modificar')) {
				$acciones[] = enlace('?r=' . MOD_EDT_ITEM_MOD . "$id_mod/$id", 'Editar', "Editar los datos del m&oacute;dulo");
			}
			if (tienePermiso(ID_ROL_MOD, 'modificar')) {
				$acciones[] = enlace('?r=' . MOD_DEL_ITEM_MOD . "$id_mod/$id", 'Eliminar', "Eliminar el m&oacute;dulo");
			}                        
			$html .= "<tr>\n"
			. "<td>{$reg['descripcion']}</td>"
			. "<td>{$reg['unidad']}</td>"
			. "<td align=\"right\">$cant</td>"
			. "<td align=\"right\">$precio</td>"
			. "<td align=\"right\">$subtot</td>"
			. "<td  align=\"center\">" . implode('|', $acciones)
			. "</td>"
			. "</tr>\n";
                        $total += $subtot;
		}
                $html .= "<tr>"
                        . "<td><strong>TOTAL</strong></td>"
                        . "<td colspan=\"3\"></td>"
                        . "<td align=\"right\">{$total}</td>"                        
                        . "<td></td>"
                         ."</tr>";
		$html .= "</table>";
	} else {
		$html .= mensajeNoExistenRegistros();
	}
	$html .= "</div>";
	return $html;
}

function editarItemMod($id_mod, $id_item) {
	global $PARAMETROS;
	if (!isset($PARAMETROS['id_it_mod'])) {
		return formEdItemMod($id_mod, $id_item);
	} else {
		if (!existenErroresItemMod($PARAMETROS)) {
			return guardarItemMod($PARAMETROS);
		} else {
			return formEdItemMod($id_mod, $id_item, true);
		}
	}
}

function formEdItemMod($id_mod, $id_item, $errores = false) {
	global $BD;
	global $PARAMETROS;
	$BD->query("SELECT cc.entidad, cc.objeto, cc.tipo, cm.descripcion as modulo, cm.convocatoria "
		. "FROM con_modulo cm "
		. "inner join con_convocatoria cc on (cm.convocatoria = cc.id_conv) "
		. "where (cm.id_modulo = $id_mod)");
	$reg = $BD->getNext();
	$entidad = $reg['entidad'];
	$objeto = $reg['objeto'];
	$tipo = $reg['tipo'];
	$modulo = $reg['modulo'];
	$id_conv = $reg['convocatoria'];
	$html = "<table border=\"0\">\n"
		. "<tr><td><h4>Entidad:</h4></td><td>$entidad</td></tr>"
		. "<tr><td><h4>Tipo:</h4></td><td>$tipo</td></tr>"
		. "<tr><td><h4>Objeto:</h4></td><td>$objeto</td></tr>"
		. "<tr><td><h4>M&oacute;dulo:</h4></td><td>$modulo</td></tr>"
		. "</table>\n";

	if (!$errores) {
		$BD->query("SELECT cim.id_it_mod, ci.descripcion, ci.unidad, "
		. "cim.cantidad, cim.precio, cim.modulo, cim.item "
		. "FROM con_item_modulo cim "
		. "inner join con_item ci on (cim.item = ci.item_id) "
		. "where (cim.id_it_mod = $id_item)");
		if ($BD->numRows() > 0) {
			$reg = $BD->getNext();
		} else {
			$reg['id_it_mod'] = '0';
			$reg['modulo'] = $id_mod;
			$reg['item'] = '0';
			$reg['cantidad'] = 0;
			$reg['precio'] = 0;
		}
		$cantidad = number_format($reg['cantidad'], 2, '.', '');
		$precio = number_format($reg['precio'], 2, '.', '');
		$subtot = number_format($cantidad * $precio, 2, '.', '');
	} else {
		$reg = array();
		$BD->query("SELECT ci.descripcion, ci.unidad, "
		. "cim.modulo, cim.item "
		. "FROM con_item_modulo cim "
		. "inner join con_item ci on (cim.item = ci.item_id) "
		. "where (cim.id_it_mod = $id_item)");
		$reg_tmp = $BD->getNext();
		$reg['id_it_mod'] = $PARAMETROS['id_it_mod'];
		$reg['modulo'] = $PARAMETROS['modulo'];
		$reg['item'] = $PARAMETROS['item'];
		$reg['cantidad'] = $PARAMETROS['cantidad'];
		$reg['precio'] = $PARAMETROS['precio'];
		$reg['descripcion'] = $reg_tmp['descripcion'];
		$reg['unidad'] = $reg_tmp['unidad'];
		$cantidad = $reg['cantidad'];
		$precio = $reg['precio'];
		$subtot = number_format(0.0, 2, '.', '');
	};

	$link_ret = enlace('?r=' . MOD_EDITAR . $id_conv . '/' . $id_mod, 'Cancelar', 'Regresar al m&oacute;dulo', 'enlace_boton');
	$lint_ed = MOD_EDT_ITEM_MOD . $id_mod . '/' . $id_item;
	$html = <<<MOSTREG
		<div>$html</div>
		<div id="div_mostrar_datos">\n
			<h1>Registro de m&oacute;dulos - Editar item</h1>\n
			<form method="post" action="?r={$lint_ed}" name="form_edt_item_mod">
			<input type="hidden" value="$id_item" name="id_it_mod">
			<input type="hidden" value="$id_mod" name="id_mod">
			<input type="hidden" value="{$reg['item']}" name="item">
			<input type="hidden" value="$id_conv" name="id_conv">
			<table class="tbl_formulario">
				<tr>
			        <td><label class="etiqueta">Descripci&oacute;n:</label></td>
			        <td colspan="3">{$reg['descripcion']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Unidad:</label></td>
			        <td colspan="3">{$reg['unidad']}</td>
			    </tr>
				<tr>
			        <td><label class="etiqueta" for="cantidad">Cantidad:</label></td>
			        <td><input type="text" name="cantidad" value="$cantidad" 
			        	maxlength="12" size="10" class="edt_form"/></td>
			        <td><label class="etiqueta" for="precio">Precio:</label></td>
			        <td><input type="text" name="precio" value="$precio" 
			        	maxlength="12" size="10" class="edt_form"/></td>
			    </tr>
			    <tr>
			    	<td colspan="4"><div class="separador">&nbsp</div></td>
			    </tr>
			    <tr>
			    	<td colspan="2" align="center">
			    		<input type="submit" value="Guardar" class="boton">
			    	</td>
			    	<td colspan="2" align="center">$link_ret</td>
			    </tr>
			</table>
			</form>
		</div>
MOSTREG;
	return $html;
}

function existenErroresItemMod($form) {
	$result = false;
	if (!is_numeric($form['cantidad'])) {
		registrarError('La cantidad debe ser un valor num&eacute;rico.');
		$result = true;
	}
	if (!is_numeric($form['precio'])) {
		registrarError('El precio debe ser un valor num&eacute;rico.');
		$result = true;
	}
	return $result;
}

function guardarItemMod($form) {
	global $BD;
	if ((trim($form['id_it_mod']) != '') && (trim($form['id_it_mod']) != '0')) {
		$cons = "update con_item_modulo "
		. "set "
		. "cantidad = '{$form['cantidad']}', "
		. "precio = '{$form['precio']}' "
		. "where (id_it_mod = {$form['id_it_mod']})";
	} else {
		global $USR;
		$cons = "insert into con_modulo (descripcion, convocatoria) "
		. "values ('{$form['descripcion']}', {$form['convocatoria']})";
	}
	if ($BD->query($cons)) {
	    registrarLog($USR['id'], 'modulo', 'con_item_modulo',
            obtenerAccionesDeQuery($cons, 'Modulo-Item', "{$form['descripcion']}, {$form['convocatoria']}"));
		registrarMensaje('Se ha guardado el item correctamente.');
	} else {
		registrarError("No se ha podido guardar el m&oacute;dulo. <br />{$BD->error}");
	}
	return '@' . MOD_EDITAR . $form['id_conv'] . '/' . $form['id_mod'];
}

function elimItemMod($id_mod, $id_item) {
	global $BD;
	global $PARAMETROS;
	$BD->query("select convocatoria from con_modulo where (id_modulo = $id_mod)");
	$reg = $BD->getNext();
	$link_ret = enlace('?r=' . MOD_EDITAR . $reg['convocatoria'] . '/' .$id_mod, 'Cancelar', 'Regresar al m&oacute;dulo');
	$link_elim = MOD_DEL_ITEM_MOD . "$id_mod/$id_item";
	$form = <<<FORMELIMFORM
		<form method="post" action="?r=$link_elim" name="form_elim_item_mod">
			<input type="hidden" value="$id_item" name="id_reg">
			<input type="hidden" value="$id_mod" name="id_modulo">
			<input type="hidden" value="{$reg['convocatoria']}" name="id_conv">
			<div id="div_normal">Realmente desea eliminar el registro?</div>
			<input type="submit" value="Eliminar" class="boton">
		</form>
		<div class="div_normal">$link_ret</div>
FORMELIMFORM;
	if (!isset($PARAMETROS['id_reg'])) {
		return $form;
	} else {
		global $BD;
		$cons = "delete from con_item_modulo where (id_it_mod = $id_item)";
		if ($BD->query($cons)) {
			registrarMensaje("Se ha eliminado el item del m&oacute;dulo correctamente.");
		} else {
			registrarError("No se ha podido eliminar el registro:<br />{$BD->error}");
		}
		unset($PARAMETROS['id_reg']);
		return '@' . MOD_EDITAR . $reg['convocatoria'] . '/' . $id_mod;
	}
}


/**
 * XYZ
 * Funcion para añadir nuevos items
 * @param $id_conv
 */
function nuevoItemsMod( $id_conv, $id_mod )
{
    global $PARAMETROS;
    $link_ins = $PARAMETROS['r'];
    
    //$link_ret = enlace('?r=' . MOD_EDITAR . $id_conv . '/' . $id_mod, 'Cancelar', 'Regresar al m&oacute;dulo', 'enlace_boton');
    $link_ret = "<a href=\"?r=".MOD_EDITAR . $id_conv . '/' . $id_mod."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
    
    //$items_busqueda = obtenerItemsTable();
    $form ='';
    
    //===
    if (isset($PARAMETROS['buscar'])) {
        $buscar = $PARAMETROS['buscar'];
    } else {
	$buscar = "";                
    }
    //===
    
    //busqueda de registros
    if (isset($PARAMETROS['btn_buscar']))
    {        
        $items_busqueda = obtenerItemsTable( $buscar );        
        if ($items_busqueda == "") 
        {	
            $items_busqueda = mensajeNoExistenRegistros();
        } 
    }
    else //muestra todo
    {
        $items_busqueda = obtenerItemsTable();
    }
    //registro
    if (isset($PARAMETROS['btn_guardar'])) {    
        $form = '';        
        //se registra nuevos items //http://stackoverflow.com/questions/4516847/make-array-from-checkbox-form        
        $checked = $PARAMETROS['items'];        
        $itemsNum = $PARAMETROS['itemsNum'];
        
        for($i=0; $i < count($checked); $i++){                 
            //echo "item id: " . $checked[$i] . ' i: ' . $i . ' cantidad:' . $itemsNum[ $checked[$i] ] . "<br/>";            
            guardarNuevoItemMod2( $checked[$i], $PARAMETROS['id_mod'] , $itemsNum[ $checked[$i] ] ); 
        }
        return '@' . MOD_EDITAR . $id_conv . '/' . $id_mod;
    }
        
    $form .= '<form method="post" action="?r='.$link_ins.'" name="form_nuevo_item_mod">
              <input type="hidden" value="0" name="acc_form">
              <input type="hidden" value="'.$id_conv.'" name="id_conv">
              <input type="hidden" value="'.$id_mod.'" name="id_mod">';
    
    $buscador = '<table><tr>
	           <td><strong>Buscar item:<strong></td>
		   <td align="center" colspan="2">
                   <input type="text" value="'.$buscar.'" name="buscar" size="60" class="edt_form"></td>
		   <td><input type="submit" value="Buscar" class="boton" name="btn_buscar"></td>
		   </tr></table>';
    
    $form .= $buscador;
    $form .= $items_busqueda . $link_ret ;
    $form .= '</form>';
    return $form;
}




/**
 * @deprecated
 * funcion para añadir un nuevo item a la vez con opcion de busqueda
 */

function nuevoItemMod( $id_conv, $id_mod ) {
	global $PARAMETROS;
	$link_ins = $PARAMETROS['r'];
	$link_ret = enlace('?r=' . MOD_EDITAR . $id_conv . '/' . $id_mod, 'Cancelar', 'Regresar al m&oacute;dulo', 'enlace_boton');
	
        if (isset($PARAMETROS['buscar'])) {
		$buscar = $PARAMETROS['buscar'];
	} else {
		$buscar = "";
	}
	
	if (isset($PARAMETROS['btn_buscar'])) {
		$items_busqueda = obtenerItemsModBusqueda($buscar);
		if ($items_busqueda != "") {
			$btn_elegir = "<input type=\"submit\" value=\"Seleccionar\" class=\"boton\" name=\"btn_elegir\">";
		} else {
			$btn_elegir = mensajeNoExistenRegistros();;
		}
	} else {
		/*$items_busqueda = "";
		$btn_elegir = "";*/
        $items_busqueda = obtenerItemsModBusqueda($buscar);
		if ($items_busqueda != "") {
			$btn_elegir = "<input type=\"submit\" value=\"Guardar\" class=\"boton\" name=\"btn_guardar\">";
		} else {
			$btn_elegir = mensajeNoExistenRegistros();;
		}
	}
	$guardar_item = "";
	/*
    if (isset($PARAMETROS['btn_elegir'])) {
		if (!isset($PARAMETROS['item_nuevo'])) {
			registrarError("Debe seleccionar un item. Realice la b&uacute;squeda nuevamente.");
		} else {
			global $BD;
			$BD->query("select * from con_item where (item_id = {$PARAMETROS['item_nuevo']})");
			$nuevo_item = $BD->getNext();
			$precio = number_format($nuevo_item['precio_unit'], 2, '.', '');
            $cantidad = $PARAMETROS['cant'];
			$guardar_item = <<<GUARDARITEM
			<tr>
				<td><label class="etiqueta">Item:</label></td>
				<td colspan="3">{$nuevo_item['descripcion']}</td>
			</tr>
			<tr>
				<td><label class="etiqueta">Unidad:</label></td>
				<td colspan="2">{$nuevo_item['unidad']}</td>
				<td><input type="hidden" name="nuevo_item" value="{$PARAMETROS['item_nuevo']}" />{$nuevo_item['unidad']}</td>
			</tr>
			<tr>
				<td><label for="precio" class="etiqueta">Precio:</label></td>
				<td><input type="text" size="10" maxlength="10" class="edt_form" name="precio" value="$precio" /></td>
				<td><label for="cantidad" class="etiqueta">Cantidad:</label></td>
				<td><input type="text" size="10" maxlength="10" class="edt_form" name="cantidad" value="$cantidad" /></td>
			</tr>
			<tr>
			    <td colspan="4"><div class="separador">&nbsp</div></td>
			</tr>
			<tr>
				<td  colspan="2" align="center"><input type="submit" value="Guardar" class="boton"  name="btn_guardar"></td>
			    <td  colspan="2" align="center">$link_ret</td>
			</tr>
GUARDARITEM;
		}
	}*/
	if (isset($PARAMETROS['btn_guardar'])) {
		if (!existenErroresRegNuevoItemMod($PARAMETROS)) {
			guardarNuevoItemMod($PARAMETROS);
			return '@' . MOD_EDITAR . $id_conv . '/' . $id_mod;
		}
	}
	$form = <<<FORMNUEVOITMMOD
		<div id="div_mostrar_datos">
		<form method="post" action="?r=$link_ins" name="form_nuevo_item_mod">
			<input type="hidden" value="0" name="acc_form">
			<input type="hidden" value="$id_conv" name="id_conv">
			<input type="hidden" value="$id_mod" name="id_mod">
			<table>
			    <tr>
			        <td>Buscar item:</td>
			        <td align="center" colspan="2"><input type="text" value="$buscar" name="buscar" size="50"></td>
			        <td><input type="submit" value="Buscar" class="boton" name="btn_buscar"></td>
			    </tr>
			    <tr>
			    	<td colspan="4">$items_busqueda</td>
			    </tr>
			    <tr>
			    	<td colspan="3">$btn_elegir</td><td colspan="1">$link_ret</td>
			    </tr>
			    $guardar_item
			</table>
		</form>
		</div>
FORMNUEVOITMMOD;
	return $form;
}



/**
 * Items registrado 
 * @param String $buscar parametro de busqueda
 */
function obtenerItemsTable( $buscar = null )
{
    global $BD;
    
    if( $buscar != null )
    {
        $BD->query("SELECT * FROM con_item where (descripcion like('%$buscar%')) order by descripcion");
    }
    else
    {
        $BD->query("SELECT * FROM con_item order by descripcion");    
    }    
    
    $html = "";  
    $html .= '<table border="0" class="listado">';
    $html .= '<tr>
                    <th>-</th>
                    <th>Item</th>
                    <th>Cantidad</th>
             </tr>'; 
    
    /*$select = '<select name="itemsNum[]">
      <option value="1">1</option>
	  <option value="2">2</option>
	  <option value="3">3</option>
	  <option value="4">4</option>	  
    </select>';*/
    
    $btn_elegir = "<input type=\"submit\" value=\"Guardar\" class=\"boton\" name=\"btn_guardar\">";
    //llena en cada fila un item
    $count_reg=0;
    while ($reg = $BD->getNext())
    {
        $precio = number_format($reg['precio_unit'], 2, '.', '');
        $html .= "<tr>"
            . "<td><input type='checkbox' name='items[]' value='{$reg['item_id']}' /></td>"
            . "<td class='etiqueta'> {$reg['descripcion']}  ({$reg['unidad']}) Pr. Unit.: $precio </td>"
            //. "<td>".str_replace("itemsNum[]", "itemsNum[{$reg['item_id']}]", $select)."</td>"
            . "<td><input type=\"text\" name=\"itemsNum[{$reg['item_id']}]\" value=\"1\" maxlength=\"5\" size=\"5\" class=\"edt_form\"/></td>"
            ."</tr>"; 
            $count_reg +=1;
    }    
    
    $html .= '</table>';
    $html .= $btn_elegir;   
    
    if( $count_reg > 0 )
        return $html;
    else
        return "";
}






/**
 * Resultado de busqueda
 * @param $buscar parametro de busqueda
 */
function obtenerItemsModBusqueda($buscar){
	global $BD;
	$BD->query("SELECT * FROM con_item where (descripcion like('%$buscar%')) order by descripcion");
	$html = "";
	while ($reg = $BD->getNext()) {
		$precio = number_format($reg['precio_unit'], 2, '.', '');
		$html .= "<div><label for=\"item_mod_buscar_{$reg['item_id']}\" class=\"etiqueta\">
				<input type=\"radio\" id=\"item_mod_buscar_{$reg['item_id']}\" name=\"item_nuevo\" value=\"{$reg['item_id']}\" />"
			. "{$reg['descripcion']} ({$reg['unidad']}) Pr. Unit.: $precio</label>"
			. "</div>";
	}
    $html .= "<div>"
            . "<label for=\"cant\">Cantidad:</label>"
            . "<input type=\"text\" name=\"cantidad\" id=\"cantidad\" maxlength=\"2\" size=\"3\" />"
            . "</div>";

	return $html;
}

function existenErroresRegNuevoItemMod($form) {
	$result = false;
	if (!isset($form['item_nuevo'])) {
        registrarError('Debe seleccionar un item. Realice la b&uacute;squeda nuevamente.');
		$result = true;
    }
    if (!is_numeric($form['cantidad'])) {
		registrarError('La cantidad debe ser un valor num&eacute;rico. Intente buscando el item nuevamente.');
		$result = true;
	}

	return $result;
}

/**
 * Registra nuevo item en la base dedatos
 * @param Array $form
 */
function guardarNuevoItemMod( $form ) {
    global $BD;
    //consulta SQL que obtiene precio de un item
    $cons = 'select * from con_item where item_id = ' . $form['item_nuevo'];
    $BD->query($cons);
    $reg = $BD->getNext();
    $precio = $reg['precio_unit']; 
    //codigo SQL para insertar registro
    $cons = "insert into con_item_modulo (modulo, item, cantidad, precio) "
		. "values ({$form['id_mod']}, {$form['item_nuevo']}, {$form['cantidad']}, $precio)";
	if ($BD->query($cons)) {
		registrarMensaje("Se ha a&ntilde;adido el item al m&oacute;dulo correctamente.");
	} else {
		registrarError("No se ha podido registrar el item:<br />{$BD->error}");
	}
}

/**
 * Registra nuevo item_modulo en la base de datos
 * @param int $iditem identificador unico de item
 * @param int $idmod identificador unico de modulo
 * @param int $cantidad cantidad de 
 */
function guardarNuevoItemMod2( $iditem, $idmod, $cantidad=0 )
{
    global $BD;
    //consulta SQL que obtiene precio de un item
    $cons = 'SELECT * FROM con_item WHERE item_id = ' . $iditem ;
    $BD->query( $cons );
    $reg = $BD->getNext();
    $precio = $reg['precio_unit']; 
    $descripcion = $reg['descripcion']; 
    
    //comprueba que item no este registrado ya en algun modulo
    $cons = "SELECT COUNT( * ) AS totalreg
            FROM con_item_modulo
            INNER JOIN con_modulo ON id_modulo = modulo
            WHERE item ={$iditem}
            AND convocatoria = ( 
            SELECT convocatoria
            FROM con_modulo
            WHERE id_modulo ={$idmod} )  " ;
    $BD->query( $cons );
    $reg = $BD->getNext();
    $totalreg = $reg['totalreg']; 

    if( $totalreg>0 ){//no se puede registrar
        registrarError("[Error]: Item \"{$descripcion}\" Ya esta en uso.");
    }else{//registra porque es nuevo
        //codigo SQL para insertar registro en la base de datos
        $cons = "INSERT INTO con_item_modulo ( modulo, item, cantidad, precio ) "
                    . " VALUES ( {$idmod}, {$iditem}, {$cantidad}, $precio)";    

        if ( $BD->query($cons) ) {
            //obtiene ID de ultimo registro ITEM_MODULO
            $sql = 'SELECT MAX(id_it_mod) AS id FROM con_item_modulo ' ;    
            $BD->query( $sql );    
            $reg = $BD->getNext();
            $id_it_mod = $reg['id'];     
            //Obtiene valores de 
            $sql = " SELECT precio , unidad FROM con_item_modulo INNER JOIN  con_item ON item_id=item
                    WHERE id_it_mod = $id_it_mod" ;    
            $BD->query( $sql );    
            $reg = $BD->getNext();
            $unidad = $reg['unidad'];     
            $precio = $reg['precio'];     
            //Codigo sql para inserta registro en avance de obra        
            $sql = "INSERT INTO con_avance_fisico ( unidad ,  programado ,  ejecutado ,  precio ,  idim ) "
                    . " VALUES ( '{$unidad}', 0 , 0, $precio , {$id_it_mod})";            
            $BD->query( $sql );    
            $sql = "INSERT INTO con_avance_financiero ( programado ,  ejecutado ,  saldo ,  idim  ) "
                    . " VALUES (  0 , 0, 0 , {$id_it_mod})";                    
            $BD->query( $sql );    

            registrarMensaje("Se ha a&ntilde;adido el item al m&oacute;dulo correctamente.");
        } else {
            registrarError("No se ha podido registrar el item:<br />{$BD->error}");
        }    
    }    
    
}






/**
 * PDF
 */
function presupuestoDeConvocatoria( $id_conv, $en_pdf = true ) {
	global $BD;
	
	$datosConv = obtDatosConvHTMLPres($id_conv);
	$presupConv = obtPresupConvHTML($id_conv);
        
	$html = <<<REPORTE
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" lang="es" xml:lang="es"> 
	<head>
    	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    	<title>Presupuesto</title>  	
        <link type="text/css" rel="stylesheet" media="all" href="temas/defecto/defecto.css" />                
	</head>
	<body>
		<div>$datosConv</div>
		<div class="htmlreport">$presupConv</div>
	</body>
REPORTE;
	
	if ($en_pdf) {
		require_once('lib/dompdf/dompdf_config.inc.php');
		$dompdf = new DOMPDF();
		$dompdf->load_html($html);
		//$dompdf->set_paper('letter', 'landscape');
		$dompdf->set_paper('letter', 'portrait');
		$dompdf->render();
		$dompdf->stream("presupuesto_$id_conv.pdf");
		exit(0);
	}
  	
	return $html;
}

function obtDatosConvHTMLPres($id_conv) {
	global $BD;
	$BD->query("SELECT tipo, cuce, entidad, objeto, duracion, "
		. "fecha_inicio, fecha_fin FROM con_convocatoria "
		. "where (id_conv = $id_conv)");
	$reg = $BD->getNext();
	$html = <<<DATCONV
	<table border="0" width="100%" class="tbl_titulos">
		<tr>
			<td colspan="6"><img src="imagenes/logo_reportes.png"></td>
		</tr>
		<tr>
			<td colspan="6" align="center"><h3>PRESUPUESTO</h3></td>
		</tr>
	    <tr>
	        <td><strong>Entidad:</strong></td>
	        <td colspan="5">{$reg['entidad']}</td>
	    </tr>
	    <tr>
	        <td><strong>Objeto:</strong></td>
	        <td colspan="5">{$reg['objeto']}</td>
	    </tr>
	    <tr>
	        <td><strong>tipo:</strong></td>
	        <td colspan="5">{$reg['tipo']}</td>
	    </tr>
	    <tr>
	        <td><strong>Duraci&oacute;n:</strong></td>
	        <td>{$reg['duracion']}</td>
	        <td><strong>Fecha inicio:</strong></td>
	        <td>{$reg['fecha_inicio']}</td>
	        <td><strong>Fecha fin.:</strong></td>
	        <td>{$reg['fecha_fin']}</td>
	    </tr>
	</table>
DATCONV;
	return $html;
}

/**
 * @param int $id_conv 
 */
function obtPresupConvHTML( $id_conv ) {
	global $BD;
	$BD->query(" SELECT id_modulo, descripcion "
		. " FROM con_modulo cm "
		. " WHERE (cm.convocatoria = $id_conv)");
	$reg = $BD->getAll();
	$html = "<table>";
	$tot_pres = 0.0;
	foreach ($reg as $modulo) {
		$total_mod = number_format(calcularTotalMod($modulo['id_modulo']), 2, '.', '');
		$tot_pres += $total_mod;
		$items_pres = obtItemsModPresu($modulo['id_modulo']);
		$html .= "<tr>"
			. "<th>MODULO:</th>"
			. "<th>{$modulo['descripcion']}</th>"
			. "<th>TOTAL:</th>"
			. "<th align=\"right\">$total_mod</th>"
			. "</tr>"
			. "<tr>"
			. "<td colspan=\"4\">$items_pres</td>"
			. "</tr>";
	};
	$html .= "<tr>"
			. "<th colspan=\"3\"><h2>TOTAL PRESUPUESTADO:</h2></th>"
			. "<td align=\"right\"> <h2>" . number_format($tot_pres, 2, '.', '') . "</h2></td>"
			. "</tr>";
	$html .= "</table>";
	return $html;
}

function calcularTotalMod($id_mod) {
	global $BD;
	$BD->query("SELECT SUM(cantidad * precio) as subtot "
		. "from con_item_modulo cim "
		. "where (cim.modulo = $id_mod)");
	$reg = $BD->getNext();
	return $reg['subtot'];
}

function obtItemsModPresu($id_mod) {
	global $BD;
	$BD->query("SELECT cim.*, ci.descripcion as item, ci.unidad "
		. "from con_item_modulo cim "
		. "inner join con_item ci on (cim.item = ci.item_id) "
		. "where (cim.modulo = $id_mod)");
	$html = "<div class=\"htmlreport\"><table>"
		. "<tr>"
		. "<th align=\"center\">Item</th>"
		. "<th align=\"center\">Und.</th>"
		. "<th align=\"center\">Cant.</th>"
		. "<th align=\"center\">Precio</th>"
		. "<th align=\"center\">Subtot.</th>"
		. "</tr>";
	while ($reg = $BD->getNext()) {
		$cant = number_format($reg['cantidad'], 2, '.', '');
		$precio = number_format($reg['precio'], 2, '.', '');
		$subtot = number_format($cant * $precio, 2, '.', '');
		$html .= "<tr>"
			. "<td>{$reg['item']}</td>"
			. "<td align=\"center\">{$reg['unidad']}</td>"
			. "<td align=\"right\">$cant</td>"
			. "<td align=\"right\">$precio</td>"
			. "<td align=\"right\">$subtot</td>"
			. "</tr>";
	}
	$html .= "</table></div>";
	return $html;
}
