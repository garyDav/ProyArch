<?php
define ('CMETRICOS_OBRA', 'cmetricos/obras');
define ('CMETRICOS_MODULOS', 'cmetricos/modulos/');
define ('CMETRICOS_ITEMS', 'cmetricos/items/');
define ('CMETRICOS_MOSTRAR', 'cmetricos/mostrar/');
define ('CMETRICOS_AGREGAR', 'cmetricos/agregar/');
define ('CMETRICOS_EDITAR', 'cmetricos/editar/');
define ('CMETRICOS_ELIMINAR', 'cmetricos/eliminar/');

define ('CMETRICOS_NUEVOITEM', 'cmetricos/nuevo-item/');

define ('MOD_IMP_CMETRICOS_HTML', 'clean/cmetricos/imprimir_html/');


function iniciarModulo_cmetricos() {
	global $PARAMETROS;
                       
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'obras') {		
            return seleccionarObra();
	} else {
		$id_obra = parametros(3);
		if ($PARAMETROS['accion'] == 'modulos') {
			return listarModulos( $id_obra );
		} elseif ($PARAMETROS['accion'] == 'items') {
		       $id_modulo = parametros(4);
                        return listarItemsModulo( $id_obra , $id_modulo );
                } elseif ($PARAMETROS['accion'] == 'mostrar') {
                        $id_itemmodulo = parametros(4);
			return listarCMetricos( $id_obra , $id_itemmodulo );
		} elseif ($PARAMETROS['accion'] == 'agregar') {                        
                        $id_itemmodulo = parametros(4);
			return editarCmetricos( $id_obra, $id_itemmodulo, "0" );
		} elseif ($PARAMETROS['accion'] == 'editar') {
			$id_itemmodulo = parametros(4);
                        $id_cm = parametros(5); // computo metrico ID
			return editarCmetricos( $id_obra, $id_itemmodulo, $id_cm );
		} elseif ($PARAMETROS['accion'] == 'eliminar') {
			$id_itemmodulo = parametros(4);
                        $id_cm = parametros(5); // computo metrico ID
			return eliminarCMetricos( $id_obra, $id_itemmodulo, $id_cm );
                } elseif ($PARAMETROS['accion'] == 'nuevo-item') {
                    $idmodulo = parametros(4);
                    return nuevoItemsFPresupuesto( $id_obra, $idmodulo );
                }elseif ($PARAMETROS['accion'] == 'imprimir_html') {
                        return cmetricosHTML( $id_obra );
                }
	}
}





/**
 * LISTADO DE OBRAS
 */
function seleccionarObra() {
	global $BD;
	$BD->query("SELECT id_obra, nombre, tipo_proy "
		. " FROM con_obras "
		. " ORDER BY tipo_proy, nombre");
	$html = "<div id=\"div_sele_obra_act\">\n<h1>Computos metricos - Seleccionar obra</h1>\n";
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
			//if (tienePermiso(ID_ROL_SEGUI, 'ver')) { //PERMISOS
				$acciones[] = enlace('?r=' . CMETRICOS_MODULOS . $id, 'Seleccionar', "Ver las MODULOS de la obra: {$reg['nombre']}");
                                $acciones[] = enlace('?r=' . MOD_IMP_CMETRICOS_HTML . $id, 'HTML', 
				"Informe Computos Metricos", "", "_BLANK");
			//}
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
 * LITADO DE MODULOS DE UNA OBRA
 * @param int $pIDObra identificador único de obra
 */
function listarModulos($pIDObra) {
	global $BD;
        //obtiene datos de obra
	$BD->query("SELECT id_obra, nombre, tipo_proy "
		. " FROM con_obras "
		. " WHERE (id_obra = $pIDObra)");
	$reg = $BD->getNext();
	$nombreObra = $reg['nombre'];
	$tipoProy = $reg['tipo_proy'];
	$html = "<div id=\"div_datos_obra\">\n"
		. "<p><label class=\"etiqueta\">Nombre de la obra:</label>$nombreObra</p>\n"
		. "<p><label class=\"etiqueta\">Tipo de proyecto:</label>$tipoProy</p>\n"
		. "</div>";
	
	$BD->query("SELECT * "		
		. "FROM con_modulo "
		. "WHERE (obra = $pIDObra)");
	$html .= "<div id=\"div_lista_actividades\">\n<h1>Computos metricos - Listado de Modulos</h1>\n";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			  . "<th>DESCRIPCION</th>\n"			  
			  . "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_modulo'];
			$acciones = array();
			if (tienePermiso(ID_ROL_SEGUI, 'ver')) {
				//$acciones[] = enlace('?r=' . SEGUI_MOSTRAR . "$pIDObra/$id", 'Ver seguimiento', "Ver el seguimiento de la actividad");
			}
			//if (tienePermiso(ID_ROL_SEGUI, 'modificar')) {
				$acciones[] = enlace('?r=' . CMETRICOS_ITEMS . "$pIDObra/$id", 'Ver Items', "Ver Items");
			//}
			$html .= "<tr>\n"
			. "<td>{$reg['descripcion']}</td>"			
			. "<td align=\"center\">" . implode('|', $acciones)
			. "</td>"
			. "</tr>\n";
		}
		$html .= "</table>";
		
                //--------------------------------------------------------
                $BD->query("SELECT id_modulo  FROM con_modulo "
		           . "WHERE (obra = $pIDObra) AND (descripcion='Fuera de Presupuesto') ");
                if ( $BD->numRows() > 0) {
                    $reg = $BD->getNext();
                    $idmodulo =$reg['id_modulo'];                    
                }else{
                    $idmodulo = 0;                    
                }
                
                //--------------------------------------------------------
                //
                //if (tienePermiso(ID_ROL_SEGUI, 'ver')) {
			$link_estado_obra = enlace('?r=' . CMETRICOS_NUEVOITEM . $pIDObra .'/'. $idmodulo , 
				'Nuevo Items fuera de presupuesto', 
				'Ver el estado del seguimiento al avance f&iacute;sico y financiero de la obra',
				'', '');
			$link_estado_obra_html = enlace('?r=' . CMETRICOS_OBRA , 
				'Volver', 'Volver listado',
				'', '');
		//} 
		$html .= "<div class=\"div_normal\"><p>$link_estado_obra | $link_estado_obra_html</p></div>";
                $html .= "<div class=\"infonota\">(*)Si se quiere a&ntilde;adir item(s) que este fuera de presupuesto, este se agregara a un nuevo modulo llamado &quot;Fuera de Presupuesto&quot;</div>";
                
	} else {
		$html .= mensajeNoExistenRegistros();
	};
	$html .= "</div>";
	return $html;
}


