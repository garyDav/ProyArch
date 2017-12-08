<?php

define ('ID_ROL_ITEMS', 7);
define ('ITEMS_LISTAR', 'items/listar/');
define ('ITEMS_NUEVO', 'items/nuevo');
define ('ITEMS_MOSTRAR', 'items/mostrar/');
define ('ITEMS_EDITAR', 'items/editar/');
define ('ITEMS_ELIMINAR', 'items/eliminar/');

define ('DETALLE_NUEVO', 'items/agregar-detalle/');
define ('DETALLE_EDITAR', 'items/editar-detalle/');
define ('DETALLE_ELIMINAR', 'items/eliminar-detalle/');


function iniciarModulo_items() {
	global $PARAMETROS;
	$id = parametros(3);       
                
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'listar') {
		return listarItems();
	} elseif ($PARAMETROS['accion'] == 'mostrar') {
		return mostrarItem( $id );
	} elseif ($PARAMETROS['accion'] == 'editar') {
		return editarItem($id);
	} elseif ($PARAMETROS['accion'] == 'nuevo') {
		return editarItem('0');
	} elseif ($PARAMETROS['accion'] == 'eliminar') {
		return eliminarItem($id);
	} elseif ($PARAMETROS['accion'] == 'editar-detalle') {
                $id_item = parametros(4);
		return editarDetalle( $id, $id_item );
	} elseif ($PARAMETROS['accion'] == 'agregar-detalle') {
		return editarDetalle( '0' , $id );	
	} elseif ($PARAMETROS['accion'] == 'eliminar-detalle') {
                $id_item = parametros(4);
		return eliminarDetalleItem( $id , $id_item );
	}
        
}

//

//------------------------------------------------------------------------------>

function listarItems() {
	global $BD;
	$BD->query("SELECT * FROM con_item order by unidad, descripcion");
	$html = "<div id=\"div_lista_items\">\n<h1>Listado de items</h1>\n";
	
        if (tienePermiso(ID_ROL_ITEMS, 'nuevo')) {
		$html .= "<h2>" . enlace('?r=' . ITEMS_NUEVO, 'Nuevo', "Registrar un nuevo item") . "</h2>";
	}
        
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\">\n"
			. "<tr>\n"
			. "<th>NUM. ITEM</th>\n"
                        . "<th>DESCRIPCI&Oacute;N</th>\n"
			. "<th>UNIDAD</th>\n"
			. "<th>PRECIO UNITARIO</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['item_id'];
			$acciones = array();
                        
			if (tienePermiso(ID_ROL_ITEMS, 'ver')) {
				$acciones[] = enlace('?r=' . ITEMS_MOSTRAR . $id, 'Ver', "Ver los datos del item");
			}
			if (tienePermiso(ID_ROL_ITEMS, 'modificar')) {
				$acciones[] = enlace('?r=' . ITEMS_EDITAR . $id, 'Editar', "Editar los datos del item");
			}
			if (tienePermiso(ID_ROL_ITEMS, 'eliminar')) {
				$acciones[] = enlace('?r=' . ITEMS_ELIMINAR . $id, 'Eliminar', "Eliminar el item");
			}		
			
                        $acciones[] = enlace('?r=' . DETALLE_NUEVO . $id, 'Agregar Detalle', "Agregar Detalle");
			                        
			$html .= "<tr>\n"
			. "<td>{$reg['numitem']}</td>"
                        . "<td>{$reg['descripcion']}</td>"
			. "<td>{$reg['unidad']}</td>"
			. "<td align=\"right\">{$reg['precio_unit']}</td>"
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
 * @param int $id identificador de item
 */
function listarDetalleItems( $id ) {
	global $BD;
	$BD->query("SELECT * FROM con_detalle_item WHERE iditem = $id ORDER BY tipo ");
        
	$html = "<div id=\"div_lista_items\">\n<h1>Detalle</h1>\n";
        
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>TIPO</th>\n"
                        . "<th>DESCRIPCI&Oacute;N</th>\n"
			. "<th>UNIDAD</th>\n"
			. "<th>REND</th>\n"
			. "<th>P.U.</th>\n"
                        . "<th>TOTAL</th>\n"
                        . "<th>Acciones</th>\n"
			. "</tr>\n";
                $total = 0;
		while ($reg = $BD->getNext()) {
			$id = $reg['iditem'];
			$acciones = array();                       
			
			if (tienePermiso(ID_ROL_ITEMS, 'modificar')) {
				$acciones[] = enlace('?r=' . DETALLE_EDITAR . $reg['id_detalle'] . '/'. $id, 'Editar', "Editar los datos del registro");
			}
			if (tienePermiso(ID_ROL_ITEMS, 'eliminar')) {
				$acciones[] = enlace('?r=' . DETALLE_ELIMINAR . $reg['id_detalle'] . '/'. $id , 'Eliminar', "Eliminar registro");
			}
			                        
			$html .= "<tr>\n"
			. "<td><b>{$reg['tipo']}</b></td>"
                        . "<td>{$reg['descripcion']}</td>"
			. "<td>{$reg['unidad']}</td>"
			. "<td>{$reg['rend']}</td>"
                        . "<td>{$reg['pu']}</td>"
                        . "<td>{$reg['total']}</td>"
			. "<td>" . implode('|', $acciones)
			. "</td>"
			. "</tr>\n";
                        $total += $reg['total'];
		}
                $html .= "<tr>
                            <th>TOTAL</th>
                            <th colspan=\"4\"></th>
                            <th><strong>{$total}</strong></th>
                            <th></th>
                         </tr>";
		$html .= "</table>";
	} else {
		$html .= mensajeNoExistenRegistros();
	}
	$html .= "</div>";
	return $html;
}

