<?php

require_once 'inc/inicio.inc';

if (!existeConexionBD()) {
	
	die ('<H2>No se puede conectar con el servidor de base de datos!!!</H2>');
}

crearPagina();