/**
 * LITADO DE ITEMS DE UN MODULO
 * @param int $pIDObra identificador único de obra
 * @param int $IDModulo identificador único de MODULO 
 */
function listarItemsModulo( $pIDObra, $IDModulo ) {
	global $BD;
        //obtiene datos de obra y modulo
	$BD->query(" SELECT id_obra, nombre, tipo_proy, descripcion "
		. " FROM con_obras INNER JOIN con_modulo ON obra=id_obra "
		. " WHERE (id_obra = $pIDObra AND id_modulo=$IDModulo )");
	$reg = $BD->getNext();
	$nombreObra = $reg['nombre'];
	$tipoProy = $reg['tipo_proy'];
        $descModulo = $reg['descripcion'];
	$html = "<div id=\"div_datos_obra\">\n"
		. "<p><label class=\"etiqueta\">Nombre de la obra:</label>$nombreObra</p>\n"
		. "<p><label class=\"etiqueta\">Tipo de proyecto:</label>$tipoProy</p>\n"
                . "<p><label class=\"etiqueta\">Modulo:</label>$descModulo</p>\n"
		. "</div>";
        
	//obtiene listado de items que pertences a modulo
	$BD->query("SELECT * "		
		. "FROM con_item_modulo INNER JOIN con_item ON item_id=item "
		. "WHERE (modulo = $IDModulo )");
	$html .= "<div id=\"div_lista_actividades\">\n<h1>Listado de Items</h1>\n";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			  . "<th>DESCRIPCION</th>\n"			  
			  . "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_it_mod'];
			$acciones = array();
			if (tienePermiso(ID_ROL_SEGUI, 'ver')) {
				//$acciones[] = enlace('?r=' . SEGUI_MOSTRAR . "$pIDObra/$id", 'Ver seguimiento', "Ver el seguimiento de la actividad");
			}
			//if (tienePermiso(ID_ROL_SEGUI, 'modificar')) {
				$acciones[] = enlace('?r=' . CMETRICOS_MOSTRAR . "$pIDObra/$id", 'Ver Computo Metrico', "Computos Metricos");
			//}
			$html .= "<tr>\n"
			. "<td>{$reg['descripcion']}</td>"			
			. "<td align=\"center\">" . implode('|', $acciones)
			. "</td>"
			. "</tr>\n";
		}
		$html .= "</table>";
		
                
              $volver = enlace('?r=' . CMETRICOS_MODULOS . $pIDObra, 
				'Volver', 'Volver al listado de modulos','', '');
		
		$html .= "<div class=\"div_normal\"><p>$volver</p></div>";
                
	} else {
		$html .= mensajeNoExistenRegistros();
	};
	$html .= "</div>";
	return $html;
}

/**
 * LITADO DE COMPUTOS METRICOS
 * @param int $pIDObra identificador único de obra
 * @param int $IDItemModulo identificador único de tabla ITEM_MODULO 
 */
function listarCMetricos( $pIDObra, $IDItemModulo ) {
	global $BD;
        //obtiene datos de obra y modulo
	$BD->query(" SELECT id_obra, nombre, tipo_proy, con_modulo.descripcion AS descmodulo, con_item.descripcion AS descItem, cantidad  "
		. " FROM con_obras INNER JOIN con_modulo ON obra=id_obra "
                . " INNER JOIN con_item_modulo ON id_modulo=modulo "
                . " INNER JOIN con_item ON item_id=item "
		. " WHERE (id_obra = $pIDObra AND id_it_mod=$IDItemModulo ) ");
	$reg = $BD->getNext();
	$nombreObra = $reg['nombre'];
	$tipoProy = $reg['tipo_proy'];
        $descModulo = $reg['descmodulo'];
        $descItem = $reg['descItem'];
        $cantidad = $reg['cantidad'];
	$html = "<div class=\"conv_1\">   \n"
		. "<p><label class=\"etiqueta\">Nombre de la obra:</label>$nombreObra</p>\n"
		. "<p><label class=\"etiqueta\">Tipo de proyecto:</label>$tipoProy</p>\n"
                . "<p><label class=\"etiqueta\">Modulo:</label>$descModulo</p>\n"
                . "<p><label class=\"etiqueta\">Item:</label>$descItem</p>\n"
                . "<p><label class=\"etiqueta\">Cantidad:</label>$cantidad</p>\n"
		. "</div>";
        
	//obtiene listado de items que pertences a modulo
	$BD->query("SELECT * "		
		. "FROM con_computo_metrico "
		. "WHERE (id_im = $IDItemModulo ) ORDER BY id_cm ASC");
	$html .= "<div id=\"div_lista_actividades\">\n<h1>Computos Metricos</h1>\n";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			  . "<th>DESCRIPCION</th>\n"
                          . "<th>UNIDAD</th>\n"
                          . "<th>Num. Veces</th>\n"
                          . "<th>EJE</th>\n"
                          . "<th>SECTOR</th>\n"
                          . "<th>LONGITUD</th>\n"
                          . "<th>ALTURA</th>\n"
                          . "<th>ANCHO</th>\n"
                          . "<th>PESO</th>\n"
                          . "<th>VOLUMEN</th>\n"
                          . "<th>PARCIAL</th>\n"                          
                          . "<th>ACUMULADO</th>\n"
			  . "<th>ACCIONES</th>\n"
			. "</tr>\n";
                $tacum=0;
		while ($reg = $BD->getNext()) {
			$id = $reg['id_cm'];
			$acciones = array();
			if (tienePermiso(ID_ROL_SEGUI, 'ver')) {
				//$acciones[] = enlace('?r=' . SEGUI_MOSTRAR . "$pIDObra/$id", 'Ver seguimiento', "Ver el seguimiento de la actividad");
			}
			//if (tienePermiso(ID_ROL_SEGUI, 'modificar')) {
				$acciones[] = enlace('?r=' . CMETRICOS_EDITAR . "$pIDObra/$IDItemModulo/$id", 'Editar', "Editar");
                                $acciones[] = enlace('?r=' . CMETRICOS_ELIMINAR . "$pIDObra/$IDItemModulo/$id"  , 'Eliminar', "Eliminar");
			//}
                        $tacumulado = $tacumulado +  $reg['parcial'];       
			$html .= "<tr>\n"
			. "<td>{$reg['descripcion']}</td>"			
                        . "<td>{$reg['unidad']}</td>"	
                        . "<td>{$reg['numveces']}</td>"	
                        . "<td>{$reg['eje']}</td>"	
                        . "<td>{$reg['sector']}</td>"	
                        . "<td>{$reg['longitud']}</td>"
                        . "<td>{$reg['altura']}</td>"
                        . "<td>{$reg['ancho']}</td>"
                        . "<td>{$reg['peso']}</td>"
                        . "<td>{$reg['volumen']}</td>"
                        . "<td>{$reg['parcial']}</td>"                        
                        . "<td>{$tacumulado}</td>"
			. "<td align=\"center\">" . implode('|', $acciones)
			. "</td>"
			. "</tr>\n";
		}
		$html .= "</table>";
		
                //if (tienePermiso(ID_ROL_SEGUI, 'ver')) {
			
		//}
		
                
	} else {
		$html .= mensajeNoExistenRegistros();
	};
        
        $link_estado_obra = enlace('?r=' . CMETRICOS_AGREGAR . $pIDObra ."/". $IDItemModulo, 
				'Agregar Computo Metrico', 'Agregar Computo Metrico','', '');			
        $html .= "<div class=\"div_normal\"><p>$link_estado_obra</p></div>";
        
	$html .= "</div>";
	return $html;
}

