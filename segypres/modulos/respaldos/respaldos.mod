<?php
/**
 * RESPALDOS
 */

define ('ID_ROL_RESP', 10);
define ('RESP_LISTAR', 'respaldos/respaldo/');

/** */
function iniciarModulo_respaldos() {
	global $PARAMETROS;
	$id = parametros(3);
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'respaldo') {
		return formularioRespaldos();
	}
}

/**
 * Formularios para crear un backup del sistema
 */
function formBackup() {
    
    $nombreArch = 'matersa_backup_' . date('Ymd');
    $formBackup = <<<FORMBACK
    <div class="conv_1"> 
        <form id="frmBakcup" name="frmBackup" method="post">
            <h1>Crear una Copia de Seguridad de la Base de Datos</h1>
            <table>                
                <tr>
                    <td>Nombre de archivo:</td>
                    <td><input type="text" name="txtNombreArch" size="40" value="$nombreArch" class="edt_form" />.sql
                </tr>
                <tr>
                    <td colspan="2" align="center">
                        <input type="submit" name="btnRespaldar" value="Respaldar" class="boton" />
                    </td>
                </tr>
            </table>
        </form>
    </div>
FORMBACK;
    
    return $formBackup;
}



function formRespaldar() {
    
    $formRespaldar = <<<FORMBRESP
    <div class="conv_1"> 
        <form id="frmRestore" name="frmRestore" method="post" enctype="multipart/form-data">
            <h1>Restaurar Base de Datos</h1>
            <table>                
                <tr>
                    <td>Elija el archivo:</td>
                    <td><input type="file" name="filNombreArch" />
                </tr>
                <tr>
                    <td colspan="2" align="center">
                        <input type="submit" name="btnRestaurar" value="Restaurar" class="boton" />
                    </td>
                </tr>
            </table>
        </form>
    </div>
FORMBRESP;
    
    return $formRespaldar;
}

/**
 * Formulario para respaldos
 */
function formularioRespaldos() {
    
    global $PARAMETROS;    
    $html = '';    
    
    if ( isset($PARAMETROS['btnRespaldar']) ) {//si se presiono boton crear respaldo
        
        $nomArch = respaldarBD( $PARAMETROS['txtNombreArch'] . '.sql' );
        
        $formDesc = '<div><form>'
            . '<table>'
            . '<tr>'
            . '<td>'
            . '<a href="' . $nomArch . '" class="boton">Descargar respaldo</a>'
            . '</td>'
            . '</tr>'
            . '</table>'
            . '</form></div>';
        $html .= $formDesc;
        
    } else if ( isset($PARAMETROS['btnRestaurar']) ) {//si se presiono boton restaurar
        $html = restaurarBD();
    } else { //muestra formularios        
        $html .= formBackup() . formRespaldar();
    }

    return $html;
}


/**
 * Crea un respaldo de la base de dato en la carpeta backups/
 * @param string $pNombreArch nombre de archivo
 * @return string nombre de archivo GZ creado
 */
function respaldarBD( $pNombreArch ) {
    
    $drop_estructura = ''; //getDropEstructura();
    
    $estructura = getEstructura();//tablas
    
    $sql_datos = getDatos();//datos
    
    $sql_datos = str_replace( '`', '', $sql_datos );//elimina 
    
    $pNombreArch = 'backups/' . $pNombreArch . '.gz'; 
   
    
    
    
    $rz = gzopen($pNombreArch, 'w9');
    gzwrite($rz, $drop_estructura . "\n\r\n\r");
    gzwrite($rz, $estructura . "\n\r\n\r");
    foreach ($sql_datos as $sentencia) {
       gzwrite($rz, $sentencia . "\n\r\n\r");
    }
    gzclose($rz);
    
    return $pNombreArch;
}

/**
 * Obtiene la estructura de la base de datos
 */
function getEstructura() {
    global $BD;
    
    $sql = '';
    $tablas = getTablas();
    
    foreach ( $tablas as $tabla ) {
        $BD->query('SHOW CREATE TABLE ' . $tabla);
        $reg = $BD->getNext();
        $ifnot = substr( $reg['Create Table'] , 0, 13 ) . " IF NOT EXISTS " . substr( $reg['Create Table'] , 13); 
        //$sql .= $reg['Create Table'] . ";\n\r" ;
        $sql .= $ifnot . ";\n\r" ;
        
    }
    return $sql;
}

/**
 * Metodo que obtiene los datos de todas alas tablas y forma los INSERT para el backup
 * @return array Description
 */
function getDatos() {
    
    global $BD;
    
    $tablas = getTablas();
    $sql = array();
          
    foreach ($tablas as $tabla) {
        //obtiene registro de tabla
        $BD->query('SELECT * FROM ' . $tabla . ';');
        $datos = $BD->getAll();
        
        foreach ($datos as $registro) {
            $campos = array();
            $valores = array();
            
            foreach ($registro as $campo => $valor) {
                $campos[] = "`$campo`";
                if (trim($valor) == 'NULL')
                    $valores[] = $valor;
                else
                    $valores[] = "'" . addslashes($valor) . "'";
            }
            //forma la instruccion SQL para INSERT
            /*$sentencia = 'INSERT INTO `' . $tabla . '` ('
                . implode(',', $campos) . ') '
                . 'VALUES (' . implode(',', $valores) . ');';*/            
            $sentencia = 'INSERT INTO `' . $tabla . '` '                
                . 'VALUES (' . implode(',', $valores) . ');';
            //guarda en array
            $sql[] = $sentencia;
        }
    }
    
    return $sql;
}