/**
 * Muestra los datos de un item y de su detalle
 * @param int $id llave de item
 */
function mostrarItem( $id ) {
	global $BD;
	$BD->query("SELECT * FROM con_item where (item_id = $id)");
	$reg = $BD->getNext();
	
        $link_ret = enlace('?r=' . ITEMS_LISTAR, 'Regresar', 'Regresar al listado de items');
	$link_ret .= enlace('?r=' . DETALLE_NUEVO . $id, 'Agregar Detalle', 'Lorem');
        
        $precio_unit = number_format($reg['precio_unit'], 2, '.', '');

        $detalle= listarDetalleItems( $id );
        
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de items</h1>\n
			<table class="tbl_formulario">
			    <tr>
			        <td><label class="etiqueta">Num. Item:</label></td>
			        <td>{$reg['numitem']}</td>
			    </tr>                                 
			    <tr>
			        <td><label class="etiqueta">Descripci&oacute;n:</label></td>
			        <td>{$reg['descripcion']}</td>
			    </tr>               
			    <tr>
			        <td><label class="etiqueta">Unidad:</label></td>
			        <td>{$reg['unidad']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Precio unitario:</label></td>
			        <td>$precio_unit</td>
			    </tr>
			</table>
                        
                        {$detalle}                                  
		</div>
		<div class="div_normal">$link_ret</div>
MOSTREG;
	return $html;
}

function editarItem($id) {
	global $BD;
	global $PARAMETROS;
	
	if (!isset($PARAMETROS['id_reg'])) {
		return formEdItems($id);
	} else {
		if (!existenErroresItems($PARAMETROS)) {
			return guardarItems($PARAMETROS);
		} else {
			return formEdItems($id, true);
		}
	}
}

/**
 * @param int $id identificador unico de registro
 * @param int $iditem identificador de item
 */
function editarDetalle( $id , $iditem ) {
	global $BD;
	global $PARAMETROS;	
        
	if ( !isset( $PARAMETROS['id_reg'] ) ) { //muestra formulario 
		return formEdDetalle( $id , $iditem );
	} else { //existen parametros
		if ( !existenErroresDetalle( $PARAMETROS ) ) { //si no existen errores -> registra
			return guardarDetalle( $PARAMETROS );
		} else {
			return formEdDetalle($id, $iditem, true);
		}
	}
}

/**
 * Muestra formulario HTML para la edicion y/o creacion de nuevos registros en DETALLE
 * @param int $id identificador unico de ITEM
 * @param boolean $errores 
 */
function formEdDetalle( $id, $iditem, $errores = false) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
        
	if ( !$errores ) {
		$BD->query("SELECT * FROM con_detalle_item WHERE (id_detalle = $id)");
		$reg = $BD->getNext();
		
                $rend = number_format($reg['rend'], 2, '.', '');
                $pu = number_format($reg['pu'], 2, '.', '');
                $total = number_format($reg['total'], 2, '.', '');
	} else {
		$reg = array();
		
		$reg['descripcion'] = $PARAMETROS['descripcion'];
		$reg['tipo'] = $PARAMETROS['tipo'];
		$reg['unidad'] = $PARAMETROS['unidad'];
                $reg['rend'] = $PARAMETROS['rend'];
                $reg['pu'] = $PARAMETROS['pu'];
                $reg['total'] = $PARAMETROS['total'];                
		
                $rend = $reg['rend'];
                $pu = $reg['pu'];
                $total = $reg['total'];
	}
	
        $link_ret = "<a href=\"?r=".ITEMS_LISTAR ."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
        
	$lint_ed = DETALLE_EDITAR;
        
        //
        $xop1 = ( $reg['tipo'] == 'MATERIALES')?'selected':'';
        $xop2 = ( $reg['tipo'] == 'MANO DE OBRA')?'selected':'';
        $xop3 = ( $reg['tipo'] == 'HERRAMIENTAS Y EQUIPO')?'selected':'';
        
        
        $op1 = ($reg['unidad']=='m')?'selected':'';
        $op2 = ($reg['unidad']=='m2')?'selected':'';
        $op3 = ($reg['unidad']=='m3')?'selected':'';
        $op4 = ($reg['unidad']=='glb')?'selected':'';
        $op5 = ($reg['unidad']=='pza')?'selected':'';
        $op6 = ($reg['unidad']=='ml')?'selected':'';
        $op7 = ($reg['unidad']=='ha')?'selected':'';
        $op8 = ($reg['unidad']=='juego')?'selected':'';
        $op9 = ($reg['unidad']=='kg')?'selected':'';
        $op10 = ($reg['unidad']=='l')?'selected':'';
        $op11 = ($reg['unidad']=='pto')?'selected':'';
        $op12 = ($reg['unidad']=='tubo')?'selected':'';
        $op13 = ($reg['unidad']=='%')?'selected':'';
        
        $detalle = listarDetalleItems( $iditem );
        
        
	$BD->query("SELECT * FROM con_item where (item_id = $iditem)");
	$reg5 = $BD->getNext();
        $itemdesc = $reg5['descripcion'];
        $itemprecio = $reg5['precio_unit'];
        
        $js .= "<script type=\"text/javascript\" src=\"modulos/items/items.js\"></script>\n";
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
                         {$js}
			<h1>Registro detalles</h1>\n
			<form method="post" action="?r={$lint_ed}$id/$iditem" name="form_edt_items">
			<input type="hidden" value="$id" name="id_reg">                        
                        <input type="hidden" value="$iditem" name="id_item">                        
                            
			<table class="tbl_formulario" border="0">                                                                                 
                            <tr>
			        <td><label class="etiqueta" for="descripcion">Descripci&oacute;n:</label></td>
			        <td colspan="3"><input type="text" name="descripcion" value="{$reg['descripcion']}" 
			        	maxlength="200" size="80" class="edt_form"/></td>
			    </tr>
                                
			    <tr>
			        <td><label class="etiqueta" for="tipo">Tipo:</label></td>
			        <td><select name="tipo" class="edt_form">
                                        <option value="MATERIALES" {$xop1}>MATERIALES</option>
                                        <option value="MANO DE OBRA" {$xop2}>MANO DE OBRA</option>
                                        <option value="HERRAMIENTAS Y EQUIPO" {$xop3}>HERRAMIENTAS Y EQUIPO</option>
                                </select></td>
			        <td><label class="etiqueta" for="unidad">Unidad:</label></td>
			        <td><select name="unidad" id="unidad">
                                    <option value="m" {$op1}>metro</option>
                                    <option value="m2" {$op2}>metro 2</option>
                                    <option value="m3" {$op3}>metro 3</option>
                                    <option value="glb" {$op4}>glb</option>
                                    <option value="pza" {$op5}>Pieza</option>
                                    <option value="ml" {$op6}>ml</option>
                                    <option value="ha" {$op7}>hectarea</option>
                                    <option value="juego" {$op8}>Juego</option>
                                    <option value="kg" {$op9}>KiloGramo</option>
                                    <option value="l" {$op10}>litro</option>
                                    <option value="pto" {$op11}>Punto</option>
                                    <option value="tubo" {$op12}>Tubo</option>
                                    <option value="%" {$op13}>%</option>
                                </select></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="rend">REND:</label></td>
			        <td><input type="text" name="rend" id="rend" value="{$rend}" 
			        	maxlength="5" size="5" class="edt_form"/></td>
			        <td><label class="etiqueta" for="pu">P.U.:</label></td>
			        <td><input type="text" name="pu" id="pu" value="{$pu}" 
			        	maxlength="10" size="8" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="total">Total:</label></td>
			        <td><input type="text" name="total" id="total" value="{$total}" 
			        	maxlength="5" size="5" class="no_edt_form" /></td>
			        <td></td>
			        <td></td>
			    </tr>                                
                                        
			    <tr>
			    	<td colspan="4" align="center"><div class="separador"></div></td>
			    </tr>
                            <tr>
                                <td colspan="4" align="center" >
                                        <table border="0" class="tbl_formulario">
                                        <tr>
                                          <td><label class="etiqueta" for="item">Item:</label></td>
                                          <td>{$itemdesc}</td>
                                          <td><label class="etiqueta" for="precio">Precio:</label></td>
                                          <td>{$itemprecio}</td>
                                        </tr>
                                      </table>
                                </td>                                
                            </tr>                                    
                            <tr>
                                <td colspan="4" align="center">$detalle</td>                                
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


/**
 * @param $id
 * @param boolean $errores
 */
function formEdItems($id, $errores = false) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
	
	if (!$errores) {
		$BD->query("SELECT * FROM con_item where (item_id = $id)");
		$reg = $BD->getNext();
		$precio_unit = number_format($reg['precio_unit'], 2, '.', '');
	} else {
		$reg = array();
		
		$reg['descripcion'] = $PARAMETROS['descripcion'];
		$reg['unidad'] = $PARAMETROS['unidad'];
		$reg['precio_unit'] = $PARAMETROS['precio_unit'];
		$precio_unit = $reg['precio_unit'];
	}
	//$link_ret = enlace('?r=' . ITEMS_LISTAR, 'Cancelar', 'Regresar al listado de items', 'enlace_boton');
	$link_ret = "<a href=\"?r=".ITEMS_LISTAR ."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
        
        $lint_ed = ITEMS_EDITAR;
        
        
        $op1 = ($reg['unidad']=='m')?'selected':'';
        $op2 = ($reg['unidad']=='m2')?'selected':'';
        $op3 = ($reg['unidad']=='m3')?'selected':'';
        $op4 = ($reg['unidad']=='glb')?'selected':'';
        $op5 = ($reg['unidad']=='pza')?'selected':'';
        $op6 = ($reg['unidad']=='ml')?'selected':'';
        $op7 = ($reg['unidad']=='ha')?'selected':'';
        $op8 = ($reg['unidad']=='juego')?'selected':'';
        $op9 = ($reg['unidad']=='kg')?'selected':'';
        $op10 = ($reg['unidad']=='l')?'selected':'';
        $op11 = ($reg['unidad']=='pto')?'selected':'';
        $op12 = ($reg['unidad']=='tubo')?'selected':'';
                       
        
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de items</h1>\n
			<form method="post" action="?r={$lint_ed}$id" name="form_edt_items">
			<input type="hidden" value="$id" name="id_reg">
                        <div class="conv_1">  
			<table class="tbl_formulario" border="0">
                            <tr>
			        <td><label class="etiqueta" for="numitem">Num. Item</label></td>
			        <td colspan="3"><input type="text" name="numitem" value="{$reg['numitem']}" 
			        	maxlength="200" size="30" class="edt_form"/></td>
			    </tr>                                                                
                            <tr>
			        <td><label class="etiqueta" for="descripcion">Descripci&oacute;n:</label></td>
			        <td colspan="3"><input type="text" name="descripcion" value="{$reg['descripcion']}" 
			        	maxlength="200" size="80" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="unidad">Unidad:</label></td>
			        <td><select name="unidad">
                                    <option value="m" {$op1}>metro</option>
                                    <option value="m2" {$op2}>metro 2</option>
                                    <option value="m3" {$op3}>metro 3</option>
                                    <option value="glb" {$op4}>glb</option>
                                    <option value="pza" {$op5}>Pieza</option>
                                    <option value="ml" {$op6}>ml</option>
                                    <option value="ha" {$op7}>hectarea</option>
                                    <option value="juego" {$op8}>Juego</option>
                                    <option value="kg" {$op9}>KiloGramo</option>
                                    <option value="l" {$op10}>litro</option>
                                    <option value="pto" {$op11}>Punto</option>
                                    <option value="tubo" {$op12}>Tubo</option>
                                </select></td>
			        <td><label class="etiqueta" for="precio_unit">Precio unitario:</label></td>
			        <td><input type="text" name="precio_unit" value="$precio_unit" 
			        	maxlength="10" size="8" class="edt_form"/></td>
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
                         </div>
			</form>
		</div>
MOSTREG;
	return $html;
}

