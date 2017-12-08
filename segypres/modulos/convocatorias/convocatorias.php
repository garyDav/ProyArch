<?php

define ('ID_ROL_CONV', 6);
define ('ID_ROL_MOD', 8);
#
define ('CONV_APROBAR', 'convocatorias/aprobar/');
define ('CONV_DESAPROBAR', 'convocatorias/desaprobar/');
define ('CONV_TERMINAR', 'convocatorias/terminar/');

define ('CONV_LISTAR', 'convocatorias/listar/');
#
//define ('CONV_LISTAR', 'convocatorias/listar/');
define ('CONV_LISTAR_HTML', 'clean/convocatorias/listarhtml/');
define ('CONV_NUEVO', 'convocatorias/nuevo');
define ('CONV_MOSTRAR', 'convocatorias/mostrar/');
define ('CONV_EDITAR', 'convocatorias/editar/');
define ('CONV_ELIMINAR', 'convocatorias/eliminar/');
define ('MOD_IMP_PRESUP', 'modulo/presupuesto/imprimir/');
define ('MOD_IMP_PRESUP_HTML', 'clean/modulo/presupuesto/imprimir_html/');

/**
 * Acciones modulo convocatorias index.php?r=convocatorias/ACCION
 * mod_loader.inc -> cargarModulo()
 */
function iniciarModulo_convocatorias() 
{
	global $PARAMETROS;
	$id = parametros(3);
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'listar')
        {
	     return listarConvs( $id );
	}elseif ($PARAMETROS['accion'] == 'mostrar') {
		return mostrarConv($id);
	} elseif ($PARAMETROS['accion'] == 'editar') {
		return editarConv($id);
	} elseif ($PARAMETROS['accion'] == 'nuevo') {
		return editarConv('0');
	} elseif ($PARAMETROS['accion'] == 'eliminar') {
		return eliminarConv($id);
	} elseif ($PARAMETROS['accion'] == 'listarhtml') {
		return listaConvsHTML();
	}
        
        elseif ($PARAMETROS['accion'] == 'aprobar') {
		return cambiarEstadoConvs( $id, "Aprobado" );
	} elseif ($PARAMETROS['accion'] == 'terminar') {
		return cambiarEstadoConvs( $id, "Terminado" );
	} elseif ($PARAMETROS['accion'] == 'desaprobar') {
		return cambiarEstadoConvs( $id, "Rechazado" );
	}
}

//---> nuevos metodos


/**
 * Marca una convocatoria como aprobado
 * @param int $id 
 * @param String $estado Pendiente | Aprobado | Terminado
 */
function cambiarEstadoConvs( $id, $estado="Pendiente" ){
    global $BD;
     global $USR;
    //actualiza estado
    $BD->query(" UPDATE con_convocatoria SET estado='{$estado}' WHERE id_conv=". $id );
    
    registrarLog($USR['id'], 'convocatoria', 'con_convocatoria', "Cambio de estado de convocatoria [ID: {$id}] a {$estado}");    
    
    $msg = " Convocatoria [ID: {$id}] cambio estado a \"{$estado}\" ";        
    $html = "<div id=\"div_mensajes\"> 
                <ul class=\"ul_mensajes\">
                    <li>{$msg}</li>
                </ul></div> ";
    
    //retorna a listado de convocatorias
    return $html . listarConvs();
}
//---> nuevos metodos : end


/**
 * Funcion para listar en una tabla 
 * @param String $estado parametro de filtrado 
 */