/**
 * @return array nombres de todas las tablas de la base de datos
 */
function getTablas() {
    
    $tablas = array(
        'sys_rol',
        'sys_perfil',
        'sys_rol_perf',
        'sys_usuario',
        'sys_bitacora',
        //'sys_sesion',                
        'con_actividad',
        'con_valoracion',
        'con_obras',
        'con_modulo',
        'con_avance_financiero',
        'con_avance_fisico',
        'con_item',
        'con_item_modulo',        
        'con_computo_metrico',
        'con_detalle_item',
        'con_convocatoria',
    );
    return $tablas;
}

/**
 * Funcion que borra las tablas de una base de datos
 * @deprecated since version number
 */
function getDropEstructura() {
    $tablas = getTablas();
    $tablas = array_reverse($tablas);
    $sql = array();
          
    foreach ($tablas as $tabla) {
        $sql[] = 'drop table if exists ' . $tabla . ";\n\r";
    }
    
    return $sql;
}




/**
 * Sube el archivo al servidor y extrae el nombre de archivo
 * @return String $nombre_arch
 */
function obtenerNombreArchResp() {
    
    if ( is_uploaded_file($_FILES['filNombreArch']['tmp_name']) ) {
        
        $nombre_arch = "tmp/" . $_FILES['filNombreArch']['name'];
        move_uploaded_file($_FILES['filNombreArch']['tmp_name'], $nombre_arch);
        
        return $nombre_arch;
    } else {
        
        registrarError('No se ha elegido ningun archivo.');
        
        return '';
    }
}

/**
 * @deprecated since version number
 */
function eliminarEstructura() {
    global $BD;
    
    $sql = getDropEstructura();
    foreach ($sql as $sentencia) {
        $BD->execute($sentencia);
    }
}



/*

function uncompress($srcName, $dstName) {
    $sfp = gzopen($srcName, "rb");
    $fp = fopen($dstName, "w");

    while (!gzeof($sfp)) {
        $string = gzread($sfp, 4096)
        fwrite($fp, $string, strlen($string));
    }
    gzclose($sfp);
    fclose($fp);
}*/


/**
 * Función que restaura la base de datos
 * @param String $pNombreArch Nombre del archivo a restaurar
 */
function restaurarDesdeArchivo( $pNombreArch ) {
    
    //descomprime archivo
    $rz = gzopen($pNombreArch, 'r');
    //$sql_ini = gzread($rz, filesize( $pNombreArch ));
    $sql_ini = gzread($rz, 4096 *32 );
    $result = "";
    global $BD;
    
    
    //echo '' . $sql_ini . '</br></br></br></br>';
    //Elimina tablas
    //eliminarEstructura();    
    $sql = explode(";", $sql_ini );    
    //print_r($sql);
    
    gzclose($rz);
    
    
    /*$BD->execute($sql);
    if (!$BD->errors) {
        $result = "Restauraci&oacute;n finalizada.";
        registrarMensaje('Se ha realizado la restauracion correctamente.');
    } else {
        $result = '';
        foreach($BD->errors as $error) {

            $result .= '<p><span>' . $error['err_str'] . '</span></p>';
        }
        registrarError("Han ocurrido errores: \n\rRevise los siguientes mensajes:<br>");
    }*/
    
    //vacia datos de las tablas
    truncateTablas();
    
    //ingresa datos
    foreach ( $sql as $sentencia  ) {
        
        if( strlen (trim($sentencia)) > 0  ){
            $BD->execute( ''. $sentencia .'' );        
            if ( $BD->errors ) { //si existe algun error en la consulta
                $result = '';
                foreach( $BD->errors as $error ) {
                    $result .= '</br>-----' . $sentencia. '------</br> <p><span>' . $error['err_str'] . '</span></p>';
                }
                registrarError( "Han ocurrido errores: </br>Revise los siguientes mensajes:</br>" );
            }else{
                $result = "La base de datos a sido restaurada.";
            }
        }        
    }    
    return $result;
}

/**
 * vacia los datos de todas las tablas
 */
function truncateTablas(){
    
    global $BD;
    $tablas = getTablas();
    //$tablas = array_reverse($tablas);
    
    //$sql = array();
    
    foreach ( $tablas as $tabla ) {
        $sentencia = 'TRUNCATE TABLE `'.$tabla.'`';    
        $BD->execute($sentencia );        
    }
    
    //return $sql;
}



/**
 * Funcion que restaura la base de datos 
 */
function restaurarBD() {
   
    $nombre_arch = obtenerNombreArchResp();
    
    if ($nombre_arch != '') {        
        return restaurarDesdeArchivo( $nombre_arch );
    } else {
        return "Debe seleccionar un archivo de respaldo (*.sql.gz)";
    }
}