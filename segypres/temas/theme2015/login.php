<html xmlns="http://www.w3.org/1999/xhtml" lang="es" xml:lang="es"> 
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title><?php echo $pag_titulo; ?></title>  
	<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
	<?php echo $pag_estilos; ?>
	<?php echo $pag_scripts; ?>
</head>
<body>
	<div id="div_cabecera">
           <?php echo $pag_cabecera; ?>
	</div>
	<div id="central">
		<div class="div_colizq">
			<?php echo $pag_col_izq; ?>
		</div>
		<div class="div_contenido">
			<div id="squeeze">
				<div id="contenido-principal">
					<?php echo $div_mensajes; ?>
					<?php echo $div_errores; ?>
					<?php echo $pag_contenido; ?>
				</div>
			</div>
		</div>
	</div>
	<div id="div_pie">
		<?php echo $pag_pie; ?>
	</div>
</body>
</html>