function listarConvs( $estado=null ) 
{
	global $BD;
        
        if( $estado == null ){
            $BD->query("SELECT * FROM con_convocatoria ORDER BY tipo, entidad, objeto");    
        }else{
            if( $estado == 0 ){ $estado = ''; }
            if( $estado == 1 ){ $estado = 'Aprobado'; }
            if( $estado == 2 ){ $estado = 'Rechazado'; }
            if( $estado == 3 ){ $estado = 'Terminado'; }
                        
            $BD->query("SELECT * FROM con_convocatoria WHERE estado like '%{$estado}%' ORDER BY tipo, entidad, objeto");
        }
        
	
	$html = "<div id=\"div_lista_convocatorias\">\n<h1>Listado de convocatorias</h1>\n";
        
        $html .= "<div class=\"submenu-1\"><strong>Estado: </strong> ".
                enlace('?r=' . CONV_LISTAR . "0", 'Todos', "Todas las convocatorias")." | " .
                enlace('?r=' . CONV_LISTAR . "1" , 'Aprobados', "Convocatorias aprobadas")." | " .
                enlace('?r=' . CONV_LISTAR . "2" , 'Rechazados', "Convocatorias rechazadas")." | " .
                enlace('?r=' . CONV_LISTAR . "3" , 'Terminados', "Convocatoriasterminadas")." | " .
                "</div>";        
        
	$accs_cab = "<div class=\"submenu-2\">";
	if (tienePermiso(ID_ROL_CONV, 'nuevo')) {
		$accs_cab .= enlace('?r=' . CONV_NUEVO, 'Nuevo', "Registrar una nueva convocatoria");
	}
	if (tienePermiso(ID_ROL_CONV, 'ver')) {
		$accs_cab .= " | " . enlace('?r=' . CONV_LISTAR_HTML, 'HTML', 
				"Mostrar el listado de convocatorias en formato HTML", "", "_BLANK") . "</div>";
	}
                
	$html .= $accs_cab . "</h2>";
	if ($BD->numRows() > 0) {
		$html .= "<div class=\"box-table\"><table class=\"listado\">\n"
			. "<tr class=\"tbhead\">\n"
			. "<th>Estado</th>\n"
                        . "<th>Entidad</th>\n"
			. "<th>Tipo</th>\n"
			. "<th>Objeto</th>\n"
			. "<th>cuce</th>\n"
			. "<th>Inicio</th>\n"
			. "<th>Duraci&oacute;n</th>\n"
			. "<th>Fin</th>\n"
			. "<th>Acciones</th>\n"
			. "</tr>\n";
		while ($reg = $BD->getNext()) 
                {
			$id = $reg['id_conv'];
			$acciones = array();
			if (tienePermiso(ID_ROL_CONV, 'ver')) {
				$acciones[] = enlace('?r=' . CONV_MOSTRAR . $id, '<img src="imagenes/ic_explore_black_18dp.png" alt=""/>', "Ver los datos de la convocatoria: {$reg['objeto']} | {$reg['entidad']}");
			}
			if (tienePermiso(ID_ROL_MOD, 'ver')) {
				//$acciones[] = enlace('?r=' . MOD_IMP_PRESUP . $id, 'Presupuesto', "Imprimir el presupuesto de la convocatoria: {$reg['objeto']} | {$reg['entidad']}");
                                //$acciones[] = enlace('?r=' . MOD_IMP_PRESUP . $id, 'Presupuesto', "Imprimir el presupuesto de la convocatoria: {$reg['objeto']} | {$reg['entidad']}");                                
                                $acciones[] = enlace('?r=' . MOD_IMP_PRESUP . $id, '<img src="imagenes/ic_account_balance_black_18dp.png" alt=""/>', "Imprimir el presupuesto de la convocatoria: {$reg['objeto']} | {$reg['entidad']}");                                
			}
                        
			if (tienePermiso(ID_ROL_MOD, 'ver')) {
				//$acciones[] = enlace('?r=' . MOD_IMP_PRESUP_HTML . $id, 'HTML', "Imprimir el presupuesto de la convocatoria: {$reg['objeto']} | {$reg['entidad']}", "", "_BLANK");
                                $acciones[] = enlace('?r=' . MOD_IMP_PRESUP_HTML . $id, '<img src="imagenes/ic_html_black_18dp.png" alt=""/>', "Imprimir el presupuesto de la convocatoria: {$reg['objeto']} | {$reg['entidad']}", "", "_BLANK");
			}
			if (tienePermiso(ID_ROL_CONV, 'modificar')) {
				//$acciones[] = enlace('?r=' . CONV_EDITAR . $id, 'Editar', "Editar los datos de la convocatoria: {$reg['objeto']} | {$reg['entidad']}");
                                $acciones[] = enlace('?r=' . CONV_EDITAR . $id, '<img src="imagenes/ic_edit_black_18dp.png" alt=""/>', "Editar los datos de la convocatoria: {$reg['objeto']} | {$reg['entidad']}");
			}
			if (tienePermiso(ID_ROL_CONV, 'eliminar')) {
				//$acciones[] = enlace('?r=' . CONV_ELIMINAR . $id, 'Eliminar', "Eliminar la convocatoria: {$reg['objeto']} | {$reg['entidad']}");
                                $acciones[] = enlace('?r=' . CONV_ELIMINAR . $id, '<img src="imagenes/ic_delete_black_18dp.png" alt=""/>', "Eliminar la convocatoria: {$reg['objeto']} | {$reg['entidad']}");
			}                        
                        
			$html .= "<tr>\n"
                         . "<td class=\"{$reg['estado']}\" ><img src=\"imagenes/{$reg['estado']}.png\" alt=\"{$reg['estado']}\" title=\"{$reg['estado']}\" width=\"24\" height=\"24\" /></td>"
			. "<td class=\"{$reg['estado']}\" >{$reg['entidad']}</td>"
			. "<td class=\"{$reg['estado']}\" >{$reg['tipo']}</td>"
			. "<td class=\"{$reg['estado']}\" >{$reg['objeto']}</td>"
			. "<td class=\"{$reg['estado']}\" width=\"140\">{$reg['cuce']}</td>"
			. "<td class=\"{$reg['estado']}\" width=\"70\">{$reg['fecha_inicio']}</td>"
			. "<td class=\"{$reg['estado']}\" >{$reg['duracion']}</td>"
			. "<td class=\"{$reg['estado']}\" width=\"70\">{$reg['fecha_fin']}</td>"
			. "<td class=\"{$reg['estado']}\" width=\"144\" >" . implode('|', $acciones)
			. "</td>"
			. "</tr>\n";
		}
		$html .= "</table></div>";
	} else {
		$html .= mensajeNoExistenRegistros();
	}
	$html .= "</div>";
	return $html;
}

