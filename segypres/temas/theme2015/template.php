<!DOCTYPE html>
<html>
<head>    
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>     
    <title><?php echo $pag_titulo; ?></title>  
	<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
	<?php echo $pag_estilos; ?>
	<?php echo $pag_scripts; ?>
</head>
<body>
    <div class="wrapper">
        
        <!-- Header -->
        <header class="main-header">
            <!-- Logo -->
            <a href="">
              MATERSA
            </a>
        </header>
        
        <!-- Left side column. contains the logo and sidebar -->
        <div class="main-sidebar">
            <?php echo $pag_col_izq; ?>
        </div>
        
        <!-- Content Wrapper. Contains page content -->
        <div class="content-wrapper">
            
              <!-- Main content -->
              <section class="content">
                    <?php echo $div_mensajes; ?>
                    <?php echo $div_errores; ?>
                    <?php echo $pag_contenido; ?>
              </section>
              
        </div>
        
         <!-- Main Footer -- >
         <footer class="main-footer">
             <section class="footer">
                 <strong>Copyright © 2014-2015</strong> jc-Mouse. All rights reserved.    
             </section>             
         </footer>-->
    </div>
</body>
</html>
