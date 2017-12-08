<?php
// Servidor de la base de datos
$Servidor = 'localhost';
// Nombre de la base de datos
$NombreBD = 'bd_const';
//$nombreBD = 'matersa_cons';
// Usuario de mysql
$Usuario = 'root';
//$Usuario = 'matersa';
// Clave del usuario de mysql
$Clave = 'princesa';
//$Clave = 'garydavid';
//$Clave = '8P6P3865';
// Tipo de base de datos
$TipoBD = 'mysql';
// Conexion persistente
$Persistente = false;
// Tema de la aplicacion
$Tema = 'temas/defecto/defecto.php';
#$Tema = 'temas/theme2013/defecto.php';
// Estilos css que se cargan
$Estilos[] = 'temas/defecto/defecto.css';
#$Estilos[] = 'temas/theme2013/defecto.css';
// Escripts usados en la aplicacion
//$Scripts[] = 'lib/jquery-1.7.1.min.js';
$Scripts = array( 'lib/js/jquery-1.7.1.min.js' , 'lib/js/jsegypres-1.0.1.js' );
//
// Duracion de la sesion
$ExpiracionDeSession = 900;