/**
 * Metodo que muestra una convocatoria en pantalla
 * @param int $int Identificadorm unico de convocatoria
 */
function mostrarConv( $id ) {
	require_once('inc/conversiones.inc');
	global $BD;
	$BD->query("select * from con_convocatoria where (id_conv = $id)");
	$reg = $BD->getNext();
	$link_ret = enlace('?r=' . CONV_LISTAR, 'Regresar', 'Regresar al listado de convocatorias');
	//nuevos comandos
        $cmd_aprobar = enlace('?r=' . CONV_APROBAR . $id , 'Aprobar', 'Aprueba una convotaria');
        $cmd_desaprobar = enlace('?r=' . CONV_DESAPROBAR . $id , 'Desaprobar', 'Desaprueba una convotaria');
        $cmd_terminar = enlace('?r=' . CONV_TERMINAR . $id , 'Terminar', 'Termina una convotaria');
        
	$f_entr = date("d/m/Y", cadenaAFecha($reg['fecha_ini_entr']));
	$f_inspec = date("d/m/Y", cadenaAFecha($reg['inspeccion']));
	$f_acla = date("d/m/Y", cadenaAFecha($reg['aclaracion']));
	$f_pres_prop = date("d/m/Y", cadenaAFecha($reg['pres_props']));
	$f_aper = date("d/m/Y", cadenaAFecha($reg['apertura_sobres']));
	$f_ini = date("d/m/Y", cadenaAFecha($reg['fecha_inicio']));
	$f_fin = date("d/m/Y", cadenaAFecha($reg['fecha_fin']));
	

	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de convocatorias</h1>\n
			<table class="tbl_formulario">
			    <tr>
			        <td><label class="etiqueta">Tipo de convocatoria:</label></td>
			        <td colspan="3">{$reg['tipo']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">CUCE:</label></td>
			        <td colspan="3">{$reg['cuce']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Nombre de la entidad:</label></td>
			        <td colspan="3">{$reg['entidad']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Objeto de contrataci&oacute;n:</label></td>
			        <td colspan="3">{$reg['objeto']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Lugar de entrega del DBC:</label></td>
			        <td>{$reg['lugar_entrega']}</td>
			        <td><label class="etiqueta">Fecha de inicio de entrega:</label></td>
			        <td>$f_entr</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Encargado de recepci&oacute;n:</label></td>
			        <td>{$reg['encargador']}</td>
			        <td><label class="etiqueta">Encargado de consultas:</label></td>
			        <td>{$reg['encargadoc']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Tel&eacute;fono:</label></td>
			        <td colspan="3">{$reg['telefono']}</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Inspecci&oacute;n previa:</label></td>
			        <td>$f_inspec</td>
			        <td><label class="etiqueta">Reuni&oacute;n de aclaraci&oacute;n:</label></td>
			        <td>$f_acla</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Presentaci&oacute;n de propuestas:</label></td>
			        <td>$f_pres_prop</td>
			        <td><label class="etiqueta">Apertura de sobres:</label></td>
			        <td>$f_aper</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Fecha de inicio:</label></td>
			        <td>$f_ini</td>
			        <td><label class="etiqueta">Fecha conclusi&oacute;n:</label></td>
			        <td>$f_fin</td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta">Duraci&oacute;n:</label></td>
			        <td colspan="3">{$reg['duracion']} (d&iacute;as)</td>
			    </tr>
			</table>
		</div>
                <div>$cmd_aprobar | $cmd_desaprobar | $cmd_terminar</div>     
		<div class="div_normal">$link_ret</div>
MOSTREG;
	return $html;
}

/**
 * 
 */
function editarConv($id) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;	
        
	if (!isset($PARAMETROS['id_reg'])) {
		return formEdConv($id);
	} else {
		if (!existenErroresConv($PARAMETROS)) {                         
                    return guardarConv($PARAMETROS);
		} else {
			return formEdConv($id, true);
		}
	}
}

/**
 * @param type $id Description
 * @param boolean $errores
 */
function formEdConv($id, $errores = false) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
	
	if (!$errores) {
		$BD->query("select * from con_convocatoria where (id_conv = $id)");
		$reg = $BD->getNext();		
                /*$f_entr = date("d/m/Y", cadenaAFecha($reg['fecha_ini_entr']));
                $f_inspec = date("d/m/Y", cadenaAFecha($reg['inspeccion']));
		$f_acla = date("d/m/Y", cadenaAFecha($reg['aclaracion']));
		$f_pres_prop = date("d/m/Y", cadenaAFecha($reg['pres_props']));
		$f_aper = date("d/m/Y", cadenaAFecha($reg['apertura_sobres']));
		$f_ini = date("d/m/Y", cadenaAFecha($reg['fecha_inicio']));
		$f_fin = date("d/m/Y", cadenaAFecha($reg['fecha_fin']));*/
                $f_entr = date("Y-m-d", cadenaAFecha($reg['fecha_ini_entr']));                
		$f_inspec = date("Y-m-d", cadenaAFecha($reg['inspeccion']));
		$f_acla = date("Y-m-d", cadenaAFecha($reg['aclaracion']));
		$f_pres_prop = date("Y-m-d", cadenaAFecha($reg['pres_props']));
		$f_aper = date("Y-m-d", cadenaAFecha($reg['apertura_sobres']));
		$f_ini = date("Y-m-d", cadenaAFecha($reg['fecha_inicio']));
		$f_fin = date("Y-m-d", cadenaAFecha($reg['fecha_fin']));
	} else {
                //recupera informacion POST
		$reg = array();
		$f_entr = $PARAMETROS['fecha_ini_entr'];
		$f_inspec = $PARAMETROS['inspeccion'];
		$f_acla = $PARAMETROS['aclaracion'];
		$f_pres_prop = $PARAMETROS['pres_props'];
		$f_aper = $PARAMETROS['apertura_sobres'];
		$f_ini = $PARAMETROS['fecha_inicio'];
		$f_fin = $PARAMETROS['fecha_fin'];
		
		$reg['tipo'] = $PARAMETROS['tipo'];
		$reg['cuce'] = $PARAMETROS['cuce'];
		$reg['entidad'] = $PARAMETROS['entidad'];
		$reg['objeto'] = $PARAMETROS['objeto'];
		$reg['lugar_entrega'] = $PARAMETROS['lugar_entrega'];
		$reg['encargadoc'] = $PARAMETROS['encargadoc'];
		$reg['encargador'] = $PARAMETROS['encargador'];
		$reg['telefono'] = $PARAMETROS['telefono'];
		$reg['duracion'] = $PARAMETROS['duracion'];
	}
	//$link_ret = enlace('?r=' . CONV_LISTAR, 'Cancelar', 'Regresar al listado de convocatorias', 'enlace_boton');
	$link_ret = "<a href=\"?r=".CONV_LISTAR ."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
        
        $lint_ed = CONV_EDITAR;
        
	$html = <<<MOSTREG
		<div id="div_mostrar_datos">\n
			<h1>Registro de convocatorias </h1>\n
			<form method="post" action="?r={$lint_ed}$id" name="form_edt_convs">
			<input type="hidden" value="$id" name="id_reg">
                                
                        <div class="conv_1">
                                <h3>Datos del Proceso</h3>
                            <table>        
                                <tr>
                                    <td><label class="etiqueta" for="tipo">Tipo de convocatoria:</label></td>
                                    <td colspan="3"><input type="text" name="tipo" value="{$reg['tipo']}" 
			        	maxlength="50" size="50" class="edt_form"/></td>
                                </tr>
                                <tr>
                                    <td><label class="etiqueta" for="cuce">CUCE:</label></td>
                                    <td colspan="3">
                                        <input type="text" name="cuce" value="{$reg['cuce']}" 
                                        placeholder="00-0000-00-000000-0-0"  pattern="[0-9]{2}-[0-9]{4}-[0-9]{2}-[0-9]{6}-[0-9]{1}-[0-9]{1}" 
                                        title="CUCE: 00-0000-00-000000-0-0"
			        	maxlength="35" size="35" class="edt_form"/></td>
                                </tr>
                                <tr>
                                    <td><label class="etiqueta" for="cuce">Nombre de la entidad:</label></td>
                                    <td colspan="3"><input type="text" name="entidad" value="{$reg['entidad']}" 
                                            maxlength="200" size="60" class="edt_form"/></td>
                                </tr>
                                <tr>
                                    <td><label class="etiqueta" for="objeto">Objeto de contrataci&oacute;n:</label></td>
                                    <td colspan="3"><input type="text" name="objeto" value="{$reg['objeto']}" 
                                            maxlength="500" size="60" class="edt_form"/></td>
                                </tr>
                            </table>
                        </div>        
                         
                        <div class="conv_1">
                             <h3>Información del documento base de contratación</h3>
                             <table>
                                <tr>
                                    <td><label class="etiqueta" for="lugar_entrega">Lugar de entrega del DBC:</label></td>
                                    <td><input type="text" name="lugar_entrega" value="{$reg['lugar_entrega']}" 
                                            maxlength="200" size="25" class="edt_form"/></td>
                                    <td><label class="etiqueta" for="fecha_ini_entr">Fecha de inicio de entrega:</label></td>
                                    <td><input type="date" name="fecha_ini_entr" value="$f_entr"
                                            maxlength="10"  size="10" class="edt_form" /></td>
                                </tr>
                                <tr>
                                    <td><label class="etiqueta" for="encargador">Encargado de recepci&oacute;n:</label></td>
                                    <td><input type="text" name="encargador" value="{$reg['encargador']}" 
                                            maxlength="50" size="30" class="edt_form"/></td>
                                    <td><label class="etiqueta" for="encargadoc">Encargado de consultas:</label></td>
                                    <td><input type="text" name="encargadoc" value="{$reg['encargadoc']}" 
                                            maxlength="50" size="30" class="edt_form"/></td>
                                </tr>
                                <tr>
                                    <td><label class="etiqueta" for="telefono">Tel&eacute;fono:</label></td>
                                    <td colspan="3"><input type="text" name="telefono" value="{$reg['telefono']}" 
                                            maxlength="25" size="20" class="edt_form"/></td>
                                </tr>     
                             </table>                                    
                        </div>
                                    
                        <div class="conv_1">
                            <table>
                                <h3>Fechas establecidas</h3>
                                <tr>
                                    <td><label class="etiqueta" for="inspeccion">Inspecci&oacute;n previa:</label></td>
                                    <td><input type="date" name="inspeccion" value="$f_inspec" 
                                            maxlength="17"  size="15" class="edt_form"/></td>
                                    <td><label class="etiqueta" for="aclaracion">Reuni&oacute;n de aclaraci&oacute;n:</label></td>
                                    <td><input type="date" name="aclaracion" value="$f_acla" 
                                            maxlength="17"  size="15" class="edt_form"/></td>
                                </tr>
                                <tr>
                                    <td><label class="etiqueta" for="pres_props">Presentaci&oacute;n de propuestas:</label></td>
                                    <td><input type="date" name="pres_props" value="$f_pres_prop" 
                                            maxlength="17"  size="15" class="edt_form"/></td>
                                    <td><label class="etiqueta" for="apertura_sobres">Apertura de sobres:</label></td>
                                    <td><input type="date" name="apertura_sobres" value="$f_aper" 
                                            maxlength="17"  size="15" class="edt_form"/></td>
                                </tr>   
                            </table>
                        </div>
                                    
                        <div class="conv_1">
                            <h3>Periodo</h3>               
                            <table>
                              <tr>
			        <td><label class="etiqueta" for="fecha_inicio">Fecha de inicio:</label></td>
			        <td><input type="date" name="fecha_inicio" id="fecha_inicio" value="$f_ini" 
			        	maxlength="10"  size="10" class="edt_form"/></td>
			        <td><label class="etiqueta" for="fecha_fin">Fecha de conclusi&oacute;n:</label></td>
			        <td><input type="text" name="fecha_fin" id="fecha_fin" value="$f_fin" 
			        	maxlength="10"  size="10" class="edt_form"/></td>
			    </tr>
			    <tr>
			        <td><label class="etiqueta" for="duracion">Duraci&oacute;n:</label></td>
			        <td colspan="3">
                                    <input type="number" name="duracion" id="duracion"  value="{$reg['duracion']}" 
			        	maxlength="4"  size="8" class="edt_form"/> (d&iacute;as)</td>
			    </tr>   
                            </table>
                        </div> 
                        <div>
                          <table>                            
			    <tr>
			    	<td colspan="2" align="center">
			    		<input type="submit" value="Guardar" class="boton">
			    	</td>
			    	<td colspan="2" align="center">
			    		$link_ret
			    	</td>
			    </tr>                
                          </table>              
                        </div>                
			</form>
		</div>
MOSTREG;
	return $html;
}

/**
 * Valida ingreso de datos
 * @param Array $form datos de formulario
 */
function existenErroresConv($form) {
	include_once('inc/validaciones.inc');
        
	$result = false;
	if (trim($form['tipo']) == '') {
		registrarError('Debe ingresar el tipo de convocatoria.');
		$result = true;
	}
	if (trim($form['entidad']) == '') {
		registrarError('Debe ingresar el nombre de la entidad.');
		$result = true;
	}
	if (trim($form['objeto']) == '') {
		registrarError('Debe ingresar el objeto de contrataci&oacute;n.');
		$result = true;
	}
	if (trim($form['fecha_ini_entr']) != '') {
		if (!fechaValida2($form['fecha_ini_entr'])) {
			registrarError('La fecha de inicio de entrega es inv&aacute;lida.');
			$result = true;
		}
	}
	if (trim($form['inspeccion']) != '') {
		if (!fechaValida2($form['inspeccion'])) {
			registrarError('La fecha de inspecci&oacute;n previa es inv&aacute;lida.');
			$result = true;
		}
	}
	if (trim($form['aclaracion']) != '') {
		if (!fechaValida2($form['aclaracion'])) {
			registrarError('La fecha de aclaraci&oacute;n es inv&aacute;lida.');
			$result = true;
		}
	}
	if (trim($form['pres_props']) != '') {
		if (!fechaValida2($form['pres_props'])) {
			registrarError('La fecha de presentaci&oacute;n de propuestas es inv&aacute;lida.');
			$result = true;
		}
	}
	if (trim($form['apertura_sobres']) != '') {
		if (!fechaValida2($form['apertura_sobres'])) {
			registrarError('La fecha de apertura de sobres es inv&aacute;lida.');
			$result = true;
		}
	}
	if (!fechaValida2($form['fecha_inicio'])) {
		registrarError('La fecha de inicio es inv&aacute;lida.');
		$result = true;
	}
	if (!fechaValida($form['fecha_fin'])) {
		registrarError('La fecha de conclusi&oacute;n es inv&aacute;lida.');
		$result = true;
	}
	if (!esNumeroEntero($form['duracion'])) {
		registrarError('La duraci&oacute;n debe ser un valor entero.');
		$result = true;
	}
	return $result;
}

/**
 * Funcion para guardar registro de nueva convocatoria en la base de datos
 * @param Array $form Description
 */
function guardarConv($form) {
    global $BD;
    global $USR;
	if ((trim($form['id_reg']) != '') && (trim($form['id_reg']) != '0')) {//ACTUALIZACION
		/*$cons = "update con_convocatoria "
		. "set "
		. "tipo = '{$form['tipo']}', "
		. "cuce = '{$form['cuce']}', "
		. "entidad = '{$form['entidad']}', "
		. "objeto = '{$form['objeto']}', "
		. "lugar_entrega = '{$form['lugar_entrega']}', "
		. "fecha_ini_entr = '" . date("Y-m-d", cadenaAFecha2($form['fecha_ini_entr'])) . "', "
		. "encargador = '{$form['encargador']}', "
		. "encargadoc = '{$form['encargadoc']}', "
		. "telefono = '{$form['telefono']}', "
		. "inspeccion = '" . date("Y-m-d", cadenaAFecha2($form['inspeccion'])) . "', "
		. "aclaracion = '" . date("Y-m-d", cadenaAFecha2($form['aclaracion'])) . "', "
		. "pres_props = '" . date("Y-m-d", cadenaAFecha2($form['pres_props'])) . "', "
		. "apertura_sobres = '" . date("Y-m-d", cadenaAFecha2($form['apertura_sobres'])) . "', "
		. "fecha_inicio = '" . date("Y-m-d", cadenaAFecha2($form['fecha_inicio'])) . "', "
                . "fecha_fin = '" . date("Y-m-d", cadenaAFecha2($form['fecha_fin'])) . "', "
		. "duracion = {$form['duracion']} "
		. "where (id_conv = {$form['id_reg']})";*/
        
                $cons = "update con_convocatoria "
		. "set "
		. "tipo = '{$form['tipo']}', "
		. "cuce = '{$form['cuce']}', "
		. "entidad = '{$form['entidad']}', "
		. "objeto = '{$form['objeto']}', "
		. "lugar_entrega = '{$form['lugar_entrega']}', "
		. "fecha_ini_entr = '" . date("Y-m-d", cadenaAFecha3($form['fecha_ini_entr'])) . "', "
		. "encargador = '{$form['encargador']}', "
		. "encargadoc = '{$form['encargadoc']}', "
		. "telefono = '{$form['telefono']}', "
		. "inspeccion = '" . date("Y-m-d", cadenaAFecha3($form['inspeccion'])) . "', "
		. "aclaracion = '" . date("Y-m-d", cadenaAFecha3($form['aclaracion'])) . "', "
		. "pres_props = '" . date("Y-m-d", cadenaAFecha3($form['pres_props'])) . "', "
		. "apertura_sobres = '" . date("Y-m-d", cadenaAFecha3($form['apertura_sobres'])) . "', "
		. "fecha_inicio = '" . date("Y-m-d", cadenaAFecha3($form['fecha_inicio'])) . "', "
                . "fecha_fin = '" . date("Y-m-d", cadenaAFecha3($form['fecha_fin'])) . "', "
		. "duracion = {$form['duracion']} "
		. "where (id_conv = {$form['id_reg']})";
                
        registrarLog($USR['id'], 'convocatoria', 'con_convocatoria', 
			"Convocatoria actualizada: [ID: {$form['id_reg']}, Tipo: {$form['tipo']}, "
            . "CUCE: {$form['cuce']}, Entidad: {$form['entidad']}, Objeto: {$form['objeto']}, "
            . "Lugar entrega: {$form['lugar_entrega']}, Fecha Ini. Entr.: {$form['fecha_ini_entr']}, "
            . "Encargado Recep: {$form['encargador']}, Encargado Cons: {$form['encargadoc']}, "
            . "Telf.: {$form['telefono']}, Inspeccion: {$form['inspeccion']}, "
            . "Aclaracion: {$form['aclaracion']}, Presentacion Props.: {$form['pres_props']}, "
            . "Apertura sobres: {$form['apertura_sobres']}, Inicio: {$form['fecha_inicio']}, "
            . "Fin: {$form['fecha_fin']}, Duracion: {$form['duracion']}]");
	} else { //INSERT 
		/*$cons = "insert into con_convocatoria (tipo, cuce, entidad, objeto, "
		. "lugar_entrega, fecha_ini_entr, encargador, encargadoc, "
		. "telefono, inspeccion, aclaracion, pres_props, "
		. "apertura_sobres, fecha_inicio, fecha_fin, duracion, usuario) "
		. "values ('{$form['tipo']}', '{$form['cuce']}', '{$form['entidad']}', '{$form['objeto']}', "
		. "'{$form['lugar_entrega']}', "
		. "'" . date("Y-m-d", cadenaAFecha2($form['fecha_ini_entr'])) . "', "
		. "'{$form['encargador']}', '{$form['encargadoc']}', '{$form['telefono']}', "
		. "'" . date("Y-m-d", cadenaAFecha2($form['inspeccion'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha2($form['aclaracion'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha2($form['pres_props'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha2($form['apertura_sobres'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha2($form['fecha_inicio'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha2($form['fecha_fin'])) . "', "
		. "'{$form['duracion']}', {$USR['id']})";
                */
      $cons = "insert into con_convocatoria (tipo, cuce, entidad, objeto, "
		. "lugar_entrega, fecha_ini_entr, encargador, encargadoc, "
		. "telefono, inspeccion, aclaracion, pres_props, "
		. "apertura_sobres, fecha_inicio, fecha_fin, duracion, usuario) "
		. "values ('{$form['tipo']}', '{$form['cuce']}', '{$form['entidad']}', '{$form['objeto']}', "
		. "'{$form['lugar_entrega']}', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['fecha_ini_entr'])) . "', "
		. "'{$form['encargador']}', '{$form['encargadoc']}', '{$form['telefono']}', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['inspeccion'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['aclaracion'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['pres_props'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['apertura_sobres'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['fecha_inicio'])) . "', "
		. "'" . date("Y-m-d", cadenaAFecha3($form['fecha_fin'])) . "', "
		. "'{$form['duracion']}', {$USR['id']})";
                
        registrarLog($USR['id'], 'convocatoria', 'con_convocatoria', 
			"Convocatoria Nueva: [ID: (Nuevo), Tipo: {$form['tipo']}, "
            . "CUCE: {$form['cuce']}, Entidad: {$form['entidad']}, Objeto: {$form['objeto']}, "
            . "Lugar entrega: {$form['lugar_entrega']}, Fecha Ini. Entr.: {$form['fecha_ini_entr']}, "
            . "Encargado Recep: {$form['encargador']}, Encargado Cons: {$form['encargadoc']}, "
            . "Telf.: {$form['telefono']}, Inspeccion: {$form['inspeccion']}, "
            . "Aclaracion: {$form['aclaracion']}, Presentacion Props.: {$form['pres_props']}, "
            . "Apertura sobres: {$form['apertura_sobres']}, Inicio: {$form['fecha_inicio']}, "
            . "Fin: {$form['fecha_fin']}, Duracion: {$form['duracion']}]");
	}
	if ($BD->query($cons)) {
		registrarMensaje('Se ha guardado la convocatoria correctamente.');
	} else {
		registrarError("No se ha podido guardar la convocatoria. <br />{$BD->error}");
	}
	return '@' . CONV_LISTAR;
}


/**
 * Funcion para eliminar una convocatoria
 * @param int $id identificador unico de convocatoria
 * @return no tiene
 */
function eliminarConv($id) {
	require_once('inc/conversiones.inc');
	global $BD;
	global $PARAMETROS;
    global $USR;
	
	//$link_ret = enlace('?r=' . CONV_LISTAR, 'Cancelar', 'Regresar al listado de convocatorias');
        $link_ret = "<a href=\"?r=".CONV_LISTAR ."\"><input type=\"button\" value=\"Cancelar\"></a>    ";
        
	$link_elim = CONV_ELIMINAR;
	$form = <<<FORMELIMOBRA
		<div class="conv_1">  
                <form method="post" action="?r=$link_elim$id" name="form_elim_conv">
                <input type="hidden" value="$id" name="id_reg">		
                <div style="width: 300px; margin: 0 auto;">
                <table border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <td colspan="2">
                          <div class="del_txt">Realmente desea eliminar esta convocatoria?</div>
                          <div class="del_txt">Este paso no se puede deshacer.</div>                
                      </td>
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
	} else { // elimna registros
		global $BD;
                
                //elimina computos metricos
                $cons = " DELETE FROM con_computo_metrico WHERE id_im IN (
                          SELECT id_it_mod FROM con_item_modulo 
                          INNER JOIN con_modulo ON modulo=id_modulo
                          WHERE convocatoria ={$id}  )";
                $BD->query($cons);
                
                //elimina avance de obra
                $cons = " DELETE FROM con_avance_financiero WHERE idim IN (
                          SELECT id_it_mod FROM con_item_modulo 
                          INNER JOIN con_modulo ON modulo=id_modulo
                          WHERE convocatoria ={$id}  ) ";
                $BD->query($cons);
                $cons = " DELETE FROM con_avance_fisico WHERE idim IN (
                          SELECT id_it_mod FROM con_item_modulo 
                          INNER JOIN con_modulo ON modulo=id_modulo
                          WHERE convocatoria ={$id}  ) ";
                $BD->query($cons);
                
                //se eliminan registros de ITEM_MODULO
                $cons = "DELETE FROM con_item_modulo WHERE modulo IN (
                            SELECT id_modulo FROM con_modulo WHERE convocatoria=$id )";
                $BD->query($cons);
                
                //se elimina registros de MODULOS
                $cons = "DELETE FROM con_modulo WHERE (convocatoria = $id)";
                $BD->query($cons);
                
                //elimina convocatoria
		$cons = "DELETE FROM con_convocatoria WHERE (id_conv = $id)";                
                registrarLog($USR['id'], 'convocatoria', 'con_convocatoria', "Convocatoria eliminada: [ID: $id]");                
		$BD->query($cons);
                
		return '@' . CONV_LISTAR;
	}
}