/**
 * @param int $idp Identificador de obra
 * @param int $idim Identificador ITEM_MODULO
 * @param int $id id computo metrico
 */
function editarCmetricos( $idp,$idim, $idcm ) {
	global $BD;
	global $PARAMETROS;
	
	if ( !isset($PARAMETROS['id_cm']) ) { //nuevo                         
            return formEdCMetricos( $idp,$idim , $idcm );
	} else {            		
                if ( !existenErroresCMetricos($PARAMETROS) ) {                        
                    return guardarCMetricos( $idp,$idim , $PARAMETROS );
		} else {
			return formEdCMetricos( $idp,$idim , $idcm, true);
		}
	}
}

/**
 * Detección de errores
 * @param array $form datos formulario
 */
function existenErroresCMetricos( $form ) {
    $result = false;
    /*if (trim($form['descripcion']) == '') {
		registrarError('Debe ingresar la descripci&oacute;n.');
		$result = true;
    }*/
    return $result;
}

/**
 * @param int $id identificador unico de proyecto
 * @param int $idim id item_modulo
 * @param Array $form Description
 */
function guardarCMetricos( $idp, $idim , $form ) {
	global $BD;
	global $USR;
        
        $form['altura'] = ( isset($form['altura']) )? $form['altura']:0;
        $form['ancho'] = ( isset($form['ancho']) )? $form['ancho']:0;
        $form['longitud'] = ( isset($form['longitud']) )? $form['longitud']:0;
        $form['sector'] = ( isset($form['sector']) )? $form['sector']:0;
        $form['eje'] = ( isset($form['eje']) )? $form['eje']:0;
        $form['peso'] = ( isset($form['peso']) )? $form['peso']:0;
        $form['volumen'] = ( isset($form['volumen']) )? $form['volumen']:0;
                
	if ((trim($form['id_cm']) != '') && (trim($form['id_cm']) != '0' )) { //actualizacion
            
                //------------------------------------------------->
		$cons = "UPDATE con_computo_metrico "
		. " SET "                                   
		. "descripcion = '{$form['descripcion']}', "
		. "unidad = '{$form['unidad']}', "
		. "numveces = '{$form['numveces']}', "
                . "eje = '{$form['eje']}', "
                . "sector = '{$form['sector']}', "
                . "longitud = '{$form['longitud']}', "
                . "altura = '{$form['altura']}', "
                . "ancho = '{$form['ancho']}', "
                . "peso = '{$form['peso']}', "
                . "volumen = '{$form['volumen']}', "
                . "parcial = '{$form['parcial']}' "
		. "WHERE (id_cm = {$form['id_cm']})";
		//registrarLog($USR['id'], 'items', 'item', "Se ha modificado un item "
		//	. "[ID: {$form['id_reg']}, Desc: {$form['descripcion']}, Unidad: {$form['unidad']}, Precio: {$form['precio_unit']}]");
	} else { //nuevo registro                                
                //guarda nuevo registro
		$cons = "INSERT INTO con_computo_metrico 
                        ( id_im ,descripcion, unidad, numveces, eje, sector, longitud, altura, ancho, parcial, peso, volumen  ) "
		. " VALUES ( '{$idim}' , '{$form['descripcion']}', '{$form['unidad']}', '{$form['numveces']}',
                    '{$form['eje']}','{$form['sector']}','{$form['longitud']}','{$form['altura']}','{$form['ancho']}', '{$form['parcial']}','{$form['peso']}','{$form['volumen']}'                        
                    )";
		//registrarLog($USR['id'], 'items', 'item', "Se ha registrado un item "
		//	. "[ID: (Nuevo), Desc: {$form['descripcion']}, Unidad: {$form['unidad']}, Precio: {$form['precio_unit']}]");
	}
	if ($BD->query($cons)) {
		registrarMensaje('Se ha guardado el computo metrico correctamente.');
	} else {
		registrarError("No se ha podido guardar el registro. <br />{$BD->error}");
	}
	return '@' . CMETRICOS_MOSTRAR . $idp.'/'.$idim ;
}


/**
 * Computo metrico FORMULARIO para creacion y edicion de registros
 * @param int $idp llave obra
 * @param int $idim llave tabla ITEM_MODULO
 * @param int $id llave computo metrico
 * @param boolean $errores TRUE|FALSE
 */
