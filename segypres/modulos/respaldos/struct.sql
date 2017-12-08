CREATE TABLE IF NOT EXISTS `con_actividad` (
  `id_act` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID de la actividad',
  `descripcion` varchar(500) NOT NULL COMMENT 'Descripcion de la actividad',
  `tipo` varchar(50) NOT NULL COMMENT 'Tipo de actividad',
  `observaciones` varchar(500) DEFAULT NULL COMMENT 'Observaciones de la actividad',
  `obra` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_act`),
  KEY `idx_desc` (`descripcion`(255)),
  KEY `idx_tipo` (`tipo`),
  KEY `fk_obra_01` (`obra`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `con_avance_financiero`
--

CREATE TABLE IF NOT EXISTS `con_avance_financiero` (
  `id_avan_fin` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID del avance financiero',
  `programado` float NOT NULL COMMENT 'Total programado',
  `ejecutado` float NOT NULL COMMENT 'Total ejecutado',
  `saldo` float NOT NULL COMMENT 'Saldo de ejecucion',
  `actividad` int(11) NOT NULL COMMENT 'ID de la actividad',
  PRIMARY KEY (`id_avan_fin`),
  KEY `fk_acti_02` (`actividad`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `con_avance_fisico`
--

CREATE TABLE IF NOT EXISTS `con_avance_fisico` (
  `id_avan_fis` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID del avance',
  `unidad` varchar(8) NOT NULL COMMENT 'Unidad',
  `programado` float NOT NULL COMMENT 'Programado',
  `ejecutado` float NOT NULL COMMENT 'Ejecutado',
  `precio` float NOT NULL COMMENT 'Precio unitario',
  `actividad` int(11) NOT NULL COMMENT 'ID de la actividad',
  PRIMARY KEY (`id_avan_fis`),
  KEY `fk_act_01` (`actividad`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `con_convocatoria`
--

CREATE TABLE IF NOT EXISTS `con_convocatoria` (
  `id_conv` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID de la convocatoria',
  `tipo` varchar(50) CHARACTER SET latin1 NOT NULL COMMENT 'Tipo de convocatoria',
  `cuce` varchar(35) CHARACTER SET latin1 NOT NULL COMMENT 'CUCE',
  `entidad` varchar(200) CHARACTER SET latin1 NOT NULL COMMENT 'Nombre de la entidad contratante',
  `objeto` varchar(500) CHARACTER SET latin1 NOT NULL COMMENT 'Objeto de contratacion',
  `lugar_entrega` varchar(200) CHARACTER SET latin1 NOT NULL COMMENT 'Lugar de entrega del DBC',
  `fecha_ini_entr` date NOT NULL COMMENT 'Fecha de inicio de entrega del DBC',
  `encargador` varchar(50) CHARACTER SET latin1 NOT NULL COMMENT 'Encargado de recepcion',
  `encargadoc` varchar(50) CHARACTER SET latin1 NOT NULL COMMENT 'Encargado de consultas',
  `telefono` varchar(25) CHARACTER SET latin1 DEFAULT NULL COMMENT 'Telefono de contacto',
  `inspeccion` datetime DEFAULT NULL COMMENT 'Fecha de inspeccion previa',
  `aclaracion` datetime DEFAULT NULL COMMENT 'Fecha de aclaracion',
  `pres_props` datetime DEFAULT NULL COMMENT 'Fecha de presentacion de propuestas',
  `apertura_sobres` datetime DEFAULT NULL COMMENT 'Fecha de apertura de sobres',
  `fecha_inicio` date NOT NULL COMMENT 'Fecha de inicio',
  `duracion` int(11) NOT NULL COMMENT 'Duracion en dias',
  `fecha_fin` date NOT NULL COMMENT 'Fecha de finalizacion',
  `usuario` int(11) NOT NULL COMMENT 'ID del usuario que registra',
  PRIMARY KEY (`id_conv`),
  KEY `idx_tipo` (`tipo`),
  KEY `idx_enti` (`entidad`),
  KEY `idx_objeto` (`objeto`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `con_item`
--

CREATE TABLE IF NOT EXISTS `con_item` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID del item',
  `descripcion` varchar(200) CHARACTER SET latin1 NOT NULL COMMENT 'Descripcion del item',
  `unidad` varchar(5) CHARACTER SET latin1 NOT NULL COMMENT 'Unidad del item',
  `precio_unit` float NOT NULL COMMENT 'Precio unitario',
  PRIMARY KEY (`item_id`),
  KEY `idx_desc` (`descripcion`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `con_item_modulo`
--

CREATE TABLE IF NOT EXISTS `con_item_modulo` (
  `id_it_mod` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID del registro',
  `modulo` int(11) NOT NULL COMMENT 'ID del modulo',
  `item` int(11) NOT NULL COMMENT 'ID del item',
  `cantidad` float NOT NULL COMMENT 'Cantidad',
  `precio` float NOT NULL COMMENT 'Precio unitario',
  PRIMARY KEY (`id_it_mod`),
  KEY `fk_mod_01` (`modulo`),
  KEY `fk_item_01` (`item`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `con_modulo`
--

CREATE TABLE IF NOT EXISTS `con_modulo` (
  `id_modulo` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID del modulo',
  `descripcion` varchar(200) NOT NULL COMMENT 'Descripcion del modulo',
  `convocatoria` int(11) NOT NULL COMMENT 'Identificador de la obra',
  PRIMARY KEY (`id_modulo`),
  KEY `idx_desc` (`descripcion`),
  KEY `fk_obra_03` (`convocatoria`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=32 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `con_obras`
--

CREATE TABLE IF NOT EXISTS `con_obras` (
  `id_obra` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(200) NOT NULL DEFAULT '-NOMBRE DE LA OBRA-',
  `tipo_proy` varchar(100) NOT NULL DEFAULT '-TIPO-',
  `zona` varchar(255) NOT NULL DEFAULT '',
  `distrito` varchar(25) NOT NULL DEFAULT '',
  `modalidad` varchar(100) NOT NULL DEFAULT '',
  `contratista` varchar(100) NOT NULL DEFAULT 'N/A',
  `nro_contrato` varchar(25) NOT NULL DEFAULT '-',
  `monto` float NOT NULL DEFAULT '0',
  `fecha_inicio` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `fecha_anticipo` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `plazo_ejec` int(11) NOT NULL,
  `fecha_conclusion` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `fecha_conclusion_real` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `dias_ejec` int(11) NOT NULL DEFAULT '0',
  `dias_retraso` int(11) NOT NULL DEFAULT '0',
  `validez_boleta` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `vencimiento_boleta` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `estado_boleta` varchar(50) NOT NULL DEFAULT '',
  `encargado_segui` varchar(100) NOT NULL DEFAULT '',
  `usuario` int(11) NOT NULL,
  `convocatoria` int(11) DEFAULT NULL COMMENT 'ID de la convocatoria',
  PRIMARY KEY (`id_obra`),
  KEY `idx_nombre` (`nombre`),
  KEY `idx_tipo_proy` (`tipo_proy`),
  KEY `idx_modalidad` (`modalidad`),
  KEY `idx_contratista` (`contratista`),
  KEY `idx_nro_contrato` (`nro_contrato`),
  KEY `fk_usr_obr` (`usuario`),
  KEY `fk_conv_02` (`convocatoria`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `con_valoracion`
--

CREATE TABLE IF NOT EXISTS `con_valoracion` (
  `id_val` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID de la valoracion',
  `descripcion` varchar(100) NOT NULL COMMENT 'Descripcion de la valoracion',
  `valor` int(11) NOT NULL COMMENT 'Valor',
  `valoracion` varchar(100) NOT NULL COMMENT 'Valoracion',
  `obs` varchar(500) NOT NULL COMMENT 'Observaciones',
  `obra` int(11) NOT NULL COMMENT 'ID de la obra',
  PRIMARY KEY (`id_val`),
  KEY `fk_obra_02` (`obra`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sys_bitacora`
--

CREATE TABLE IF NOT EXISTS `sys_bitacora` (
  `id_bit` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `tipo` varchar(25) NOT NULL DEFAULT '',
  `tabla` varchar(150) NOT NULL DEFAULT '',
  `acciones` text NOT NULL,
  PRIMARY KEY (`id_bit`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=27 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sys_perfil`
--

CREATE TABLE IF NOT EXISTS `sys_perfil` (
  `id_perfil` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID del perfil',
  `desc` varchar(50) NOT NULL,
  PRIMARY KEY (`id_perfil`),
  KEY `idx_desc` (`desc`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sys_rol`
--

CREATE TABLE IF NOT EXISTS `sys_rol` (
  `id_rol` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID del rol',
  `desc` varchar(50) NOT NULL COMMENT 'Descripcion del rol',
  `url_mod` varchar(250) NOT NULL,
  `orden` int(11) NOT NULL DEFAULT '0' COMMENT 'Orden de aparicion',
  `tit_grup` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_rol`),
  KEY `idx_desc` (`desc`),
  KEY `idx_url` (`url_mod`),
  KEY `idx_orden` (`orden`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=11 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sys_rol_perf`
--

CREATE TABLE IF NOT EXISTS `sys_rol_perf` (
  `id_perf` int(11) NOT NULL COMMENT 'ID del perfil',
  `id_rol` int(11) NOT NULL,
  `nuevo` tinyint(1) NOT NULL DEFAULT '0',
  `modif` tinyint(1) NOT NULL DEFAULT '0',
  `elim` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_perf`,`id_rol`),
  KEY `fk_rol` (`id_rol`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sys_sesion`
--

CREATE TABLE IF NOT EXISTS `sys_sesion` (
  `id_sesion` varchar(250) NOT NULL,
  `expiracion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip_origen` varchar(20) DEFAULT NULL,
  `usuario` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_sesion`),
  KEY `fk_usr` (`usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sys_usuario`
--

CREATE TABLE IF NOT EXISTS `sys_usuario` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID del usuario',
  `login` varchar(25) NOT NULL COMMENT 'Nombre de usuario',
  `clave` varchar(250) NOT NULL COMMENT 'Clave de acceso',
  `perfil` int(11) NOT NULL COMMENT 'Perfil del usuario',
  `ult_acc` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de ultimo acceso',
  `estado` char(1) NOT NULL DEFAULT 'A',
  PRIMARY KEY (`id`),
  KEY `idx_login` (`login`),
  KEY `fk_perfil` (`perfil`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

--
-- Filtros para las tablas descargadas (dump)
--

--
-- Filtros para la tabla `con_actividad`
--
ALTER TABLE `con_actividad`
  ADD CONSTRAINT `fk_obra_01` FOREIGN KEY (`obra`) REFERENCES `con_obras` (`id_obra`) ON DELETE CASCADE;

--
-- Filtros para la tabla `con_avance_financiero`
--
ALTER TABLE `con_avance_financiero`
  ADD CONSTRAINT `fk_acti_02` FOREIGN KEY (`actividad`) REFERENCES `con_actividad` (`id_act`) ON DELETE CASCADE;

--
-- Filtros para la tabla `con_avance_fisico`
--
ALTER TABLE `con_avance_fisico`
  ADD CONSTRAINT `fk_act_01` FOREIGN KEY (`actividad`) REFERENCES `con_actividad` (`id_act`) ON DELETE CASCADE;

--
-- Filtros para la tabla `con_item_modulo`
--
ALTER TABLE `con_item_modulo`
  ADD CONSTRAINT `fk_item_01` FOREIGN KEY (`item`) REFERENCES `con_item` (`item_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_mod_01` FOREIGN KEY (`modulo`) REFERENCES `con_modulo` (`id_modulo`) ON DELETE CASCADE;

--
-- Filtros para la tabla `con_modulo`
--
ALTER TABLE `con_modulo`
  ADD CONSTRAINT `fk_obra_03` FOREIGN KEY (`convocatoria`) REFERENCES `con_convocatoria` (`id_conv`) ON DELETE CASCADE;

--
-- Filtros para la tabla `con_obras`
--
ALTER TABLE `con_obras`
  ADD CONSTRAINT `fk_conv_02` FOREIGN KEY (`convocatoria`) REFERENCES `con_convocatoria` (`id_conv`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_usr_obr` FOREIGN KEY (`usuario`) REFERENCES `sys_usuario` (`id`);

--
-- Filtros para la tabla `con_valoracion`
--
ALTER TABLE `con_valoracion`
  ADD CONSTRAINT `fk_obra_02` FOREIGN KEY (`obra`) REFERENCES `con_obras` (`id_obra`) ON DELETE CASCADE;

--
-- Filtros para la tabla `sys_rol_perf`
--
ALTER TABLE `sys_rol_perf`
  ADD CONSTRAINT `fk_perf` FOREIGN KEY (`id_perf`) REFERENCES `sys_perfil` (`id_perfil`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rol` FOREIGN KEY (`id_rol`) REFERENCES `sys_rol` (`id_rol`) ON DELETE CASCADE;

--
-- Filtros para la tabla `sys_sesion`
--
ALTER TABLE `sys_sesion`
  ADD CONSTRAINT `fk_usr` FOREIGN KEY (`usuario`) REFERENCES `sys_usuario` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `sys_usuario`
--
ALTER TABLE `sys_usuario`
  ADD CONSTRAINT `fk_perfil` FOREIGN KEY (`perfil`) REFERENCES `sys_perfil` (`id_perfil`);
