<?php
global $Errores;

/**
 * @param $indice
 * @return Array con la cantidad de elmentos indicados por $indice
 */
function parametros( $indice ) {
	global $PARAMETROS;
	if (isset($PARAMETROS['r'])) {
		$cadena = $PARAMETROS['r'];
	} else {
		$cadena = '';
	}
	$lista = explode('/', $cadena);
	$lista = array_merge(array($cadena), $lista);
	if (isset( $lista[ $indice ]) ) {
		return $lista[ $indice ];
	} else {
		return null;
	}
}

/**
 * 
 */
function esURL($cadena) {
	$ret = strpos($cadena, '@');
	if ($ret === false) {
		return false;
	} else {
		if ($ret == 0) {
			return true;
		} else {
			return false;
		}
	}
}

function registrarError($error) {
	global $Errores;	
	$Errores[] = $error;
}

function registrarMensaje($mensaje) {
	global $Mensajes;	
	$Mensajes[] = $mensaje;
}

function mensajeNoExistenRegistros() {
	return "<p class=\"texto_error\">No existen registros.</p>";
}

/**
 * Funcion que retorna un hipervinculo en HTML
 * @param $url
 * @param String $titulo 
 * @param String $ayuda ALT
 * @param String $clase estilo CSS
 * @param String $objetivo  target
 */
function enlace($url, $titulo, $ayuda = "", $clase="", $objetivo="") {
	if ($clase != "") {
		$clase = "class=\"$clase\"";
	}
	if ($objetivo != "") {
		$objetivo = "target=\"$objetivo\"";
	}
	return <<<ENLACE
		<a href="$url" $clase $objetivo title="$ayuda">$titulo</a>\n
ENLACE;
}
