<?php
define ('ID_ROL_SEGUI', 4);
define ('SEGUI_SEL_OBRA', 'avance_obra/selobr/');
define ('SEGUI_LISTAR', 'avance_obra/listar/');
define ('SEGUI_MOSTRAR', 'avance_obra/mostrar/');
define ('SEGUI_EDITAR', 'avance_obra/editar/');

define ('SEGUI_ESTADO_OBRA_HTML', 'clean/avance_obra/estado_avance_html/');

function iniciarModulo_avance_obra() {
	global $PARAMETROS;
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'selobr') {	     
             return seleccionarObraSegui();
	} else {
		$id_obra = parametros(3);
		$id = parametros(4);
		if ( $PARAMETROS['accion'] == 'listar' ) {
			return listarSeguis($id_obra);
		} elseif ($PARAMETROS['accion'] == 'mostrar') {                    
                    return mostrarSegui( $id_obra , $id);
		} elseif ($PARAMETROS['accion'] == 'editar') {			
                    //return editarSegui( $id_obra, $id );
		} elseif ($PARAMETROS['accion'] == 'estado_avance') {
			//return estadoAvanceObra($id_obra);
		} elseif ($PARAMETROS['accion'] == 'estado_avance_html') {
			return estadoAvanceObra($id_obra, false);
		}
	}
}

/**
 * Listado de obras en seguimiento
 */
function seleccionarObraSegui() {
	global $BD;
	$BD->query("SELECT id_obra, nombre, tipo_proy "
		. "FROM con_obras "
		. "ORDER BY tipo_proy, nombre ");
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


/**
 * @param int $pIDObra identificador unico de obra
 */
function listarSeguis( $pIDObra ) {
	global $BD;
	$BD->query("SELECT id_obra, nombre, tipo_proy "
		. "FROM con_obras "
		. "WHERE (id_obra = $pIDObra)");
	$reg = $BD->getNext();
	$nombreObra = $reg['nombre'];
	$tipoProy = $reg['tipo_proy'];
	$html = "<div id=\"div_datos_obra\">\n"
		. "<p><label class=\"etiqueta\">Nombre de la obra:</label>$nombreObra</p>\n"
		. "<p><label class=\"etiqueta\">Tipo de proyecto:</label>$tipoProy</p>\n"
		. "</div>";
	
        //listado de items y modulos
	$BD->query(" SELECT m.id_modulo , id_avan_fin ,id_avan_fis , im.item AS iditem ,m.descripcion AS ModDesc , i.descripcion AS ItemDesc "
		. " FROM con_modulo m INNER JOIN con_item_modulo im ON im.modulo=m.id_modulo "
		. " INNER JOIN con_item i ON item_id=item  "
                . " INNER JOIN con_avance_financiero af ON af.idim=id_it_mod "
                . " INNER JOIN con_avance_fisico afi ON afi.idim=id_it_mod "
		. " WHERE (m.obra = $pIDObra)");
        
	$html .= "<div id=\"div_lista_actividades\">\n<h1>Listado de items por modulos</h1>\n";
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>ITEM</th>\n"
			. "<th>MODULO</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['iditem'];
                        $idavance = $reg['id_avan_fin']; // id_avan_fin = id_avan_fis
			$acciones = array();
			if (tienePermiso(ID_ROL_SEGUI, 'ver')) {
				$acciones[] = enlace('?r=' . SEGUI_MOSTRAR . "$pIDObra/$idavance", 'Ver seguimiento', "Ver el seguimiento de la actividad");
			}
			//if (tienePermiso(ID_ROL_SEGUI, 'modificar')) {
				//$acciones[] = enlace('?r=' . SEGUI_EDITAR . "$pIDObra/$idavance", 'Actualizar seguimiento', "Actualizar el seguimiento de la actividad");
			//}
			$html .= "<tr>\n"
			. "<td>{$reg['ItemDesc']}</td>"
			. "<td>{$reg['ModDesc']}</td>"
			. "<td align=\"center\">" . implode('|', $acciones)
			. "</td>"
			. "</tr>\n";
		}
		$html .= "</table>";
		if (tienePermiso(ID_ROL_SEGUI, 'ver')) {			
			$link_estado_obra_html = enlace('?r=' . SEGUI_ESTADO_OBRA_HTML . $pIDObra, 
				'Informe HTML', 
				'Ver el avance de obra',
				'', '_BLANK');			
		} else {			
			$link_estado_obra_html = '';
		}
		$html .= "<div class=\"div_normal\"><p>$link_estado_obra_html</p></div>";
	} else {
		$html .= mensajeNoExistenRegistros();
	};
	$html .= "</div>";
	return $html;
}