/**
 * @param $form
 */
function existenErroresDetalle( $form ){
    $result = false;
    if (trim($form['descripcion']) == '') {
        registrarError('Debe ingresar la descripci&oacute;n.');
	$result = true;
    }
    if (trim($form['unidad']) == '') {
        registrarError('Debe ingresar la unidad.');
	$result = true;
    }    
    
    return $result;
}

function existenErroresItems( $form ) {
	$result = false;
	if (trim($form['descripcion']) == '') {
		registrarError('Debe ingresar la descripci&oacute;n.');
		$result = true;
	}
	if (trim($form['unidad']) == '') {
		registrarError('Debe ingresar la unidad.');
		$result = true;
	}
	if (!is_numeric($form['precio_unit'])) {
		registrarError('El precio unitario debe ser un valor num&eacute;rico.');
		$result = true;
	}
	return $result;
}


/**
 * @param array $form
 */
function guardarDetalle( $form ){
    global $BD;
    global $USR;                
    
    //obtiene total de item
    $BD->query("SELECT precio_unit FROM con_item WHERE (item_id = {$form['id_item']} )");
    $reg = $BD->getNext();
    $precio_unit = $reg['precio_unit'];
               
    if ( (trim($form['id_reg']) != '') && (trim($form['id_reg']) != '0') ) { //actualiza registro
                //obtiene total de detalle menos el detalle que se esta actualizando
                $BD->query("SELECT SUM(total) AS tdetalle FROM con_detalle_item WHERE (iditem = {$form['id_item']} AND id_detalle<>{$form['id_reg']} )");
                $reg = $BD->getNext();
	        $tdetalle = $reg['tdetalle'];
                if( ( $tdetalle + $form['total'] )>$precio_unit ){//no se puede actualizar
                   registrarError("No se puede actualizar, el precio total de DETALLE no puede ser mayor al Precio Unitario de ITEM");
                   $ok=false;
                }else{
                    $cons = "UPDATE con_detalle_item "
                    . "SET "
                    . "descripcion = '{$form['descripcion']}', "
                    . "tipo = '{$form['tipo']}', "
                    . "unidad = '{$form['unidad']}', "
                    . "rend = '{$form['rend']}', "
                    . "pu = '{$form['pu']}', "
                    . "total = '{$form['total']}' "
                    . "WHERE (id_detalle = {$form['id_reg']})";    
                    $ok = $BD->query($cons);
                    registrarLog($USR['id'], 'items', 'item', "Se ha modificado un item "
			. "[ID: {$form['id_reg']}, Desc: {$form['descripcion']}, Unidad: {$form['unidad']}, Precio: {$form['total']}]");
                }
	} else { //inserta nuevo registro               
               //obtiene total de detalle
               $BD->query("SELECT SUM(total) AS tdetalle FROM con_detalle_item WHERE (iditem = {$form['id_item']} )");
	       $reg = $BD->getNext();
	       $tdetalle = $reg['tdetalle'];
               
               if( ($tdetalle + $form['total'] ) > $precio_unit ) { //error no se puede registrar
                   registrarError("No se puede continuar, el precio total de DETALLE no puede ser mayor al Precio Unitario de ITEM");
                   $ok=false;
               }else{
    		   $cons = "INSERT INTO con_detalle_item (iditem, descripcion, tipo, unidad, rend, pu, total ) "
		   . "values ( '{$form['id_item']}' , '{$form['descripcion']}', '{$form['tipo']}', '{$form['unidad']}', '{$form['rend']}', '{$form['pu']}', '{$form['total']}' )";                   
                   $ok = $BD->query($cons);
                   registrarLog($USR['id'], 'items', 'item', "Se ha registrado un nuevo registro detalle a item "
		  	. "[ID: (Nuevo), Desc: {$form['descripcion']}, Unidad: {$form['unidad']}, Precio: {$form['total']}]");
               }
	}
        
        if ( $ok ) {
		registrarMensaje('Se ha guardado el registro correctamente.');
	} else {
		registrarError("No se ha podido guardar el registro. <br />{$BD->error}");
	}      
        
        
        $id_item= $form['id_item'];
        return '@' . ITEMS_MOSTRAR . $id_item;        
}