function formEdCMetricos( $idp,$idim , $id , $errores = false) {
	require_once( 'inc/conversiones.inc' );
	global $BD;
	global $PARAMETROS;
      
	//--------------------------------------------------------------------------------------
        //obtiene datos de obra y modulo
	$BD->query(" SELECT id_obra, nombre, tipo_proy, con_modulo.descripcion AS descmodulo, con_item.descripcion AS descItem, unidad, precio "
		. " FROM con_obras INNER JOIN con_modulo ON obra=id_obra "
                . " INNER JOIN con_item_modulo ON id_modulo=modulo "
                . " INNER JOIN con_item ON item_id=item "
		. " WHERE (id_obra = $idp AND id_it_mod=$idim )");
	$reg = $BD->getNext();
	$nombreObra = $reg['nombre'];
	$tipoProy = $reg['tipo_proy'];
        $descModulo = $reg['descmodulo'];
        $descItem = $reg['descItem'];
        $unidad = $reg['unidad'];
        $precio_unitario = $reg['precio'];
               
        
        //obtiene TOTAL_MEDIDA = suma de todos los parciales
        $BD->query("SELECT SUM(parcial) AS sump "		
		. "FROM con_computo_metrico "
		. "WHERE (id_im = $idim )");
        $reg2 = $BD->getNext();
        $total_medida = round( $reg2['sump'] , 2);
        
	$html = "<div id=\"div_datos_obra\">\n"
		. "<p><label class=\"etiqueta\">Nombre de la obra:</label>$nombreObra</p>\n"
		. "<p><label class=\"etiqueta\">Tipo de proyecto:</label>$tipoProy</p>\n"
                . "<p><label class=\"etiqueta\">Modulo:</label>$descModulo</p>\n"
                . "<p><label class=\"etiqueta\">Item:</label>$descItem</p>\n"
		. "</div>";
        //------------------------------------------------------------------------------------
	if (!$errores) { //consulta a la base de datos
		$BD->query("SELECT * FROM con_computo_metrico WHERE (id_cm = $id)");
		$reg = $BD->getNext();
		//$precio_unit = number_format($reg['precio_unit'], 2, '.', '');
	} else {
		$reg = array();
		//obtiene valor de form
		$reg['descripcion'] = $PARAMETROS['descripcion'];
		//$reg['unidad'] = $PARAMETROS['unidad'];
                $reg['numveces'] = $PARAMETROS['numveces'];
                $reg['eje'] = $PARAMETROS['eje'];
                $reg['longitud'] = $PARAMETROS['longitud'];
                $reg['altura'] = $PARAMETROS['altura'];
                $reg['ancho'] = $PARAMETROS['ancho'];
                $reg['peso'] = $PARAMETROS['peso'];
                $reg['volumen'] = $PARAMETROS['volumen'];
                $reg['parcial'] = $PARAMETROS['parcial'];
	}
        
	//$link_ret = enlace('?r=' . CMETRICOS_MOSTRAR . $idp.'/'.$idim  , 'Cancelar', 'Regresar al listado', 'enlace_boton');
        $link_ret = "<a href=\"?r=".CMETRICOS_MOSTRAR . $idp.'/'.$idim ."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
	$lint_ed = CMETRICOS_EDITAR;
 
        //form segun unidades -----------------------------------------------------
        if( $unidad == 'm' || $unidad == 'km' ){
            $script= "modulos/cmetricos/m.js";
            
            $tabla = <<<HTMLTABLA
   <div class="conv_1">                   
   <table>
  <tr>
    <td><label class="etiqueta" for="descripcion">Descripci&oacute;n : </label></td>
    <td colspan="5"><input type="text" value="{$reg['descripcion']}" name="descripcion" maxlength="200" size="90" class="edt_form" /></td>
  </tr>
  <tr>
    <td><label class="etiqueta" for="unidad">Unidad : </label></td>
    <td><input type="text" name="unidad" value="{$unidad}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="numveces">Num. Veces: </label></td>
    <td><input type="text" id="numveces" name="numveces" value="{$reg['numveces']}" maxlength="40" size="10" class="edt_form"  /></td>
    <td><label class="etiqueta" for="eje">Eje : </label></td>
    <td><input type="text" name="eje" value="{$reg['eje']}" maxlength="40" size="10" class="edt_form" /></td>
  </tr>
  <tr>
    <td><label class="etiqueta" for="sector">Sector : </label></td>
    <td><input type="text" name="sector" value="{$reg['sector']}" maxlength="40" size="10" class="edt_form" /></td>
    <td><label class="etiqueta" for="longitud">Longitud : </label></td>
    <td><input type="text" id="longitud" name="longitud" value="{$reg['longitud']}" maxlength="40" size="10" class="edt_form" /></td>
    <td><label class="etiqueta" for="parcial">Parcial : </label></td>
    <td><input type="text" id="parcial" name="parcial" value="{$reg['parcial']}" maxlength="40" size="10" class="auto_edt_form" /></td>
  </tr>
  <tr>
    <td><label class="etiqueta" for="precio_unitario">Precio Unitario : </label></td>
    <td><input type="text" name="precio_unitario" value="{$precio_unitario}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="longitud">Total Medida: </label></td>
    <td><input type="text" name="total_medida" value="{$total_medida}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input type="submit" value="Guardar" class="boton"></td>
    <td>&nbsp;</td>
    <td>$link_ret</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>    
    </div>
HTMLTABLA;
        }

if( $unidad == 'm2' || $unidad == 'ha' ){
    $script= "modulos/cmetricos/m2.js";
       $tabla = <<<HTMLTABLA
                   <div class="conv_1">
    <table>
  <tr>
    <td><label class="etiqueta" for="descripcion">Descripci&oacute;n : </label></td>
    <td colspan="5"><input type="text" value="{$reg['descripcion']}" name="descripcion" maxlength="200" size="90" class="edt_form" /></td>
  </tr>
  <tr>
    <td><label class="etiqueta" for="unidad">Unidad : </label></td>
    <td><input type="text" name="unidad" value="{$unidad}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="numveces">Num. Veces: </label></td>
    <td><input type="text" id="numveces" name="numveces" value="{$reg['numveces']}" maxlength="40" size="10" class="edt_form"  /></td>
    <td><label class="etiqueta" for="eje">Eje : </label></td>
    <td><input type="text" name="eje" value="{$reg['eje']}" maxlength="40" size="10" class="edt_form" /></td>
  </tr>
 <tr>    
    <td><label class="etiqueta" for="ancho">Ancho : </label></td>
    <td><input type="text" id="ancho" name="ancho" value="{$reg['ancho']}" maxlength="40" size="10" class="edt_form" /></td>
    <td><label class="etiqueta" for="alto">Alto : </label></td>
    <td><input type="text" id="altura" name="altura" value="{$reg['altura']}" maxlength="40" size="10" class="edt_form" /></td>
    <td></td>
    <td></td>
  </tr>      
  <tr>
    <td><label class="etiqueta" for="sector">Sector : </label></td>
    <td><input type="text" name="sector" value="{$reg['sector']}" maxlength="40" size="10" class="edt_form" /></td>    
    <td><label class="etiqueta" for="parcial">Parcial : </label></td>
    <td><input type="text" id="parcial" name="parcial" value="{$reg['parcial']}" maxlength="40" size="10" class="auto_edt_form" /></td>
    <td></td>
    <td></td>
  </tr>  
  <tr>
    <td><label class="etiqueta" for="precio_unitario">Precio Unitario : </label></td>
    <td><input type="text" name="precio_unitario" value="{$precio_unitario}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="longitud">Total Medida: </label></td>
    <td><input type="text" name="total_medida" value="{$total_medida}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input type="submit" value="Guardar" class="boton"></td>
    <td>&nbsp;</td>
    <td>$link_ret</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>  </div> 
HTMLTABLA;
}

if( $unidad == 'm3' ){
    $script= "modulos/cmetricos/m3.js";
    $tabla = <<<HTMLTABLA
    <div class="conv_1">
        <table>
  <tr>
    <td><label class="etiqueta" for="descripcion">Descripci&oacute;n : </label></td>
    <td colspan="5"><input type="text" value="{$reg['descripcion']}" name="descripcion" maxlength="200" size="90" class="edt_form" /></td>
  </tr>
  <tr>
    <td><label class="etiqueta" for="unidad">Unidad : </label></td>
    <td><input type="text" name="unidad" value="{$unidad}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="numveces">Num. Veces: </label></td>
    <td><input type="text" id="numveces" name="numveces" value="{$reg['numveces']}" maxlength="40" size="10" class="edt_form"  /></td>
    <td><label class="etiqueta" for="eje">Eje : </label></td>
    <td><input type="text" name="eje" value="{$reg['eje']}" maxlength="40" size="10" class="edt_form" /></td>
  </tr>
 <tr>
    <td><label class="etiqueta" for="longitud">Longitud : </label></td>
    <td><input type="text" id="longitud" name="longitud" value="{$reg['longitud']}" maxlength="40" size="10" class="edt_form" /></td>
    <td><label class="etiqueta" for="ancho">Ancho : </label></td>
    <td><input type="text" id="ancho" name="ancho" value="{$reg['ancho']}" maxlength="40" size="10" class="edt_form" /></td>
    <td><label class="etiqueta" for="alto">Alto : </label></td>
    <td><input type="text" id="altura" name="altura" value="{$reg['altura']}" maxlength="40" size="10" class="edt_form" /></td>
  </tr>      
  <tr>
    <td><label class="etiqueta" for="sector">Sector : </label></td>
    <td><input type="text" name="sector" value="{$reg['sector']}" maxlength="40" size="10" class="edt_form" /></td>
    <td></td>
    <td></td>
    <td><label class="etiqueta" for="parcial">Parcial : </label></td>
    <td><input type="text" id="parcial" name="parcial" value="{$reg['parcial']}" maxlength="40" size="10" class="auto_edt_form" /></td>
  </tr>  
  <tr>
    <td><label class="etiqueta" for="precio_unitario">Precio Unitario : </label></td>
    <td><input type="text" name="precio_unitario" value="{$precio_unitario}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="longitud">Total Medida: </label></td>
    <td><input type="text" name="total_medida" value="{$total_medida}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input type="submit" value="Guardar" class="boton"></td>
    <td>&nbsp;</td>
    <td>$link_ret</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>  </div> 
HTMLTABLA;
}        


if( $unidad == 'glb' ){ //global    
       $tabla = <<<HTMLTABLA
     <div class="conv_1">
         <table>
  <tr>
    <td><label class="etiqueta" for="descripcion">Descripci&oacute;n : </label></td>
    <td colspan="5"><input type="text" value="{$reg['descripcion']}" name="descripcion" maxlength="200" size="90" class="edt_form" /></td>
  </tr>
  <tr>
    <td><label class="etiqueta" for="unidad">Unidad : </label></td>
    <td><input type="text" name="unidad" value="{$unidad}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="numveces">Num. Veces: </label></td>
    <td><input type="text" id="numveces" name="numveces" value="{$reg['numveces']}" maxlength="40" size="10" class="edt_form"  /></td>
    <td><label class="etiqueta" for="eje">Eje : </label></td>
    <td><input type="text" name="eje" value="{$reg['eje']}" maxlength="40" size="10" class="edt_form" /></td>
  </tr> 
  <tr>
    <td><label class="etiqueta" for="sector">Sector : </label></td>
    <td><input type="text" name="sector" value="{$reg['sector']}" maxlength="40" size="10" class="edt_form" /></td>    
    <td><label class="etiqueta" for="parcial">Parcial : </label></td>
    <td><input type="text" id="parcial" name="parcial" value="1" maxlength="40" size="10" class="auto_edt_form" /></td>
    <td></td>
    <td></td>
  </tr>  
  <tr>
    <td><label class="etiqueta" for="precio_unitario">Precio Unitario : </label></td>
    <td><input type="text" name="precio_unitario" value="{$precio_unitario}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="longitud">Total Medida: </label></td>
    <td><input type="text" name="total_medida" value="{$total_medida}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input type="submit" value="Guardar" class="boton"></td>
    <td>&nbsp;</td>
    <td>$link_ret</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>  </div> 
HTMLTABLA;
}

if( $unidad == 'pza' || $unidad == 'juego' ){ //pieza   o juego
    $script= "modulos/cmetricos/pza.js";    
    $tabla = <<<HTMLTABLA
    <div class="conv_1">
        <table>
  <tr>
    <td><label class="etiqueta" for="descripcion">Descripci&oacute;n : </label></td>
    <td colspan="5"><input type="text" value="{$reg['descripcion']}" name="descripcion" maxlength="200" size="90" class="edt_form" /></td>
  </tr>
  <tr>
    <td><label class="etiqueta" for="unidad">Unidad : </label></td>
    <td><input type="text" name="unidad" value="{$unidad}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr> 
  <tr>
    <td><label class="etiqueta" for="numveces">Num. Veces: </label></td>
    <td><input type="text" id="numveces" name="numveces" value="{$reg['numveces']}" maxlength="40" size="10" class="edt_form"  /></td>    
    <td><label class="etiqueta" for="parcial">Parcial : </label></td>
    <td><input type="text" id="parcial" name="parcial" value="{$reg['parcial']}" maxlength="40" size="10" class="auto_edt_form" /></td>
    <td></td>
    <td></td>
  </tr>  
  <tr>
    <td><label class="etiqueta" for="precio_unitario">Precio Unitario : </label></td>
    <td><input type="text" name="precio_unitario" value="{$precio_unitario}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="longitud">Total Medida: </label></td>
    <td><input type="text" name="total_medida" value="{$total_medida}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input type="submit" value="Guardar" class="boton"></td>
    <td>&nbsp;</td>
    <td>$link_ret</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>  </div> 
HTMLTABLA;
}

if( $unidad == 'kg' ){ //kilogramo
    $script= "modulos/cmetricos/kg.js";    
       $tabla = <<<HTMLTABLA
  <div class="conv_1">
      <table>
  <tr>
    <td><label class="etiqueta" for="descripcion">Descripci&oacute;n : </label></td>
    <td colspan="5"><input type="text" value="{$reg['descripcion']}" name="descripcion" maxlength="200" size="90" class="edt_form" /></td>
  </tr>
  <tr>
    <td><label class="etiqueta" for="unidad">Unidad : </label></td>
    <td><input type="text" name="unidad" value="{$unidad}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="numveces">Num. Veces: </label></td>
    <td><input type="text" id="numveces" name="numveces" value="{$reg['numveces']}" maxlength="40" size="10" class="edt_form"  /></td>
    <td><label class="etiqueta" for="eje">Eje : </label></td>
    <td><input type="text" name="eje" value="{$reg['eje']}" maxlength="40" size="10" class="edt_form" /></td>
  </tr> 
  <tr>
    <td><label class="etiqueta" for="sector">Sector : </label></td>
    <td><input type="text" name="sector" value="{$reg['sector']}" maxlength="40" size="10" class="edt_form" /></td>    
    <td><label class="etiqueta" for="peso">Peso : </label></td>
    <td><input type="text" id="peso" name="peso" value="{$reg['peso']}" maxlength="40" size="10" class="edt_form" /></td>    
    <td><label class="etiqueta" for="parcial">Parcial : </label></td>
    <td><input type="text" id="parcial" name="parcial" value="{$reg['parcial']}" maxlength="40" size="10" class="auto_edt_form" /></td>    
  </tr>  
  <tr>
    <td><label class="etiqueta" for="precio_unitario">Precio Unitario : </label></td>
    <td><input type="text" name="precio_unitario" value="{$precio_unitario}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="longitud">Total Medida: </label></td>
    <td><input type="text" name="total_medida" value="{$total_medida}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input type="submit" value="Guardar" class="boton"></td>
    <td>&nbsp;</td>
    <td>$link_ret</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table> </div>  
HTMLTABLA;
}

if( $unidad == 'l' ){ //litro
    $script= "modulos/cmetricos/l.js";    
       $tabla = <<<HTMLTABLA
    <div class="conv_1">
        <table>
  <tr>
    <td><label class="etiqueta" for="descripcion">Descripci&oacute;n : </label></td>
    <td colspan="5"><input type="text" value="{$reg['descripcion']}" name="descripcion" maxlength="200" size="90" class="edt_form" /></td>
  </tr>
  <tr>
    <td><label class="etiqueta" for="unidad">Unidad : </label></td>
    <td><input type="text" name="unidad" value="{$unidad}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="numveces">Num. Veces: </label></td>
    <td><input type="text" id="numveces" name="numveces" value="{$reg['numveces']}" maxlength="40" size="10" class="edt_form"  /></td>
    <td><label class="etiqueta" for="eje">Eje : </label></td>
    <td><input type="text" name="eje" value="{$reg['eje']}" maxlength="40" size="10" class="edt_form" /></td>
  </tr> 
  <tr>
    <td><label class="etiqueta" for="sector">Sector : </label></td>
    <td><input type="text" name="sector" value="{$reg['sector']}" maxlength="40" size="10" class="edt_form" /></td>    
    <td><label class="etiqueta" for="volumen">Volumen : </label></td>
    <td><input type="text" id="volumen" name="volumen" value="{$reg['volumen']}" maxlength="40" size="10" class="edt_form" /></td>    
    <td><label class="etiqueta" for="parcial">Parcial : </label></td>
    <td><input type="text" id="parcial" name="parcial" value="{$reg['parcial']}" maxlength="40" size="10" class="auto_edt_form" /></td>    
  </tr>  
  <tr>
    <td><label class="etiqueta" for="precio_unitario">Precio Unitario : </label></td>
    <td><input type="text" name="precio_unitario" value="{$precio_unitario}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td><label class="etiqueta" for="longitud">Total Medida: </label></td>
    <td><input type="text" name="total_medida" value="{$total_medida}" maxlength="40" size="10" class="no_edt_form" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td><input type="submit" value="Guardar" class="boton"></td>
    <td>&nbsp;</td>
    <td>$link_ret</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>   </div>
HTMLTABLA;
}

$html .= "<script type=\"text/javascript\" src=\"$script\"></script>\n";
//form segun unidades -----------------------------------------------------end
        
	$html .= <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Computo Metrico</h1>\n
			<form method="post" action="?r={$lint_ed}$idp/$idim/$id" name="form_edt_items">			
                        <input type="hidden" value="$id" name="id_cm">                                
			$tabla                                    
			</form>
		</div>
MOSTREG;
                            
        //------computos metricos
	//obtiene listado de items que pertences a modulo
	$BD->query("SELECT * "		
		. "FROM con_computo_metrico "
		. "WHERE (id_im = $idim )");
	$html .= "<div id=\"div_lista_actividades\">";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			  . "<th>DESCRIPCION</th>\n"
                          . "<th>UNIDAD</th>\n"
                          . "<th>Num. Veces</th>\n"
                          . "<th>EJE</th>\n"
                          . "<th>SECTOR</th>\n"
                          . "<th>LONGITUD</th>\n"
                          . "<th>ALTURA</th>\n"
                          . "<th>ANCHO</th>\n"
                          . "<th>PESO</th>\n"
                          . "<th>PARCIAL</th>\n"                          
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_cm'];
			
			$html .= "<tr>\n"
			. "<td>{$reg['descripcion']}</td>"			
                        . "<td>{$reg['unidad']}</td>"	
                        . "<td>{$reg['numveces']}</td>"	
                        . "<td>{$reg['eje']}</td>"	
                        . "<td>{$reg['sector']}</td>"	
                        . "<td>{$reg['longitud']}</td>"
                        . "<td>{$reg['altura']}</td>"
                        . "<td>{$reg['ancho']}</td>"
                        . "<td>{$reg['peso']}</td>"
                        . "<td>{$reg['parcial']}</td>"
			. "</td>"
			. "</tr>\n";
		}
		$html .= "</table>";
	} else {
		$html .= mensajeNoExistenRegistros();
	};