/**
 * @param int $id identificador de 
 */
/*
function editarSegui( $idobra, $iditem ) {
	global $PARAMETROS;
	//echo $PARAMETROS['id_reg'] . '-----------';
        
	if (!isset( $PARAMETROS['id_reg'] )) {
		return formEdSegui( $idobra , $iditem);
	} else {
		if (!existenErroresSegui($PARAMETROS)) {
			return guardarSegui($PARAMETROS);
		} else {
			return formEdSegui($iditem, true);
		}
	}
}
*/

/**
 * Formulario para editar avande de obra
 * @param int $id identificador de
 * @param boolean $errores TRUE|FALSE
 */
function formEdSegui( $idobra, $id, $errores = false ) {
	
        //verificarSegui($id);	
	global $BD;
	global $PARAMETROS;
        //obtiene datos de 
	$BD->query(" SELECT id_obra, nombre, m.descripcion AS moddesc , it.descripcion AS itemdesc "
		. " FROM con_obras o INNER JOIN con_modulo m ON m.obra=o.id_obra "
                . " INNER JOIN con_item_modulo im ON im.modulo=m.id_modulo "
                . " INNER JOIN con_item it ON it.item_id=im.item "
                . " INNER JOIN con_avance_financiero af ON af.idim=im.id_it_mod "
		. " WHERE (o.id_obra = $idobra AND id_avan_fin= $id )");
	$reg = $BD->getNext();
	$idObra = $reg['obra'];
        $obradesc = $reg['nombre'];
        $moddesc = $reg['moddesc'];
        $itemdesc= $reg['itemdesc'];
	//$descActi = $reg['nombre'];
	//$tipoActi = $reg['tipo'];
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
			<h1>Avance de Obra</h1>\n
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
			        <td><label class="etiqueta">Obra:</label></td>
			        <td colspan="3"><label class="etiqueta">$obradesc</label></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Modulo:</label></td>
			        <td colspan="3"><label class="etiqueta">$moddesc</label></td>
			    </tr>
                            <tr>
			        <td><label class="etiqueta">Item:</label></td>
			        <td colspan="3"><label class="etiqueta">$itemdesc</label></td>
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
			        <td><label class="etiqueta" for="programado_fis">Anterior:</label></td>
			        <td><input type="text" name="programado_fis" value="$prog_fis" 
			        	maxlength="10" size="10" class="edt_form"/></td>
			        <td><label class="etiqueta" for="ejecutado_fis">Total ejecutado:</label></td>
			        <td>
                                    <input type="text" name="ejecutado_fis" value="$ejec_fis" 
			        	maxlength="10" size="10" class="edt_form"/>
                                            </td>
			    </tr>                                            
			    <tr>
			        <td><label class="etiqueta" for="programado_fis">% Ejecutado:</label></td>
			        <td><input type="text" name="programado_fis" value="$prog_fis" 
			        	maxlength="10" size="10" class="edt_form"/></td>
			        <td><label class="etiqueta" for="programado_fis">% x ejecutar:</label></td>
			        <td><input type="text" name="programado_fis" value="$prog_fis" 
			        	maxlength="10" size="10" class="edt_form"/></td>
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
			        <td><label class="etiqueta" for="saldo">anterior:</label></td>
			        <td><input type="text" name="saldo_ed" value="$saldo_fin" 
			        	maxlength="10" size="10" class="edt_form_disabled" disabled="true" /></td>
			        <td><label class="etiqueta" for="porcentaje">total ejecutado:</label></td>
			        <td><input type="text" name="porcentaje_ed" value="$porc" 
			        	maxlength="10" size="10" class="edt_form_disabled" disabled="true" /></td>
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



/**
 * muestra avance de obra
 * @param int $idobra 
 * @param int $id id modulo
 */
function mostrarSegui( $idobra , $id ) {

   global $BD;
   global $PARAMETROS;
        //datos
	$BD->query(" SELECT id_obra, it.unidad AS unidaditem, im.precio AS preciounidad , nombre, m.descripcion AS moddesc , it.descripcion AS itemdesc, "
                . " im.cantidad AS imcantidad  "
		. " FROM con_obras o INNER JOIN con_modulo m ON m.obra=o.id_obra "
                . " INNER JOIN con_item_modulo im ON im.modulo=m.id_modulo "
                . " INNER JOIN con_item it ON it.item_id=im.item "
                . " INNER JOIN con_avance_financiero af ON af.idim=im.id_it_mod "
                . " INNER JOIN con_avance_fisico afi ON afi.idim=im.id_it_mod "
		. " WHERE (o.id_obra = $idobra AND id_avan_fin= $id )");
	$reg = $BD->getNext();
	//$idObra = $reg['obra'];
        $obradesc = $reg['nombre'];
        $moddesc = $reg['moddesc'];
        $itemdesc= $reg['itemdesc'];	
        
        //$ejecutado_anterior_fis = $reg['ejecutado_anterior'];	
        //$ejecutado_anterior_fin = $reg['ejecutado_anterior_fin'];	
	
        //$link_ret = enlace('?r=' . SEGUI_LISTAR . $idobra, 'Volver', 'Regresar al listado', 'enlace_boton');
        $link_ret = "<a href=\"?r=".SEGUI_LISTAR . $idobra."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
       
        //------------------------------------------------->
        //obtiene ejecutado fisico = suma todos parciales
        $BD->query("SELECT SUM(parcial) AS sump "		
		. "FROM con_computo_metrico "
		. "WHERE (id_im = $id )");
        $reg2 = $BD->getNext();
        $ejecutado_fis = round( $reg2['sump'] , 2);
        //------------------------------------------------->
        
        if( $reg['imcantidad'] > 0 ){
            $porEjecutado = round ( $ejecutado_fis*100/$reg['imcantidad'],2);    
        }else{
            $porEjecutado = 0;
        }
        
        
        $porxejecutar = round ( 100 - $porEjecutado , 2);
        
        $totalbs= round ($reg['imcantidad']*$reg['preciounidad'] , 2);
        
        //$totalacumulado = $ejecutado_anterior_fis + $ejecutado_fis;
        
        $faltaejecutar = $reg['imcantidad'] - $ejecutado_fis;
               
        $actualfin = round( $ejecutado_fis * $reg['preciounidad'],2);
        
        //$totalacumuladofin = $ejecutado_anterior_fin + $actualfin;
        
        $faltaejecutarfin =  round ( $totalbs - $actualfin , 2);
        
        
        $jscss = "<link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\"modulos/avance_obra/jquery.percentageloader-0.1.css\" />\n";
        $jscss .= "<script type=\"text/javascript\" src=\"modulos/avance_obra/jquery.percentageloader-0.1.min.js\"></script>\n";
        $jscss .="<div id=\"topLoader\"></div>  
            <script>$(function() {
             var \$topLoader = $(\"#topLoader\").percentageLoader({width: 256, height: 256, controllable : false, progress : ($porEjecutado/100), onProgressUpdate : function(val) {}});         
            \$topLoader.setValue('Ejecutado'); 
            }); </script>";
        
        $html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Avance de Obra</h1>\n
			<form method="post" action="" name="form_edt_segui">
                        <div class="conv_1">  
                        <table class="tbl_formulario">
				<tr>
			        <td><label class="etiqueta">Obra:</label></td>
                                <td colspan="3">{$obradesc}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Modulo:</label></td>
			        <td colspan="3">{$moddesc}</td>
			    </tr>
                            <tr>
			        <td><label class="etiqueta">Item:</label></td>
                                <td colspan="3">{$itemdesc}</td>
			    </tr>                                            
                            <tr>
                                <td><label class="etiqueta" for="unidad">Unidad:</label></td>
			        <td><input type="text" name="unidad" value="{$reg['unidaditem']}" 
			        	maxlength="5" size="5" class="edt_form"/></td>
                                <td><label class="etiqueta" for="preciounidad">Precio/Unidad:</label></td>
			        <td><input type="text" name="precio" value="{$reg['preciounidad']}" 
			        	maxlength="10" size="10" class="edt_form"/></td>
                            </tr>    
                            <tr>
                                <td><label class="etiqueta" for="cantidad">Cantidad :</label></td>
                                <td><input type="text" name="precio" value="{$reg['imcantidad']}" 
			        	maxlength="10" size="10" class="edt_form"/></td>
                                <td><label class="etiqueta" for="totalbs">Total (Bs.):</label></td>
                                <td><input type="text" name="precio" value="{$totalbs}" 
			        	maxlength="10" size="10" class="edt_form"/></td>
                            </tr>                                    
			    <tr>
			        <td colspan="4"><h2>Avance f&iacute;sico</h2></td>
			    </tr>
                              <tr>
                                <td><label class="etiqueta" for="programado_fis">Programado (cantidad):</label></td>
                                <td><input type="text" name="programado_fis" value="{$reg['imcantidad']}" 
			        	maxlength="10" size="10" class="edt_form"/></td>
                                <td colspan="2" rowspan="5">$jscss</td>
                              </tr>
                              <tr>
                                <td><label class="etiqueta" for="ejecutado_fis">Ejecutado :</label></td>
                                <td><input type="text" name="ejecutado_fis" value="{$ejecutado_fis}" 
			        	maxlength="10" size="10" class="edt_form"/></td>
                              </tr>
                              <tr>
                                <td><label class="etiqueta" for="ejecutado_fis">Falta ejecutar :</label></td>
                                <td><input type="text" name="ejecutado_fis" value="$faltaejecutar" 
			        	maxlength="10" size="10" class="edt_form"/></td>
                              </tr>
                              <tr>
                                <td><label class="etiqueta" for="programado_fis">% Ejecutado:</label></td>
                                <td><input type="text" name="programado_fis" value="{$porEjecutado}" 
			        	maxlength="10" size="10" class="edt_form"/></td>
                              </tr>
                              <tr>
                                <td><label class="etiqueta" for="programado_fis">% por ejecutar:</label></td>
                                <td><input type="text" name="programado_fis" value="{$porxejecutar}" 
			        	maxlength="10" size="10" class="edt_form"/></td>
                              </tr>
			                                     
			    <tr>
			        <td colspan="4"><h2>Seguimiento financiero</h2></td>
			    </tr>
                            <tr>
                                <td><label class="etiqueta" for="programado_fin">Ejecutado (P.U.*Act. Fis):</label></td>
                                <td><input type="text" name="programado_fin_ed" value="{$actualfin}" 
			        	maxlength="10" size="10" class="edt_form" /></td>
                                <td><label class="etiqueta" for="programado_fin">Faltar ejecutar:</label></td>
                                <td><input type="text" name="programado_fin_ed" value="{$faltaejecutarfin}" 
			        	maxlength="10" size="10" class="edt_form"/></td>
                            </tr>                            		    
			</table>
                                </div>
			</form>
                        <div>$link_ret</div>
		</div>
MOSTREG;
	return $html;
}



/**
 * Informe HTML
 * @param int $id_obra identificador unico de obra
 */
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
        
        //obtiene los items de la obra
        	$BD->query(" SELECT id_obra, it.unidad AS uni , im.precio AS preciounidad , nombre, m.descripcion AS moddesc , it.descripcion AS itemdesc, "
                . " im.cantidad AS imcantidad, im.id_it_mod AS idim , sum(parcial) AS ejecutado  "
		. " FROM con_obras o INNER JOIN con_modulo m ON m.obra=o.id_obra "
                . " INNER JOIN con_item_modulo im ON im.modulo=m.id_modulo "
                . " INNER JOIN con_item it ON it.item_id=im.item "
                . " INNER JOIN con_avance_financiero af ON af.idim=im.id_it_mod "
                . " INNER JOIN con_computo_metrico cm ON cm.id_im=im.id_it_mod "        
		. " WHERE (o.id_obra = $id_obra )"
                . " GROUP by idim "        
                );
        $tblDatos = "";                
        
        $tmpBD = $BD;
        $monto_actual_ejecutado = 0;
        $monto_total_acumulado = 0;
        $monto_total_por_ejecutar =0;
        $suma_totalbs=0;
        //$porTotalEjecutado=0;
        
        while ( $reg = $tmpBD->getNext() ) {
                    
           $totalbs= round ($reg['imcantidad']*$reg['preciounidad'] , 2);
           $suma_totalbs +=$totalbs;
           
           $anteriorfis = 0;
           
           $ejecutado = round( $reg['ejecutado'] , 2);
           $totalacumulado = $anteriorfis + $ejecutado;
           $faltaejecutar = $reg['imcantidad'] - $totalacumulado;
           $anteriorfin = 0;
           $actualfin = round( $ejecutado * $reg['preciounidad'],2);
           
           $monto_actual_ejecutado += $actualfin;
           $monto_total_acumulado += 1;
           
           $totalacumuladofin = $anteriorfin + $actualfin;
           
           $monto_total_acumulado += $totalacumuladofin;           
           
           
           $faltaejecutarfin =  round ( $totalbs - $totalacumuladofin , 2);
           
           $monto_total_por_ejecutar += $faltaejecutarfin;
           
           $porEjecutado = round ( $ejecutado*100/$reg['imcantidad'],2);
           $porxejecutar = round ( 100 - $porEjecutado , 2);
        
                   
           $tblDatos .= "<tr>"
                        ."<td>{$reg['itemdesc']}</td>"
                        ."<td>{$reg['uni']}</td>"
                        ."<td>{$reg['imcantidad']}</td>"
                        ."<td>{$reg['preciounidad']}</td>"
                        ."<td>{$totalbs}</td>"
                        ."<td>{$anteriorfis}</td>"
                        ."<td>{$ejecutado}</td>"
                        ."<td>{$totalacumulado}</td>"
                        ."<td>{$faltaejecutar}</td>"
                        ."<td>{$anteriorfin}</td>"
                        ."<td>{$actualfin}</td>"
                        ."<td>{$totalacumuladofin}</td>"
                        ."<td>{$faltaejecutarfin}</td>"
                        ."<td>{$porEjecutado} %</td>"
                        ."<td>{$porxejecutar} %</td>"
                      ."</tr>";  
        }        
	
        $porTotalEjecutado = round ( $monto_actual_ejecutado*100/$suma_totalbs , 2);
        
        //----------------------------------------------------------------//
 
$tblAvance = <<<TBLAVANCE
       <div class="htmlreport" >         
       <table>
  <tr>
    <th rowspan="2">DESCRIPCION</th>
    <th rowspan="2">UNID</th>
    <th rowspan="2">CANTIDAD</th>
    <th rowspan="2">P.U.</th>
    <th rowspan="2">TOTAL (Bs.)</th>
    <th colspan="4">AVANCE FISICO </th>
    <th colspan="4">AVANCE FINANCIERO </th>
    <th rowspan="2">% EJECUTADO </th>
    <th rowspan="2">% X EJECUTAR </th>
  </tr>
  <tr>
    <th>ANTERIOR</th>
    <th>ACTUAL </th>
    <th>T. ACUMULADO</th>
    <th>FALTA EJECUTAR </th>	
    <th>ANTERIOR</th>
    <th>ACTUAL</th>
    <th>T. ACUMULADO </th>
    <th>FALTA EJECUTAR </th>
  </tr>
{$tblDatos}
</table>
</div>
TBLAVANCE;

$tabletotal = <<<TABLETOTAL
   <div style="margin: 30px 5px 0 35px;">     
    <table class="tablatotales" >
  <tr>
    <th>Monto actual ejecutado : </th>
    <td>{$monto_actual_ejecutado}</td>
    <th>Monto total acumulado a la fecha: </th>
    <td>{$monto_total_acumulado}</td>
  </tr>
  <tr>
    <th>Porcentaje total ejecutado : </th>
    <td>{$porTotalEjecutado} %</td>
    <th>Monto total por ejecutar : </th>
    <td>{$monto_total_por_ejecutar}</td>
  </tr>
</table></div>
TABLETOTAL;

        //reporte
	$html = <<<REPORTE
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" lang="es" xml:lang="es"> 
	<head>
    	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    	<title>Seguimiento de obras</title>  
         <link type="text/css" rel="stylesheet" media="all" href="temas/defecto/defecto.css" />                
	</head>
	<body>
                
	<table width="100%" class="tbl_main">
		<tr>
			<td colspan="4"><img src="imagenes/logo_reportes.png"></td>
		</tr>
            <tr>
		<td colspan="4"><h1>DATOS DEL PROYECTO</h1></td>
	    </tr>                
	    <tr>
	        <th><strong>Obra:</strong></th>
	        <td>$nombreObra</td>
	        <th><strong>Tipo de proyecto:</strong></th>
	        <td>$tipoProy</td>
	    </tr>
	    <tr>
	        <th><strong>Modalidad:</strong></th>
	        <td>$modalidad</td>
	        <th><strong>Contratista:</strong></th>
	        <td>$contratista</td>
	    </tr>
	    <tr>
	        <th><strong>Nro. de contrato:</strong></th>
	        <td>$nroContrato</td>
	        <td>&nbsp;</td>
	        <td>&nbsp;</td>
	    </tr>
	</table>
                
	$tblAvance  $tabletotal
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

?>