/**
 * 
 */
function guardarItems( $form ) {
	global $BD;
	global $USR;
	if ((trim($form['id_reg']) != '') && (trim($form['id_reg']) != '0')) {
		$cons = "update con_item "
		. "set "
                . "numitem = '{$form['numitem']}', "                        
		. "descripcion = '{$form['descripcion']}', "
		. "unidad = '{$form['unidad']}', "
		. "precio_unit = '{$form['precio_unit']}' "
		. "where (item_id = {$form['id_reg']})";
		registrarLog($USR['id'], 'items', 'item', "Se ha modificado un item "
			. "[ID: {$form['id_reg']}, Desc: {$form['descripcion']}, Unidad: {$form['unidad']}, Precio: {$form['precio_unit']}]");
	} else {
		$cons = "insert into con_item (numitem,descripcion, unidad, precio_unit) "
		. "values ( '{$form['numitem']}' , '{$form['descripcion']}', '{$form['unidad']}', '{$form['precio_unit']}')";
		registrarLog($USR['id'], 'items', 'item', "Se ha registrado un item "
			. "[ID: (Nuevo), Desc: {$form['descripcion']}, Unidad: {$form['unidad']}, Precio: {$form['precio_unit']}]");
	}
	if ($BD->query($cons)) {
		registrarMensaje('Se ha guardado el item correctamente.');
	} else {
		registrarError("No se ha podido guardar el item. <br />{$BD->error}");
	}
	return '@' . ITEMS_LISTAR;
}