//-----------------------                            
                            
	return $html;
}


/**
 * 
 */
function eliminarCMetricos( $idp,$idim, $id ) {
	global $BD;
	global $PARAMETROS;
	
	$link_ret = enlace('?r=' . CMETRICOS_MOSTRAR  . $idp . '/' . $idim , 'Cancelar', 'Regresar al listado de items');
            
        //formulario para eliminar items
	$link_elim = CMETRICOS_ELIMINAR . $idp.'/'.$idim . '/' . $id ;
	$form = <<<FORMELIMFORM
		<form method="post" action="?r=$link_elim$id" name="form_elim_item">
			<input type="hidden" value="$id" name="id_reg">
			<div id="div_normal">Realmente desea eliminar el registro de Computo Metrico?</div>
                        <div id="div_normal">Esta accion no se puede deshacer.</div>
			<input type="submit" value="Eliminar" class="boton">
		</form>
		<div class="div_normal">$link_ret</div>
FORMELIMFORM;
            
        if (!isset($PARAMETROS['id_reg'])) { // no elimina
             return $form;
        } else { //elimina registro
                    global $BD;
                    global $USR;
                    //$BD->query("select * from con_item where item_id = $id");
                    //$reg = $BD->getNext();
                    //instrucion para eliminar registro ITEM
                    $cons = "DELETE FROM con_computo_metrico WHERE (id_cm = {$PARAMETROS['id_reg']} )";
                    $BD->query($cons);                    
                    //registra en bitacora item eliminado
                    //registrarLog($USR['id'], 'items', 'item', "Se ha eliminado un item "
                    //        . "[ID: $id, Desc: {$reg['descripcion']}, Unidad: {$reg['unidad']}, Precio: {$reg['precio_unit']}]");
                    return '@' . CMETRICOS_MOSTRAR . $idp . '/' . $idim ;
            }
        
        
}

