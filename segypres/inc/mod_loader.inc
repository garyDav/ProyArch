<?php

/**
 * inicio.inc -> crearPagina();
 */
function modInicioDeSesion() {
	global $PARAMETROS;
	global $pag_contenido;
	global $GlobalIDSesion;
	
	$PARAMETROS['modulo'] = 'usuario';
	$PARAMETROS['accion'] = 'ini_ses';
	$PARAMETROS['id_sesion'] = $GlobalIDSesion;
	cargarModulo();
}

/**
 * modInicioDeSesion()
 * inicio.inc -> crearPagina()
 * Funcion que procesa las peticiones ?r=abc/def
 */
function cargarModulo() {
	require_once('metodos.inc');
	
	global $PARAMETROS;
	global $pag_contenido;
        
	if ( isset($PARAMETROS['modulo']) ) //si existe
        {
            
                #Comprueba que modulos existan
                if( is_readable( 'modulos/' . $PARAMETROS['modulo'] . '/' . $PARAMETROS['modulo'] . '.mod' ) )
                {
                    require_once('modulos/' . $PARAMETROS['modulo'] . '/' . $PARAMETROS['modulo'] . '.mod');                    
                }
                else
                {
                    die("<H2>ERROR CRITICO: Modulo [".'modulos/' . $PARAMETROS['modulo'] . '/' . $PARAMETROS['modulo'] . '.mod'."] no existe!!!</H2>");
                }
                		
                #Inicia modulo
		$ret = call_user_func("iniciarModulo_{$PARAMETROS['modulo']}");
                
		if ( esURL($ret) ) 
                {
			$pars = explode('/', str_replace('@', '', $ret));
			$PARAMETROS['modulo'] = (isset($pars[0]))? $pars[0]: '';
			$PARAMETROS['accion'] = (isset($pars[1]))? $pars[1]: '';
			$i = 2;
			$url = $PARAMETROS['modulo'] . '/' . $PARAMETROS['accion'];
			$param = isset($pars[$i])? $pars[$i]: null;
			while (isset($param)) {
				$url .= '/' . $param;
				if (isset($pars[$i + 1])) {
					$param = $pars[++$i];
				} else {
					$param = null;
				}
			}
			$PARAMETROS['r'] = $url;
			cargarModulo();
		} else {                    
		     $pag_contenido = $ret;
		}
	}
}