/**
 * @param int $id identificador de detalle
 */
function eliminarDetalleItem( $id_detalle, $id_item ){
    	global $BD;
	global $PARAMETROS;

        //enlace para retornar a registro item
        //$link_ret = enlace('?r=' . ITEMS_MOSTRAR . $id_item , 'Cancelar', 'Regresar');
        $link_ret = "<a href=\"?r=".ITEMS_MOSTRAR . $id_item."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
        
        //formulario para eliminar registro
	$link_elim = DETALLE_ELIMINAR;
        
	$form = <<<FORMELIMFORM
                <div class="conv_1">  
                    <form method="post" action="?r=$link_elim$id_detalle/$id_item" name="form_elim_item">
                    <input type="hidden" value="$id_detalle" name="id_reg">                              
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
        
            if ( !isset($PARAMETROS['id_reg']) ) { //muestra confirmacion
                    return $form;
            } else { // elimina registro
                    global $BD;
                    global $USR;
                    //$BD->query("SELECT * FROM con_item where item_id = $id");
                    //$reg = $BD->getNext();
                    $cons = "DELETE FROM con_detalle_item WHERE (id_detalle = $id_detalle)";
                    $BD->query($cons);
                    //registra en bitacora item eliminado
                    //registrarLog($USR['id'], 'items', 'item', "Se ha eliminado un registro "
                    //        . "[ID: $id, Desc: {$reg['descripcion']}, Unidad: {$reg['unidad']}, Precio: {$reg['precio_unit']}]");
                    return '@' . ITEMS_MOSTRAR . $id_item;
            }
        
        
        
}

