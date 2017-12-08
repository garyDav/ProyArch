<?php

require_once 'bd_metds.inc';

global $BD;
global $Errores;
global $Mensajes;
global $Permisos;

/**
 * Funcion que controla la existencia de la conexion a la base de datos
 * index.php
 * 
 */
function existeConexionBD() {
	
	global $BD;
	$BD = conectarConBD();

	return !($BD == null);
}

/**
 * index.php
 */
function crearPagina() {
	include_once ('logs.inc');
	require_once 'sesiones.inc';
	require_once 'mod_loader.inc';
	global $Errores;
	global $Mensajes;
	global $USR;
	$USR = array();
	$Errores = array();
	$Mensajes = array();
	
	if ( !existeSesion() ) // Si no existe sesion 
        {		
		modInicioDeSesion();
		crearPaginaFull();
		return;
	}
        else 
        {
		include_once('metodos.inc');
		
		global $PARAMETROS;
		$PARAMETROS = $_REQUEST;
		$PARAMETROS['modulo'] = parametros( 1 );
		$PARAMETROS['accion'] = parametros( 2 );
                
                #print_r($PARAMETROS);                
                
		if ($PARAMETROS['modulo'] == '') {
			$PARAMETROS['modulo'] = 'paginas';
		} 
                elseif ($PARAMETROS['modulo'] == 'clean') #???
                {
			global $pag_contenido;
			
			$PARAMETROS['modulo'] = $PARAMETROS['accion'];
			$PARAMETROS['accion'] = parametros( 3 );
			$arr = explode('/', $PARAMETROS['r']);
			array_shift($arr);
			$PARAMETROS['r'] = implode('/', $arr);
			cargarModulo();
			echo $pag_contenido;
			return;
		}	
                
		cargarModulo();
		crearPaginaFull();
	}
}

/**
 * crearPagina();
 * Funcion que carga los datos en el codigo HTML
 * 
 */
function crearPaginaFull() {
	global $pag_titulo;
	global $pag_scripts;
	global $pag_estilos;
	global $pag_contenido;
	global $pag_cabecera;
	global $pag_col_der;
	global $pag_col_izq;
	global $pag_pie;
	global $Tema;
	global $div_errores;
	global $div_mensajes;
	global $menu_principal;
	
	$pag_titulo = obtenerTituloApp();
	$pag_scripts = crearScripts();
	$pag_estilos = crearEstilos();
	$pag_cabecera = crearEncabezado();
	$pag_col_izq = crearColIzq();
	$pag_col_der = crearColDer();
	$pag_pie = crearPiePag();
	$div_errores = crearErrores();
	$div_mensajes = crearMensajes();
	require_once($Tema);
}

function obtenerTituloApp() {
	return "Registro de obras civiles";
}

function crearScripts() {
	global $Scripts;
	$html = '';
	foreach ($Scripts as $script) {
		$html .= "<script type=\"text/javascript\" src=\"$script\"></script>\n";
	}
	return $html;
}

function crearEstilos() {
	global $Estilos;
	$estilos_html = '';
	foreach ($Estilos as $estilo) {
		$estilos_html .= "<link type=\"text/css\" rel=\"stylesheet\" media=\"all\" href=\""
				. $estilo . "\" />\n";
	}
	return $estilos_html;
}

function crearEncabezado() {
	/*
	global $Tema;
	$ruta_tema = dirname($Tema);
	return "<img src=\"$ruta_tema/imagenes/logo.gif\">";
	*/
	return "";
}

function crearColIzq() {
	return crearMenuPrincipal();
}

function crearColDer() {
	return "";
}

function crearPiePag() {
	return "";
}

function crearErrores() {
	global $Errores;
	if (count($Errores) > 0) {
		$html = "<div id=\"div_error\"> \n";
		$html .= "<ul class=\"ul_mensajes\">\n";
		foreach($Errores as $err) {
			$html .= "<li>$err</li>\n";
		}
		$html .= "</ul>";
		$html .= "</div> \n";
		return $html;
	} else {
		return "";
	}
}

function crearMensajes() {
	global $Mensajes;
	if (count($Mensajes) > 0) {
		$html = "<div id=\"div_mensajes\"> \n";
		$html .= "<ul class=\"ul_mensajes\">\n";
		foreach($Mensajes as $men) {
			$html .= "<li>$men</li>\n";
		}
		$html .= "</ul>";
		$html .= "</div> \n";
		return $html;
	} else {
		return "";
	}
}

/**
 * Menu principal
 */
function crearMenuPrincipal() {
	global $Permisos;
	$html = "<div id=\"menu_principal\">\n";
	$html .= "<ul class=\"ul_menu\">\n";
        #dependiendo de los permisos del usuario crea el menu respectivo
	if ( is_array($Permisos) ) {
		if ( count($Permisos) > 0 ) 
                {
			foreach ( $Permisos as $perm ) {
				if ($perm['tit_grup'] != '') {
					$html .= "<li class=\"tit_menu\">"
						. $perm['tit_grup']
						. "</li>";
				}
				$html .= "<li>"
					. enlace('?r=' . $perm['url_mod'], $perm['desc'], $perm['desc'])
					. "</li>\n";
			}
                        
			global $USR;
			$id_usr = $USR['id'];
			$html .= "<li class=\"tit_menu\">Sesi&oacute;n</li>";
			$html .= "<li>" . enlace("?r=usuario/campass/$id_usr", 'Cambiar la contrase&ntilde;a', 'Cambiar la contrase&ntilde;a de usuario')
				. "</li>";
			$html .= "<li>" . enlace('?r=usuario/salir', 'Salir', 'Cerrar la sesi&oacute;n')
				. "</li>";
		}
                ################ #menu prueba ####################
                //$html .= "<li>" . enlace('?r=mimodulo/ver', 'Mi Modulo', 'ayuda'). "</li>";
                ##################################################
	}
        else // menu de inicio de sesion 
        {
		$html .= "<li>"	. enlace('?r=usuario/ini_ses', 'Iniciar sesi&oacute;n', 'Iniciar sesi&oacute;n')
				. "</li>\n";
	}
	$html .= "</ul>";
	$html .= "</div>\n";
	return $html;
}