function obtListaConvsArr() {
	global $BD;
	$BD->query("select entidad, tipo, objeto, cuce, lugar_entrega, "
		. "fecha_ini_entr, encargador, encargadoc, telefono, "
		. "inspeccion, aclaracion, pres_props, apertura_sobres, "
		. "fecha_inicio, duracion, fecha_fin "
		. "from con_convocatoria "
		. "order by tipo, entidad, objeto");
	return $BD->getAll();
}

function obtenerListadoConvsHTML() {
	$regs = obtListaConvsArr();
	$cont = '';
	$cont .= '<table border="1" cellspacing="0" '
		. 'class="listado">';
	$cont .= '<tr style="border: 1px solid #000;">'
		. "<th>ENTIDAD</th>"
		. "<th>TIPO</th>"
		. "<th>OBJETO</th>"
		. "<th>CUCE</th>"
		. "<th>LUGAR DE ENTREGA</th>"
		. "<th>FECHA INICIAL DE ENTREGA</th>"
		. "<th>ENCARGADO RECEPCION</th>"
		. "<th>ENCARGADO DURACION</th>"
		. "<th>TELEFONO</th>"
		. "<th>INSPECCION</th>"
		. "<th>ACLARACION</th>"
		. "<th>FECHA DE PRESENTACION DE PROPUESTAS</th>"
		. "<th>APERTURA DE SOBRES</th>"
		. "<th>FECHA DE INICIO</th>"
		. "<th>DURACION</th>"
		. "<th>FECHA DE CONCLUSION</th>"
		. "</tr>";
	foreach ($regs as $reg) {
		$cont .= '<tr><td>' . implode('</td><td>', $reg) . '</td></tr>';
	}
	$cont .= "</table>";
	return $cont;
}

function listaConvsHTML() {
	$listadoHTML = obtenerListadoConvsHTML();
	global $Estilos;
    global $USR;
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
    registrarLog($USR['id'], 'convocatoria', 'con_convocatoria', 
		"Listado de convocatorias");
	return $html;
}