/**
 * Elimina un item
 * @param $id identificador unico de item
 */
function eliminarItem( $id ) {
	global $BD;
	global $PARAMETROS;
	
	//$link_ret = enlace('?r=' . ITEMS_MOSTRAR.$id , 'Cancelar', 'Regresar al listado de items');
        $link_ret = "<a href=\"?r=".ITEMS_MOSTRAR.$id ."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
        
        //comprobar que item no tenga relacion en tabla item_modulo
        $BD->query("SELECT count(*) AS total FROM con_item_modulo WHERE item = $id ");
        $reg = $BD->getNext();        
        
        if( $reg['total'] > 0 ) // el item cuenta con registros relacionados y no puede eliminados
        {
            $form = <<<FORM_ALERT
                <div class='div_alert' >El registro no puede ser eliminado <br/>
                    actualmente este ITEM esta siendo usado en [{$reg['total']}] modulo(s). </div>
                <div class="div_normal">$link_ret</div>
FORM_ALERT;
            return $form;
        }
        else // puede ser elimiando
        {
        //formulario para eliminar items
	$link_elim = ITEMS_ELIMINAR;
	$form = <<<FORMELIMFORM
		<div class="conv_1">  
                <form method="post" action="?r=$link_elim$id" name="form_elim_item">
                <input type="hidden" value="$id" name="id_reg">		
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
                    $BD->query("select * from con_item where item_id = $id");
                    $reg = $BD->getNext();
                    //instrucion para eliminar registro ITEM
                    $cons = "DELETE FROM con_item WHERE (item_id = $id)";
                    $BD->query($cons);
                    //instrucion para eliminar registros relacionados con ITEM
                    $cons = "DELETE FROM con_detalle_item WHERE (iditem = $id)";
                    $BD->query($cons);
                    
                    registrarMensaje("Se ha eliminado el ITEM correctamente.");
                    //registra en bitacora item eliminado
                    registrarLog($USR['id'], 'items', 'item', "Se ha eliminado un item "
                            . "[ID: $id, Desc: {$reg['descripcion']}, Unidad: {$reg['unidad']}, Precio: {$reg['precio_unit']}]");
                    return '@' . ITEMS_LISTAR;
            }
        }
        
}
