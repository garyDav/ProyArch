<?php

define ('ID_ROL_BITACORA', 9);
define ('BIT_LISTAR', 'bitacora/filtrar/');
define ('BIT_NUEVO', 'bitacora/nuevo');
define ('BIT_MOSTRAR', 'bitacora/mostrar/');
define ('BIT_EDITAR', 'bitacora/editar/');
define ('BIT_ELIMINAR', 'bitacora/eliminar/');

function iniciarModulo_bitacora() {
	global $PARAMETROS;
	$id = parametros(3);
	if ($PARAMETROS['accion'] == '' || $PARAMETROS['accion'] == 'filtrar') {
		return filtrarBitacora();
	}
}

function filtrarBitacora() {
	global $BD;
    global $PARAMETROS;
    
    $usuario = isset($PARAMETROS['id_usr']) ? $PARAMETROS['id_usr'] : '0';
    $tipo = isset($PARAMETROS['tipo']) ? $PARAMETROS['tipo'] : '';
    $periodo = isset($PARAMETROS['periodo']) ? $PARAMETROS['periodo'] : '';
    $usuariosHTML = listaUsrHTML($usuario);
    $tiposHTML = listaTiposHTML($tipo);
    $periodosHTML = listaPeriodosHTML($periodo);
    $form_filtro = <<<FILTRO_BIT
    <form id="filtro_bit" method="post" action="?r=bitacora/filtrar">
    <table>
    <tr>
        <td>Usuario:</td><td>$usuariosHTML</td>
        <td>Tipo:</td><td>$tiposHTML</td>
        <td>Periodo:</td><td>$periodosHTML</td>
        <td align="center"><input type="submit" value="Filtrar" />
    </tr>
    </table>
    </form>
FILTRO_BIT;
    $resultado = obtenerBitacoraFiltrada($usuario, $tipo, $periodo);
    $html = $form_filtro . $resultado;
    return $html;
}

function listaUsrHTML($pUsuario) {
    global $BD;
    
    $html = "<select name=\"id_usr\" id=\"lst_id_usr\">";
    $cons = "select u.id, u.login, p.desc "
        . "from sys_usuario u "
        . "inner join sys_perfil p on (u.perfil = p.id_perfil) "
        . "where (u.id > 1) "
        . "order by u.login";
    $res = $BD->query($cons);
    $html .= "<option value=\"0\">-- Seleccione --</option>";
    while ($reg = $BD->getNext()) {
        $selected = $reg['id'] == $pUsuario ? 'selected="selected"' : '';
        $html .= '<option value="' . $reg['id'] . '" ' . $selected . '>' 
            . $reg['login'] . ' [' . $reg['desc'] . ']</option>';
    }
    $html .= "</select>";
    return $html;
}

function listaPeriodosHTML($pPeriodo) {
    $periodos = array(
        '1' => 'Ultimo d&iacute;a',
        '7' => 'Hace una semana',
        '30' => 'Hace 30 d&iacute;as',
        '90' => 'Hace 90 d&iacute;as',
        '-' => 'Todos los registros',
    );
    
    $html = "<select name=\"periodo\" id=\"lst_periodo\">";
    foreach ($periodos as $id => $per) {
        $selected = $id == $pPeriodo ? 'selected="selected"' : '';
        $html .= '<option value="' . $id . '" ' . $selected . '>' 
            . $per . '</option>';
    }
    $html .= "</select>";
    return $html;
}

function listaTiposHTML($pTipo) {
    global $BD;
    
    $html = "<select name=\"tipo\" id=\"lst_tipo\">";
    $cons = "select distinct tipo as tipo "
        . "from sys_bitacora "
        . "where (tipo <> '') "
        . "order by tipo";
    $res = $BD->query($cons);
    $html .= "<option value=\"\">-- Seleccione --</option>";
    while ($reg = $BD->getNext()) {
        $selected = $reg['tipo'] == $pTipo ? 'selected="selected"' : '';
        $html .= '<option value="' . $reg['tipo'] . '" ' . $selected . '>' 
            . $reg['tipo'] . '</option>';
    }
    $html .= "</select>";
    return $html;
}

function obtenerBitacoraFiltrada($pUsuario, $pTipo, $pPeriodo) {
    global $BD;
    
    $html = '';
    
    if ($pUsuario <> '0' || $pTipo <> '') {
        $html = '<div><table class="listado" cellspacing="0">';
        $cons = 'SELECT b.*, u.login '
            . 'FROM sys_bitacora b ' 
            . 'INNER JOIN sys_usuario u on (u.id = b.usuario) ';
        $where = array();
        if ($pUsuario <> '0') {
            $where[] = 'usuario = ' . $pUsuario;
        }
        if ($pTipo <> '') {
            $where [] = "tipo = '$pTipo'";
        }
        $fecha_act = strtotime(date('Y-m-d'));
        switch ($pPeriodo) {
            case '': {} break;
            case '-': {} break;
            default: {
                $pPeriodo = (int)($pPeriodo);
                $fecha_act -= $pPeriodo * 3600 * 24;
                $where[] = "fecha >= '" . date('Y-m-d', $fecha_act) . "'";
            }
        } 
                
        $cons .= 'WHERE ' . implode(' AND ', $where);
        $cons .= ' ORDER BY fecha DESC, hora DESC';
        $BD->query($cons);
        $html .= '<tr>'
            . '<th>Usuario</th>'
            . '<th>Fecha</th>'
            . '<th>Hora</th>'
            . '<th>Tipo</th>'
            . '<th>Tabla</th>'
            . '<th>Acciones</th>'
            . '</tr>';
        while ($reg = $BD->getNext()) {
            $html .= '<tr>';
            $html .= '<td>' . $reg['login'] . '</td>';
            $html .= '<td>' . $reg['fecha'] . '</td>';
            $html .= '<td>' . $reg['hora'] . '</td>';
            $html .= '<td>' . $reg['tipo'] . '</td>';
            $html .= '<td>' . $reg['tabla'] . '</td>';
            $html .= '<td><span title="' . $reg['acciones'] . '">' . $reg['acciones'] . '</span></td>';
            $html .= '</tr>';
        } 
        
        $html .= '</table></div>';
    } else {
        $html .= '<p align="center" style="color: #f00;">'
            . 'Debe seleccionar un criterio de b&uacute;squeda.</p>';        
    }
    
    return $html;
}