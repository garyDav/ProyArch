<?php

define ('OBR_LISTAR_HTML', 'clean/obras/listarhtml/');
define ('OBR_CONSULTAR', 'obras/consultar/');

function iniciarModulo_obras() {
	global $PARAMETROS;
	$id = parametros(3);
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'listar') {
		return listarObras();
	} elseif ($PARAMETROS['accion'] == 'mostrar') {
		return mostrarObra($id);
	} elseif ($PARAMETROS['accion'] == 'editar') {
		return editarObra($id);
	} elseif ($PARAMETROS['accion'] == 'nuevo') {
		return editarObra('0');
	} elseif ($PARAMETROS['accion'] == 'eliminar') {
		return eliminarObra($id);
	} elseif ($PARAMETROS['accion'] == 'listarhtml') {
		return listaObrsHTML($id);
	} elseif ($PARAMETROS['accion'] == 'consultar') {
	   return frmConsultarObras();
	}
}

function listarObras() {
	global $BD;
	$BD->query("select * from con_obras order by nombre");
	$html = "<div id=\"div_lista_obras\">\n<h1>Listado de obras</h1>\n";
	$accs_cab = '<h2>';
	if (tienePermiso(1, 'nuevo')) {
		$accs_cab .= enlace('?r=obras/nuevo', 'Nuevo', "Registrar una nueva obra");
	}
	if (tienePermiso(1, 'ver')) {
		$accs_cab .= " | " . enlace('?r=' . OBR_LISTAR_HTML, 'HTML', 
				"Mostrar el listado de obras en formato HTML", "", "_BLANK");
	}
	$html .= $accs_cab . '</h2>';
	if ($BD->numRows() > 0) {
		$html .= "<table class=\"listado\" cellspacing=\"0\">\n"
			. "<tr>\n"
			. "<th>NOMBRE</th>\n"
			. "<th>TIPO</th>\n"
			. "<th>MODALIDAD</th>\n"
			. "<th>INICIO</th>\n"
			. "<th>NRO. CONTRATO</th>\n"
			. "<th>ZONA</th>\n"
			. "<th>DISTRITO</th>\n"
			. "<th>CONTRATISTA</th>\n"
			. "<th>ACCIONES</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) {
			$id = $reg['id_obra'];
			$acciones = array();
			if (tienePermiso(2, 'ver')) {
				$acciones[] = enlace('?r=obras/mostrar/' . $id, 'Ver', "Ver los datos de la obra: {$reg['nombre']}");
			}
			if (tienePermiso(2, 'modificar')) {
				$acciones[] = enlace('?r=obras/editar/' . $id, 'Editar', "Editar los datos de la obra: {$reg['nombre']}");
			}
			if (tienePermiso(2, 'eliminar')) {
				$acciones[] = enlace('?r=obras/eliminar/' . $id, 'Eliminar', "Eliminar la obra: {$reg['nombre']}");
			}
			$html .= "<tr>\n"
			. "<td>{$reg['nombre']}</td>"
			. "<td>{$reg['tipo_proy']}</td>"
			. "<td>{$reg['modalidad']}</td>"
			. "<td>{$reg['fecha_inicio']}</td>"
			. "<td>{$reg['nro_contrato']}</td>"
			. "<td>{$reg['zona']}</td>"
			. "<td>{$reg['distrito']}</td>"
			. "<td>{$reg['contratista']}</td>"
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
 * @param int $id identificador unico de obra
 */
function mostrarObra( $id ) {
	require_once('inc/conversiones.inc');
	global $BD;
	$BD->query("select * from con_obras where (id_obra = $id)");
	$reg = $BD->getNext();
	$monto = number_format($reg['monto'], 2);
	$link_ret = enlace('?r=obras/listar/', 'Regresar', 'Regresar al listado de obras');
	$f_ini = date("d/m/Y", cadenaAFecha($reg['fecha_inicio']));
	$f_anti = date("d/m/Y", cadenaAFecha($reg['fecha_anticipo']));
	$f_conc = date("d/m/Y", cadenaAFecha($reg['fecha_conclusion']));
	$val_bol = date("d/m/Y", cadenaAFecha($reg['validez_boleta']));
	$f_conc_r = date("d/m/Y", cadenaAFecha($reg['fecha_conclusion_real']));
	$ven_bol = date("d/m/Y", cadenaAFecha($reg['vencimiento_boleta']));
	$html = <<<MOSTOBRA
		<div id="div_mostrar_datos">\n
			<h1>Registro de obras</h1>\n
			<table class="tbl_formulario">
			    <tr>
			        <td><label class="etiqueta">Proyecto/Obra:</label></td>
			        <td colspan="3">{$reg['nombre']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Tipo de Proyecto:</label></td>
			        <td colspan="3">{$reg['tipo_proy']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Zona:</label></td>
			        <td>{$reg['zona']}</td>
			        <td><label class="etiqueta">Distrito:</label></td>
			        <td>{$reg['distrito']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Modalidad:</label></td>
			        <td>{$reg['modalidad']}</td>
			        <td><label class="etiqueta">Fecha de inicio:</label></td>
			        <td>$f_ini</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Contratista:</label></td>
			        <td>{$reg['contratista']}</td>
			        <td><label class="etiqueta">Fecha de anticipo:</label></td>
			        <td>$f_anti</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Nro. contrato:</label></td>
			        <td>{$reg['nro_contrato']}</td>
			        <td><label class="etiqueta">Plazo ejecuci&oacute;n:</label></td>
			        <td>{$reg['plazo_ejec']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Monto:</label></td>
			        <td>$monto</td>
			        <td><label class="etiqueta">Fecha conclusi&oacute;n:</label></td>
			        <td>$f_conc</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Validez de Boleta:</label></td>
			        <td>$val_bol</td>
			        <td><label class="etiqueta">Fecha conclusi&oacute;n real:</label></td>
			        <td>$f_conc_r</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Vencimiento Boleta:</label></td>
			        <td>$ven_bol</td>
			        <td><label class="etiqueta">Dias ejecutados:</label></td>
			        <td>{$reg['dias_ejec']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Estado Boleta:</label></td>
			        <td>{$reg['estado_boleta']}</td>
			        <td><label class="etiqueta">Dias retraso:</label></td>
			        <td>{$reg['dias_retraso']}</td>
			    </tr>
			</table>
		</div>
		<div class="div_normal">$link_ret</div>
MOSTOBRA;
	return $html;
}

/**
 * @param int $id identificador unico de obra
 */
function editarObra( $id ) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
	echo $PARAMETROS['convocatoria'];
	if (!isset($PARAMETROS['id_reg'])) {
		return formEdObra($id);
	} else {
		if (!existenErroresObras($PARAMETROS)) {
			return guardarObras($PARAMETROS);
		} else {
			return formEdObra($id, true);
		}
	}
}

/**
 * @param int $id llave primaria de obra
 * @param boolean $errores
 */
function formEdObra($id, $errores = false) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
	
        $ttipo = ( $id > 0 )?"Actualizacion":"Nuevo Registro";
        
	if ( !$errores ) {            
		$BD->query("SELECT * FROM con_obras WHERE (id_obra = $id) ");
		$reg = $BD->getNext();                
                
		$monto = number_format($reg['monto'], 2, '.', '');                
		$f_ini = date("Y-m-d", cadenaAFecha($reg['fecha_inicio']));
		$f_anti = date("Y-m-d", cadenaAFecha($reg['fecha_anticipo']));
		$f_conc = date("Y-m-d", cadenaAFecha($reg['fecha_conclusion']));
		$val_bol = date("Y-m-d", cadenaAFecha($reg['validez_boleta']));
		$f_conc_r = date("Y-m-d", cadenaAFecha($reg['fecha_conclusion_real']));
		$ven_bol = date("Y-m-d", cadenaAFecha($reg['vencimiento_boleta']));
	} else {
		$reg = array();                
		$monto = $PARAMETROS['obr_monto'];
		$f_ini = $PARAMETROS['obr_fecha_ini'];
		$f_anti = $PARAMETROS['obr_fecha_anti'];
		$f_conc = $PARAMETROS['obr_fecha_conc'];
		$val_bol = $PARAMETROS['obr_val_bol'];
		$f_conc_r = $PARAMETROS['obr_conc_r'];
		$ven_bol = $PARAMETROS['obr_ven_bol'];
		$reg['nombre'] = $PARAMETROS['obr_nombre'];
		$reg['tipo_proy'] = $PARAMETROS['obr_tipo_proy'];
		$reg['zona'] = $PARAMETROS['obr_zona'];
		$reg['distrito'] = $PARAMETROS['obr_distrito'];
		$reg['modalidad'] = $PARAMETROS['obr_modalidad'];
		$reg['contratista'] = $PARAMETROS['obr_contratista'];
		$reg['nro_contrato'] = $PARAMETROS['obr_nro_cont'];
		$reg['plazo_ejec'] = $PARAMETROS['obr_plazo_ejec'];
		$reg['dias_ejec'] = $PARAMETROS['obr_dias_ejec'];
		$reg['estado_boleta'] = $PARAMETROS['obr_estado_boleta'];
		$reg['dias_retraso'] = $PARAMETROS['obr_dias_retraso'];
	}
        //-----------------------------------> CONVOCATORIA
        $op="";
        if( $id > 0){ //es actualizacion
            $BD->query("SELECT objeto FROM con_convocatoria INNER JOIN con_modulo ON id_conv=convocatoria
                        WHERE obra=$id LIMIT 1 ");
            $reg2 = $BD->getNext();
            $op = $reg2['objeto'];
        }else{ // nuevo registro
            //obtiene convocatorias disponibles que hallan sido aprobadas
            $BD->query("SELECT DISTINCT id_conv, objeto FROM con_convocatoria INNER JOIN con_modulo
                        ON convocatoria=id_conv WHERE estado='Aprobado' AND obra IS NULL ");            
            $op = "<select name=\"convocatoria\" style=\"width:400px;\" class=\"edt_form\">";
            if ( $BD->numRows() > 0 ){//existen registros
                while ( $reg2 = $BD->getNext() ) {                
                      $op .= "<option value=\"{$reg2['id_conv']}\">{$reg2['objeto']}</option>";
                }   
            }
            $op .= "</select>";
        }
        
        //----------------------------------->//
        //$link_ret = enlace('?r=obras/listar/', 'Cancelar', 'Regresar al listado de obras', 'enlace_boton');
        $js = "<script type=\"text/javascript\" src=\"modulos/obras/obras.js\"></script>\n";
	$html = <<<MOSTOBRA
                {$js}
		<div id="div_mostrar_datos">\n
			<h1>Registro de obras [{$ttipo}] </h1>\n
			<form method="post" action="?r=obras/editar/$id" name="form_edt_obras">
			<input type="hidden" value="$id" name="id_reg">
                
                    <div class="conv_1">                
                        <table class="tbl_formulario">
                            <tr>
			        <td><label class="etiqueta" for="obr_nombre">Proyecto/Obra:</label></td>
			        <td colspan="3"><input type="text" name="obr_nombre" value="{$reg['nombre']}" 
			        	maxlength="200" size="50" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="obr_tipo_proy">Tipo de Proyecto:</label></td>
			        <td colspan="3"><input type="text" name="obr_tipo_proy" value="{$reg['tipo_proy']}" 
			        	maxlength="100"  size="35" class="edt_form" /></td>
			    </tr>    
			    <tr>
			        <td><label class="etiqueta" for="convocatoria">Convocatoria:</label></td>
			        <td colspan="3">{$op}</td>
			    </tr>                                    
                        </table>
                    </div>
                                
                    <!--  -->
                    <div class="conv_1">
                        <h3>Periodo</h3>
                        <table class="tbl_formulario">
                             <tr>
			        <td><label class="etiqueta" for="obr_fecha_ini">Fecha de inicio:</label></td>
			        <td><input type="date" name="obr_fecha_ini" id="obr_fecha_ini" value="$f_ini" 
			        	maxlength="10"  size="10" class="edt_form"/></td>
			        <td><label class="etiqueta" for="obr_fecha_conc">Fecha conclusi&oacute;n:</label></td>
			        <td><input type="text" name="obr_fecha_conc" id="obr_fecha_conc" value="$f_conc" 
			        	maxlength="10"  size="10" class="no_edt_form"/></td>
			    </tr>
                            <tr>
                                <td><label class="etiqueta" for="obr_plazo_ejec">Plazo ejecuci&oacute;n:</label></td>
                                <td><input type="number" name="obr_plazo_ejec" id="obr_plazo_ejec" value="{$reg['plazo_ejec']}" 
			        	maxlength="4"  size="8" class="edt_form"/></td>
                                <td><label class="etiqueta" for="obr_conc_r">Fecha conclusi&oacute;n real:</label></td>
                                <td><input type="date" name="obr_conc_r" id="obr_conc_r" value="$f_conc_r" 
			        	maxlength="10"  size="10" class="edt_form"/></td>
                            </tr>
                            <tr>
                                <td><label class="etiqueta" for="obr_dias_ejec">Dias ejecutados:</label></td>
                                <td><input type="number" name="obr_dias_ejec" value="{$reg['dias_ejec']}" 
			        	maxlength="4"  size="8" class="edt_form"/></td>
                                <td><label class="etiqueta" for="obr_dias_retraso">Dias retraso:</label></td>
                                <td><input type="number" name="obr_dias_retraso" value="{$reg['dias_retraso']}" 
			        	maxlength="4"  size="8" class="edt_form"/></td>
                            </tr>
                            <tr>
                                <td><label class="etiqueta" for="obr_fecha_anti">Fecha de anticipo:</label></td>
                                <td><input type="date" name="obr_fecha_anti" value="$f_anti" 
			        	maxlength="10"  size="10" class="edt_form"/></td>
                                <td></td>
                                <td></td>
                            </tr>    
                        </table>
                    </div>

                    <!-- datos -->
                    <div class="conv_1">                        
                        <table class="tbl_formulario">
                           <tr>
                               <td><label class="etiqueta" for="obr_zona">Zona:</label></td>
                               <td><input type="text" name="obr_zona" value="{$reg['zona']}" 
			        	maxlength="255"  size="25" class="edt_form"/></td>
                               <td><label class="etiqueta" for="obr_distrito">Distrito:</label></td>
                               <td><input type="text" name="obr_distrito" value="{$reg['distrito']}" 
			        	maxlength="25"  size="25" class="edt_form"/></td>
                           </tr>  
                           <tr>
                               <td><label class="etiqueta" for="obr_contratista">Contratista:</label></td>
                               <td><input type="text" name="obr_contratista" value="{$reg['contratista']}" 
			        	maxlength="100"  size="25" class="edt_form"/></td>
                               <td><label class="etiqueta" for="obr_nro_cont">Nro. contrato:</label></td>
                               <td><input type="text" name="obr_nro_cont" value="{$reg['nro_contrato']}" 
			        	maxlength="25"  size="25" class="edt_form"/></td>
                           </tr>                                  
                           <tr>
                               <td><label class="etiqueta" for="obr_modalidad">Modalidad:</label></td>
                               <td><input type="text" name="obr_modalidad" value="{$reg['modalidad']}" 
			        	maxlength="100"  size="25" class="edt_form"/></td>
                               <td><label class="etiqueta" for="obr_monto">Monto:</label></td>
                               <td><input type="text" name="obr_monto" value="$monto" 
			        	maxlength="15"  size="10" class="edt_form"/></td>
                           </tr>
                           <tr>
                               <td><label class="etiqueta" for="obr_val_bol">Validez de Boleta:</label></td>
                               <td><input type="date" name="obr_val_bol" value="$val_bol" 
			        	maxlength="10"  size="10" class="edt_form"/></td>
                               <td><label class="etiqueta" for="obr_ven_bol">Vencimiento Boleta:</label></td>
                               <td><input type="date" name="obr_ven_bol" value="$ven_bol" 
			        	maxlength="10"  size="10" class="edt_form"/></td>
                           </tr>    
                           <tr>
                               <td><label class="etiqueta" for="obr_estado_boleta">Estado Boleta:</label></td>
                               <td><input type="text" name="obr_estado_boleta" value="{$reg['estado_boleta']}" 
			        	maxlength="50"  size="25" class="edt_form"/></td>
                               <td></td>
                               <td></td>
                           </tr>                
                        </table>
                    </div>      
                          
                     <!-- controles -->
			<table class="tbl_formulario">			  
			    
			    <tr>
			    	<td colspan="2" align="center">
			    		<input type="submit" value="Guardar">
			    	</td>
			    	<td colspan="2" align="center">
                                        <a href="?r=obras/listar/">
                                            <input type="button" value="Cancelar">
                                        </a>    			    		
			    	</td>
			    </tr>
			</table>
			</form>
		</div>
MOSTOBRA;
	return $html;
}

function existenErroresObras($form) {
	include_once('inc/validaciones.inc');
	$result = false;
	if (trim($form['obr_nombre']) == '') {
		registrarError('Debe ingresar el nombre de la obra.');
		$result = true;
	}
	if (trim($form['obr_tipo_proy']) == '') {
		registrarError('Debe ingresar el tipo de proyecto.');
		$result = true;
	}
	if (trim($form['obr_zona']) == '') {
		registrarError('Debe ingresar la zona.');
		$result = true;
	}
	if (trim($form['obr_modalidad']) == '') {
		registrarError('Debe ingresar la modalidad.');
		$result = true;
	}
	if (!fechaValida($form['obr_fecha_ini'])) {
		registrarError('La fecha de inicio es inv&aacute;lida.');
		$result = true;
	}
	if ($form['obr_fecha_anti'] != '') {
		if (!fechaValida($form['obr_fecha_anti'])) {
			registrarError('La fecha de anticipo es inv&aacute;lida.');
			$result = true;
		}
	}
	if (!esNumeroEntero($form['obr_plazo_ejec'])) {
		registrarError('El plazo de ejecuci&oacute;n debe ser un valor entero.');
		$result = true;
	}
	if (!is_numeric($form['obr_monto'])) {
		registrarError('El monto debe ser un valor num&eacute;rico.');
		$result = true;
	}
	if (!fechaValida($form['obr_fecha_conc'])) {
		registrarError('La fecha de conclusi&oacute;n es inv&aacute;lida.');
		$result = true;
	}
	if (!fechaValida($form['obr_val_bol'])) {
		registrarError('La fecha de validez de la boleta es inv&aacute;lida.');
		$result = true;
	}
	if ($form['obr_conc_r'] != '') {
		if (!fechaValida($form['obr_conc_r'])) {
			registrarError('La fecha de conclusi&oacute;n real es inv&aacute;lida.');
			$result = true;
		}
	}
	if (!fechaValida($form['obr_ven_bol'])) {
		registrarError('La fecha de vencimiento de la boleta es inv&aacute;lida.');
		$result = true;
	}
	if (!esNumeroEntero($form['obr_dias_ejec'])) {
		registrarError('Los d&iacute;as ejecutados deben ser un valor entero.');
		$result = true;
	}
	if (trim($form['obr_estado_boleta']) == '') {
		registrarError('Debe ingresar el estado de la boleta.');
		$result = true;
	}
	if (trim($form['obr_dias_retraso']) != '') {
		if (!esNumeroEntero($form['obr_dias_retraso'])) {
			registrarError('Los d&iacute;as de retraso deben ser un valor entero.');
			$result = true;
		}
	}
	return $result;
}

/**
 * @param array $form datos formulario
 */
function guardarObras($form) {
    global $BD;
    global $USR;
	if ((trim($form['id_reg']) != '') && (trim($form['id_reg']) != '0')) { //actualizacion
		$cons = "UPDATE con_obras "
		. "SET "
		. "nombre = '{$form['obr_nombre']}', "
		. "tipo_proy = '{$form['obr_tipo_proy']}', "
		. "zona = '{$form['obr_zona']}', "
		. "distrito = '{$form['obr_distrito']}', "
		. "modalidad = '{$form['obr_modalidad']}', "
		. "contratista = '{$form['obr_contratista']}', "
		. "nro_contrato = '{$form['obr_nro_cont']}', "
		. "monto = '{$form['obr_monto']}', "
		. "fecha_inicio = '" . date("Y-m-d", cadenaAFecha3($form['obr_fecha_ini'])) . "', "
		. "fecha_anticipo = '" . date("Y-m-d", cadenaAFecha3($form['obr_fecha_anti'])) . "', "
		. "plazo_ejec = {$form['obr_plazo_ejec']}, "
		. "fecha_conclusion = '" . date("Y-m-d", cadenaAFecha3($form['obr_fecha_conc'])) . "', "
		. "fecha_conclusion_real = '" . date("Y-m-d", cadenaAFecha3($form['obr_conc_r'])) . "', "
		. "dias_ejec = {$form['obr_dias_ejec']}, "
		. "dias_retraso = {$form['obr_dias_retraso']}, "
		. "validez_boleta = '" . date("Y-m-d", cadenaAFecha3($form['obr_val_bol'])) . "', "
		. "vencimiento_boleta = '" . date("Y-m-d", cadenaAFecha3($form['obr_ven_bol'])) . "', "
		. "estado_boleta = '{$form['obr_estado_boleta']}', "
		. "encargado_segui = 'N/A' "
		. "WHERE (id_obra = {$form['id_reg']})";
	} else { //nuevo registro
		$cons = "INSERT into con_obras (nombre, tipo_proy, zona, distrito, "
		. "modalidad, contratista, nro_contrato, monto, "
		. "fecha_inicio, fecha_anticipo, plazo_ejec, fecha_conclusion, "
		. "fecha_conclusion_real, dias_ejec, dias_retraso, validez_boleta, "
		. "vencimiento_boleta, estado_boleta, encargado_segui, usuario) "                        
		. "VALUES ('{$form['obr_nombre']}', '{$form['obr_tipo_proy']}', '{$form['obr_zona']}', '{$form['obr_distrito']}', "
		. "'{$form['obr_modalidad']}', '{$form['obr_contratista']}', '{$form['obr_nro_cont']}', '{$form['obr_monto']}', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['obr_fecha_ini'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['obr_fecha_anti'])) . "', "
		. "{$form['obr_plazo_ejec']}, "
		. "'" . date("Y-m-d", cadenaAFecha3($form['obr_fecha_conc'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['obr_conc_r'])) . "', "
		. "{$form['obr_dias_ejec']}, {$form['obr_dias_retraso']}, "
		. "'" . date("Y-m-d", cadenaAFecha3($form['obr_val_bol'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['obr_ven_bol'])) . "', "
		. "'{$form['obr_estado_boleta']}', '', {$USR['id']})";
                                
	}
	if ( $BD->query($cons) ) {
	       registrarMensaje('Se ha guardado la obra correctamente.');
               if( $form['id_reg'] == 0){ // el registro es nuevo es nuevo -> asigna obra a modulos segun convocatoria seleccionada
                //obtiene ID de ultimo registro de obra creada
                $BD->query(" SELECT max(id_obra) AS id FROM con_obras ");   
                $reg2 = $BD->getNext();
                $idobra = $reg2['id'];
                //actualiza modulos
                 $BD->query(" UPDATE con_modulo SET obra='{$idobra}' WHERE convocatoria=". $form['convocatoria'] );   
               }
               registrarLog($USR['id'], 'obras', 'con_obras',obtenerAccionesDeQuery($cons, 'Obra', $form['id_reg']));
	} else {
		registrarError("No se ha podido guardar la obra. <br />{$BD->error}");
	}
	return '@obras/listar';
}

function eliminarObra($id) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
	global $USR;
	//$link_ret = enlace('?r=obras/listar/', 'Cancelar', 'Regresar al listado de obras');
        $link_ret = "<a href=\"?r=obras/listar/"."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
        
	$form = <<<FORMELIMOBRA
            <div class="conv_1">  
                <form method="post" action="?r=obras/eliminar/$id" name="form_elim_obras">
                <input type="hidden" value="$id" name="id_reg">		
                <div style="width: 300px; margin: 0 auto;">
                <table border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <td colspan="2"><div class="del_txt">Realmente desea eliminar el registro completo de esta obra?</div></td>
                    </tr>
                    <tr>
                      <td><input type="submit" value="Eliminar" class="boton"></td>
                      <td>$link_ret</td>
                    </tr>
                  </table>
                </div>
		</form>  
                </div>			   
FORMELIMOBRA;
	if (!isset($PARAMETROS['id_reg'])) {
		return $form;
	} else {
		global $BD;
		$cons = "DELETE FROM con_obras WHERE (id_obra = $id)";
		$BD->query($cons);
                registrarLog($USR['id'], 'obras', 'con_obras',"Obra eliminada [ID: $id]");
		return '@obras/listar/';
	}
}

function obtListaObrsArr() {
	global $BD;
	$BD->query("select nombre, tipo_proy, zona, distrito, "
		. "modalidad, contratista, nro_contrato, monto, "
		. "fecha_inicio, fecha_anticipo, plazo_ejec, "
		. "fecha_conclusion, fecha_conclusion_real, "
		. "dias_ejec, dias_retraso, validez_boleta, "
		. "vencimiento_boleta, estado_boleta, encargado_segui "
		. "from con_obras "
		. "order by nombre, tipo_proy");
	return $BD->getAll();
}

function obtenerListadoObrsHTML() {
	$regs = obtListaObrsArr();
	$cont = '';
	$cont .= '<table border="1" cellspacing="0" '
		. 'class="listado">';
	$cont .= '<tr style="border: 1px solid #000;">'
		. "<th>OBRA</th>"
		. "<th>TIPO</th>"
		. "<th>ZONA</th>"
		. "<th>DISTRITO</th>"
		. "<th>MODALIDAD</th>"
		. "<th>CONTRATISTA</th>"
		. "<th>NRO. CONTRATO</th>"
		. "<th>MONTO</th>"
		. "<th>FECHA INICIO</th>"
		. "<th>FECHA ANTICIPO</th>"
		. "<th>PLAZO EJEC.</th>"
		. "<th>FECHA CONCLUSION</th>"
		. "<th>FECHA CONCL. REAL</th>"
		. "<th>DIAS EJECUTADOS</th>"
		. "<th>DIAS RETRASO</th>"
		. "<th>VALIDEZ DE BOLETA</th>"
		. "<th>VENCIMIENTO BOLETA</th>"
		. "<th>ESTADO BOLETA</th>"
		. "<th>ENC. SEGUIMIENTO</th>"
		. "</tr>";
	foreach ($regs as $reg) {
		$cont .= '<tr><td>' . implode('</td><td>', $reg) . '</td></tr>';
	}
	$cont .= "</table>";
	return $cont;
}

function listaObrsHTML() {
	$listadoHTML = obtenerListadoObrsHTML();
	global $Estilos;
	$estilo = $Estilos[ 0 ];
	$html = <<<CONT
<html xmlns="http://www.w3.org/1999/xhtml" lang="es" xml:lang="es"> 
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Listado de convocatorias</title>  
	<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
	<link type="text/css" rel="stylesheet" media="all" href="$estilo" />
		
</head>
<body>
<h3>LISTADO DE CONVOCATORIAS</h3>
$listadoHTML
</body>
CONT;
	return $html;
}

function frmConsultarObras() {
    
    $tipo_sel = isset($_POST['tipo_obra']) ? $_POST['tipo_obra'] : '';
    $tipos = listaTiposObras($tipo_sel);
    $reporte = frmFormConsultarObras($tipo_sel);
    
    $form = <<<FORM_TIPO_OBRAS
    <form method="post">
    <table>
        <tr>
            <td>Tipo de obra:</td>
            <td>$tipos</td>
            <td><input type="submit" name="consultar_obras_btn" value="Consultar" />
        </tr>
    </table>
    </form>
    <div class="reporte_imp" id="reporte_imp_obras_cons">
    $reporte
    </div>
FORM_TIPO_OBRAS;
    return $form;
}

function obtenerObras($tipo) {
    global $BD;
    
    $cons = "select * from con_obras ";
    if (trim($tipo != '')) {
        $cons .= "where (tipo_proy = '$tipo') ";    
    }
    $cons .= "order by nombre";
    $BD->query($cons);
    $obras = $BD->getAll();
    
    return $obras;
}

function seleccionarTerminadas($pObras) {
    global $BD;
    
    $obras_sel = array();
    
    foreach ($pObras as $obra) {
        $BD->query('select programado, ejecutado '
            . 'from con_actividad a '
            . 'left outer join con_avance_fisico afis on (a.id_act = afis.actividad) '
            . 'where (obra = ' . $obra['id_obra'] . ')');
        $finalizada = true;

        if ($BD->numRows() > 0) {
            while ($reg = $BD->getNext()) {
                if (((float)$reg['programado'] - (float)$reg['ejecutado']) > 0) {
                    $finalizada = false;
                    break;
                } 
            }
        } else {
            $finalizada = false;
        }
        if ($finalizada) {
            $obras_sel[] = $obra;
        }
    }
    
    return $obras_sel;
}

function obtenerObrasParaGraf() {
    $obras = obtenerObras('');
    $obras = seleccionarTerminadas($obras);
    $datos_graf = array();
    
    foreach ($obras as $obra) {
        if (isset($datos_graf["'" . $obra['tipo_proy'] . "'"])) {
            $datos_graf[$obra['tipo_proy']]++;
        } else {
            $datos_graf[$obra['tipo_proy']] = 1;
        }
    }
    
    return $datos_graf;
}

function crearGraficoObras($datos) {
    require_once ("lib/libchart/classes/libchart.php");
    
    $chart = new PieChart(850, 450);

	$dataSet = new XYDataSet();
	
    foreach ($datos as $tipo => $cant) {
        $dataSet->addPoint(new Point($tipo, $cant));    
    }
    
	$chart->setDataSet($dataSet);

	$chart->setTitle("ESTADISTICA DE OBRAS TERMINADAS POR TIPOS");
    $nombre_img = "imagenes/estadistica.png";
	$chart->render($nombre_img);
    
    return $nombre_img;
}

function frmFormConsultarObras($tipo) {
    
    $obras = obtenerObras($tipo);
    $obras = seleccionarTerminadas($obras);
    $datos_graf = obtenerObrasParaGraf();
    
    $html = '';
    if (count($obras) > 0) {
        $html .= '<div style="padding: 0px; padding-top: 30px;">';
        $html .= '<table class="listado" border="0" cellspacing="0">'
            . '<tr><th>Nro.</th><th>OBRA</th><th>TIPO</th></tr>';
        $count = 1;
        foreach ($obras as $obra) {
            $html .= '<tr>'
                . '<td align="center">' . $count . '</td>'
                . '<td>' . $obra['nombre'] . '</td>'
                . '<td>' . $obra['tipo_proy'] . '</td>'
                . '</tr>';
                $count++;
        }
        $html .= '</table></div>';
    }
    
    $grafico = crearGraficoObras($datos_graf);
    $html .= '<div style="padding: 0px; padding-top: 30px;">';
    $html .= '<img alt="Estad&iacute;stica de obras terminadas"  title="Estad&iacute;stica de obras terminadas" src="' 
        . $grafico 
        . '" style="border: 1px solid gray;"/>';
    $html .= '</div>';
    
    return $html;
}

function listaTiposObras($select = '') {
    global $BD;
    
    $html = '<select name="tipo_obra">';
    
    $html .= '<option selected="selected" value="">-- Todos --</option>';
    $BD->query('select distinct(tipo_proy) as tipo '
        . 'from con_obras '
        . 'order by tipo;');
    while ($reg = $BD->getNext()) {
        $selected = $reg['tipo'] == $select ? ' selected="selected" ' : '';
        $html .= '<option value="' . $reg['tipo'] . '" ' . $selected . '>' 
            . $reg['tipo'] . '</option>';
    };    
    $html .= '</select>';
    
    return $html;
}