/**
 * @param 
 * @param 
 */
function nuevoItemsFPresupuesto( $id_obra, $id_modulo ){
    global $BD;
    global $PARAMETROS;
    $link_ins = $PARAMETROS['r'];
    
    $link_ret = "<a href=\"?r=".CMETRICOS_MODULOS . $id_obra."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
      
    $form ='';
    //--------------------------------------------------------------------
    if (isset($PARAMETROS['buscar'])) {
        $buscar = $PARAMETROS['buscar'];
    } else {
	$buscar = "";                
    }
    //--------------------------------------------------------------------
    // busqueda de registros
    if ( isset($PARAMETROS['btn_buscar']) )
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
    
    // ---------- registro ------------------------------------------------------------------------------------
    if ( isset($PARAMETROS['btn_guardar']) ) {    
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        if( $id_modulo==0 ){ // modulo no existe -> crea registro            
            $BD->query("SELECT convocatoria  FROM con_modulo "
	           . "WHERE (obra = $id_obra) ");
            $reg = $BD->getNext();
            $idconv =$reg['convocatoria'];                                
                
            $sql = "INSERT INTO con_modulo ( descripcion , obra, convocatoria ) "
		. " VALUES ( 'Fuera de Presupuesto', {$id_obra} , {$idconv})";            
            $BD->query( $sql );   
            //obtiene ID de nuevo registro
            $BD->query("SELECT id_modulo  FROM con_modulo "
	           . "WHERE (obra = $id_obra) AND (descripcion='Fuera de Presupuesto') ");
            $reg = $BD->getNext();
            $id_modulo =$reg['id_modulo'];                                
        }
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        $form = '';                
        $checked = $PARAMETROS['items'];        
        $itemsNum = $PARAMETROS['itemsNum'];
        
        //print_r( $PARAMETROS );
        for($i=0; $i < count($checked); $i++){                 
            //echo "item id: " . $checked[$i] . ' i: ' . $i . ' cantidad:' . $itemsNum[ $checked[$i] ] . "<br/>";            
            guardarNuevoItemMod2( $checked[$i], $id_modulo, $itemsNum[ $checked[$i] ] ); 
        }
        return '@' . CMETRICOS_MODULOS . $id_obra ;
    }
    //-----------------------------------------------------------------------------------------------------------
    $form .= '<form method="post" action="?r='.$link_ins.'" name="form_nuevo_item_mod">
            <input type="hidden" value="0" name="acc_form">
            <input type="hidden" value="'.$id_conv.'" name="id_conv">
            <input type="hidden" value="'.$id_mod.'" name="id_mod">';
    
    $buscador = '
           <div><h1>Agregar Items Fuera de Presupuesto</h1></div>
            <table>
                 <tr>
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

function cmetricosHTML( $id_obra ){
    global $BD;
    
    $datosObra = obtDatosObraHTMLPres( $id_obra );
    $presupConv = obtCMetricosHTML( $id_obra );
    
    $html = <<<REPORTE
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" lang="es" xml:lang="es"> 
	<head>
    	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    	<title>Computos metricos</title>  	
        <link type="text/css" rel="stylesheet" media="all" href="temas/defecto/defecto.css" />                
	</head>
	<body>
		<div>$datosObra</div>
		<div class="tbl500">$presupConv</div>
	</body>
REPORTE;
    
    return $html;
}

/**
 * @param int $id_obra Description
 */
function obtDatosObraHTMLPres( $id_obra ) {
	global $BD;
	$BD->query("SELECT * "
		. " FROM con_obras "
		. " WHERE (id_obra = $id_obra)");
        
	$reg = $BD->getNext();
	$html = <<<DATCONV
	<table border="0" width="100%">
		<tr>
			<td colspan="6"><img src="imagenes/logo_reportes.png"></td>
		</tr>
		<tr>
			<td colspan="6" align="center"><h3>COMPUTOS METRICOS</h3></td>
		</tr>
	    <tr>
	        <td><strong>Nombre:</strong></td>
	        <td colspan="5">{$reg['nombre']}</td>
	    </tr>
	    <tr>
	        <td><strong>Tipo Proyecto:</strong></td>
	        <td colspan="5">{$reg['tipo_proy']}</td>
	    </tr>
	    <tr>
	        <td><strong>Zona:</strong></td>
	        <td colspan="5">{$reg['zona']}</td>
	    </tr>
	    <tr>
	        <td><strong>Plazo de Ejecucion:</strong></td>
	        <td>{$reg['plazo_ejec']}</td>	        
	        <td><strong>Fecha Inicio.:</strong></td>
	        <td>{$reg['fecha_inicio']}</td>
                <td><strong>Fecha de Conclusion:</strong></td>
	        <td>{$reg['fecha_conclusion']}</td>
	    </tr>
	</table>
DATCONV;
	return $html;
}

/**
 * @param 
 */
function obtCMetricosHTML( $id_obra ) {
	global $BD;
	$BD->query(" SELECT id_modulo, descripcion "
		. " FROM con_modulo cm "
		. " WHERE (cm.obra = $id_obra)");
	$reg = $BD->getAll();
	$html = "<table>";
	$tot_pres = 0.0;
	foreach ($reg as $modulo) {
		$total_mod = number_format(calcularTotalMod($modulo['id_modulo']), 2, '.', '');
		$tot_pres += $total_mod;
		$items_pres = obtListCMetricos( $modulo['id_modulo'] );
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
			. "<th colspan=\"3\"><h2>TOTAL:</h2></th>"
			. "<td align=\"right\"> <h2>" . number_format($tot_pres, 2, '.', '') . "</h2></td>"
			. "</tr>";
	$html .= "</table>";
	return $html;
}

function calcularTotalMod( $id_mod ) {
	global $BD;
	$BD->query("SELECT SUM(cantidad * precio) as subtot "
		. " FROM con_item_modulo cim "
		. " WHERE (cim.modulo = $id_mod)");
	$reg = $BD->getNext();
	return $reg['subtot'];
}

/**
 * 
 */
function obtListCMetricos( $id_mod ) {
	global $BD;        
	$BD->query(" SELECT numitem , ci.item_id AS iditem, ci.descripcion AS itemdesc, ci.unidad AS itemunidad, "
                . " cim.cantidad AS cimcantidad, cim.precio AS cimprecio "
		. " FROM con_modulo cm INNER JOIN con_item_modulo cim ON cm.id_modulo=cim.modulo "
		. " INNER JOIN con_item ci ON ci.item_id=cim.item "
		. " WHERE (cm.id_modulo= {$id_mod} ) ");
	$html = "<div class=\"\"><table>"
		. "<tr>"
                . "<th align=\"center\">Num. Item</th>"
		. "<th align=\"center\">Descripcion</th>"
		. "<th align=\"center\">Undidad</th>"
                . "<th align=\"center\">Cantidad</th>"
		. "<th align=\"center\">Precio Unidad</th>"		
                . "<th align=\"center\">Precio Total</th>"		
		. "</tr>";    
        $reg = $BD->getAll();
        foreach ($reg as $modulo){
              $cm = obtListaCMetricos( $id_mod, $modulo['iditem'] );
                $ptotal = $modulo['cimcantidad'] * $modulo['cimprecio'];
		$html .= "<tr>"
			. "<th>{$modulo['numitem']}</th>"
                        . "<th>{$modulo['itemdesc']}</th>"
			. "<td align=\"center\">{$modulo['itemunidad']}</td>"
                        . "<td align=\"center\">{$modulo['cimcantidad']}</td>"
			. "<td align=\"center\">{$modulo['cimprecio']}</td>"			
                        . "<td align=\"center\"><strong>{$ptotal}</strong></td>"			
			. "</tr>"
                        . "<tr>"
			. "<td colspan=\"6\">$cm</td>"
			. "</tr>";
        }

        
	$html .= "</table></div>";
	return $html;
}

/**
 * 
 */
function obtListaCMetricos( $id_mod, $iditem ) {
    global $BD;
    $BD->query(" SELECT ccm.descripcion AS cmdesc, ccm.unidad AS cmunidad, numveces, ccm.* "
		. " FROM con_item_modulo cim INNER JOIN con_computo_metrico ccm ON ccm.id_im=cim.id_it_mod "		
		. " WHERE cim.modulo={$id_mod} AND cim.item={$iditem} ");
	$html = "<div class=\"\"><table>"
		. "<tr>"
		. "<th align=\"center\">Descripcion</th>"
		. "<th align=\"center\">Undidad</th>"
		. "<th align=\"center\">Num. Veces</th>"		
                . "<th align=\"center\">Eje</th>"		
                . "<th align=\"center\">Sector</th>"		
                . "<th align=\"center\">Longitud</th>"	
                . "<th align=\"center\">Altura</th>"	
                . "<th align=\"center\">Ancho</th>"	
                . "<th align=\"center\">Peso</th>"	
                . "<th align=\"center\">Volumen</th>"	
                . "<th align=\"center\">Parcial</th>"	
		. "</tr>";    
        $reg = $BD->getAll();
        $total=0;
        foreach ($reg as $modulo){              
		$html .= "<tr>"
			. "<td><div class=\"txtalignleft\">{$modulo['cmdesc']}</div></td>"
			. "<td align=\"left\">{$modulo['cmunidad']}</td>"
			. "<td align=\"left\">{$modulo['numveces']}</td>"			
                        . "<td align=\"left\">{$modulo['eje']}</td>"
                        . "<td align=\"left\">{$modulo['sector']}</td>"
                        . "<td align=\"left\">{$modulo['longitud']}</td>"
                        . "<td align=\"left\">{$modulo['altura']}</td>"
                        . "<td align=\"left\">{$modulo['ancho']}</td>"
                        . "<td align=\"left\">{$modulo['peso']}</td>"
                        . "<td align=\"left\">{$modulo['volumen']}</td>"
                        . "<td align=\"left\">{$modulo['parcial']}</td>"
			. "</tr>";                        
                 $total += $modulo['parcial'];        
        }     
        $html .= "<tr>"
                  ."<td colspan=\"9\"></td>"
                  ."<th><strong>TOTAL</strong></th>"
                  ."<td><strong>{$total}</strong></td>"
                 ."</tr>";
	$html .= "</table></div>";
	return $html;
}
?>
