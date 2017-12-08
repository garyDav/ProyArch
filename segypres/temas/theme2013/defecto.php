<!DOCTYPE html>
<html>
<head>
<title><?php echo $pag_titulo; ?></title>
<!--[if IE]><script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script><![endif]-->
<link rel="stylesheet" type="text/css" href="../css/441741.css" />
	<?php echo $pag_estilos; ?>
	<?php echo $pag_scripts; ?>
</head>
<body>
    <div id="wrapper">
        <div id="header">
           <?php echo $pag_cabecera; ?>
        </div>
        <div id="leftcolumn">
            <?php echo $pag_col_izq; ?>
        </div>
        <div id="content">
           <?php echo $div_mensajes; ?>
           <?php echo $div_errores; ?>
	   <?php echo $pag_contenido; ?>
       </div>
        <div id="footer">
            <?php echo $pag_pie; ?>
        </div>
    </div>
</body>
</html>
