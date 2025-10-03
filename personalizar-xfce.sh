#!/usr/bin/env sh
# Descripcion: Script que personaliza Xfce.
# Autor: Alex Gracia
# Version: 0.1.0
# Requisitos: conexion de red, paquete wget y p7zip-full
# URL: https://github.com/AlexGracia/Personalizar-xfce
#════════════════════════════════════════

# Variables globales
opcion=$1

# Funcion para mostrar un titulo descriptivo del paso actual.
_titulo () {
    echo
    echo "  $1 ($2 de 3)"
    echo "════════════════════════════════════════"
}

# Funcion para mostrar un mensaje de error en rojo.
_error () {
    echo
    echo "\e[91;1m[ ERROR ] $1 \e[0m"
    exit 1
}

# Funcion para mostrar un mensaje de ok en verde.
_ok () {
    echo
    echo "\e[92;1m[ OK ]\e[0m"
    sync
}

#
#   1. Comprobaciones iniciales
#════════════════════════════════════════

# Funcion para las comprobaciones iniciales.
_comprobaciones_iniciales () {
    _titulo "Comprobaciones iniciales   " 1

    # Comprobar el paquete wget.
    echo "Comprobando el paquete wget ..."
    command -v wget >/dev/null
    if [ $? != 0 ]; then
        _error "Falta el paquete wget."
    fi

    # Comprobar el paquete p7zip-full.
    echo "Comprobando el paquete p7zip-full ..."
    command -v 7z >/dev/null
    if [ $? != 0 ]; then
        _error "Falta el paquete p7zip-full."
    fi

    _ok
}

#
#   2. Elegir opcion
#════════════════════════════════════════

# Funcion para validar la opcion elegida.
_validar_opcion () {
    # Convertir mayusculas en minusculas.
    opcion=$(echo "$opcion" | tr '[:upper:]' '[:lower:]')

    # Advertir si la opcion es invalida y volver a preguntar.
    if [ $opcion != "f" ] && [ $opcion != "i" ]; then
        echo
        echo "\e[93;1m[ ! ] Debes escoger una opcion valida (f/i).\e[0m"
        opcion=""
        _elegir_opcion
        return
    fi

    _ok
}

# Funcion para elegir opcion,
# si no se eligio previamente en la ejecucion del script.
_elegir_opcion () {
    _titulo "Elegir opcion              " 2

    # No elegir manualmente opcion,
    # si ya se ha elegido en la ejecucion del script.
    if [ $opcion ]; then
        _validar_opcion
        return
    fi

    # Elegir opcion.
    echo "- Opcion [f]recuente."
    echo "- Opcion [i]nfrecuente."
    echo
    read -p "¿Que deseas elegir [F/i]?: " opcion

    # La opcion por defecto sera f,
    # si no se elige ninguna manualmente.
    if [ ! $opcion ]; then
        opcion="f"
        _ok
        return
    fi

    _validar_opcion
}

#
#   3. Personalizar Xfce
#════════════════════════════════════════

# Funcion para personalizar Xfce.
_personalizar_xfce () {
    _titulo "Personalizar Xfce          " 3

    # Variables
    local fuente="Serif Bold 18"
    local tamanio_cursor=48
    local carpeta_local="$HOME/.local/share"
    local carpeta_iconos="$HOME/.icons"
    local carpeta_temas="$carpeta_local/themes"
    local carpeta_fuentes="$carpeta_local/fonts"
    readonly fuente
    readonly tamanio_cursor
    readonly carpeta_local
    readonly carpeta_iconos
    readonly carpeta_temas
    readonly carpeta_fuentes
    local estilo=""
    local tema=""
    local cursor=""

    # Carpeta temporal de trabajo
    cd /tmp/
    if [ ! -d "personalizar-xfce" ]; then
        mkdir personalizar-xfce
    fi
    cd personalizar-xfce/

    # Descargas
    # Cursor
    if [ ! -f "cursores.zip" ]; then
        echo "Descargando cursor ..."
        wget -q --show-progress -O cursores.zip https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/heads/master.zip
    fi
    # Tema
    if [ ! -f "temas.zip" ]; then
        echo "Descargando tema ..."
        wget -q --show-progress -O temas.zip https://github.com/AlexGracia/Temas-xfwm4/archive/refs/heads/master.zip
    fi

    # Carpetas creadas
    # Iconos
    if [ ! -d "$carpeta_iconos" ]; then
        mkdir $carpeta_iconos
    fi
    # Tema
    if [ ! -d "$carpeta_temas" ]; then
        mkdir $carpeta_temas
    fi

    # Descomprimir
    # Cursor
    echo "Descomprimiendo cursor ..."
    7z x -y cursores.zip '-xr!.gitignore' '-xr!.github' '-xr!colors' '-xr!links' '-xr!release' '-xr!src' '-xr!templates' '-xr!AUTHORS' '-xr!COPYING' '-xr!fluent-icon.jpg' '-xr!install.sh' '-xr!README.md' '-xr!build.sh' '-xr!LICENSE' '-xr!logo.png' '-xr!logo.svg' '-xr!preview-01.png' '-xr!preview-02.png' >/dev/null 2>&1

    sleep 0.5

    # Tema
    echo "Descomprimiendo tema ..."
    7z x -y temas.zip '-xr!img' '-xr!*.md' >/dev/null 2>&1

    sleep 0.5

    echo "Aplicando personalización ..."
    # Borrar plugins
    xfconf-query -c xfce4-panel -p /plugins -rR
    xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -r

    if [ $opcion = "f" ]; then
        estilo="HighContrast"
        # Tema
        tema="Gris-light"
        cp -r "Temas-xfwm4-master/$tema" "$carpeta_temas"

        # Cursor
        cursor="Fluent-cursors"
        cp -r Fluent-icon-theme-master/cursors/dist/ "$carpeta_iconos/$cursor"

        # Panel
        # Estilo, color sólido
        xfconf-query -n -c xfce4-panel -p /panels/panel-1/background-style -t int -s 0
        # Posicionar abajo
        xfconf-query -c xfce4-panel -p /panels/panel-1/position -n -t string -s 'p=8;x=0;y=0'
        # Elementos
        xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -n -t int -s 1 -t int -s 2 -t int -s 3 -t int -s 4 -t int -s 5 -t int -s 6 -t int -s 7 -t int -s 8
        xfconf-query -c xfce4-panel -p /plugins/plugin-1 -n -t string -s whiskermenu
        xfconf-query -c xfce4-panel -p /plugins/plugin-2 -n -t string -s tasklist

        xfconf-query -c xfce4-panel -p /plugins/plugin-3 -n -t string -s separator
        xfconf-query -c xfce4-panel -p /plugins/plugin-3/expand -n -t bool -s true
        xfconf-query -c xfce4-panel -p /plugins/plugin-3/style -n -t int -s 0

        xfconf-query -c xfce4-panel -p /plugins/plugin-4 -n -t string -s pulseaudio

        xfconf-query -c xfce4-panel -p /plugins/plugin-5 -n -t string -s systray
        xfconf-query -c xfce4-panel -p /plugins/plugin-5/square-icons -n -t bool -s true
        xfconf-query -c xfce4-panel -p /plugins/plugin-5/icon-size -n -t int -s 0

        xfconf-query -c xfce4-panel -p /plugins/plugin-6 -n -t string -s power-manager-plugin
        xfconf-query -c xfce4-panel -p /plugins/plugin-7 -n -t string -s notification-plugin

        xfconf-query -c xfce4-panel -p /plugins/plugin-8 -n -t string -s clock
        xfconf-query -c xfce4-panel -p /plugins/plugin-8/digital-layout -n -t int -s 3
        xfconf-query -c xfce4-panel -p /plugins/plugin-8/digital-time-font -n -t string -s "Serif Bold 42"

        # Mostrar iconos del escritorio
        xfconf-query -n -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -t bool -s true
        xfconf-query -n -c xfce4-desktop -p /desktop-icons/file-icons/show-home -t bool -s true
        xfconf-query -n -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -t bool -s true

        # Botones del título de las ventanas
        xfconf-query -c xfwm4 -p /general/button_layout -n -t string -s '|HMC'

        # Notificaciones abajo a la derecha
        xfconf-query -n -c xfce4-notifyd -p /notify-location -t uint -s 3

        # Deshabilitar menú de aplicaciones en el escritorio
        xfconf-query -n -c xfce4-desktop -p /desktop-menu/show -t bool -s false
    else
        # Fuente
        if [ ! -f "fuente.zip" ]; then
            echo "Descargando fuente ..."
            wget -q --show-progress -O fuente.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
        fi
        echo "Descomprimiendo fuente ..."
        7z x -y fuente.zip '-xr!*.md' >/dev/null 2>&1
        sleep 0.5
        echo "Instalando fuente ..."
        if [ ! -d "$carpeta_fuentes" ]; then
            mkdir $carpeta_fuentes
        fi
        cp *.ttf $carpeta_fuentes
        echo "Actualizando lista de fuentes ..."
        fc-cache -f
        echo "Seleccionando fuente ..."
        xfconf-query -c xsettings -p /Gtk/MonospaceFontName -n -t string -s "Hack Nerd Font Bold 18"

        estilo="Adwaita-dark"

        # Tema
        tema="Oliva-dark"
        cp -r "Temas-xfwm4-master/$tema" "$carpeta_temas"

        # Cursor
        cursor="Fluent-dark-cursors"
        cp -r Fluent-icon-theme-master/cursors/dist-dark/ "$carpeta_iconos/$cursor"

        # Panel
        # Estilo, color sólido
        xfconf-query -n -c xfce4-panel -p /panels/panel-1/background-style -t int -s 1
        # Color de fondo, negro
        xfconf-query -n -c xfce4-panel -p /panels/panel-1/background-rgba -t double -s 0.000000 -t double -s 0.000000 -t double -s 0.000000 -t double -s 1.000000
        # Posicionar arriba
        xfconf-query -c xfce4-panel -p /panels/panel-1/position -n -t string -s 'p=6;x=0;y=0'
        # Elementos
        xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -n -t int -s 1 -t int -s 2 -t int -s 3 -t int -s 4 -t int -s 5 -t int -s 6 -t int -s 7
        xfconf-query -c xfce4-panel -p /plugins/plugin-1 -n -t string -s separator
        xfconf-query -c xfce4-panel -p /plugins/plugin-1/expand -n -t bool -s true
        xfconf-query -c xfce4-panel -p /plugins/plugin-1/style -n -t int -s 0

        xfconf-query -c xfce4-panel -p /plugins/plugin-2 -n -t string -s clock
        xfconf-query -c xfce4-panel -p /plugins/plugin-2/digital-layout -n -t int -s 3
        xfconf-query -c xfce4-panel -p /plugins/plugin-2/digital-time-font -n -t string -s "Hack Nerd Font Bold 42"

        xfconf-query -c xfce4-panel -p /plugins/plugin-3 -n -t string -s separator
        xfconf-query -c xfce4-panel -p /plugins/plugin-3/expand -n -t bool -s true
        xfconf-query -c xfce4-panel -p /plugins/plugin-3/style -n -t int -s 0

        xfconf-query -c xfce4-panel -p /plugins/plugin-4 -n -t string -s pulseaudio

        xfconf-query -c xfce4-panel -p /plugins/plugin-5 -n -t string -s systray
        xfconf-query -c xfce4-panel -p /plugins/plugin-5/square-icons -n -t bool -s true
        xfconf-query -c xfce4-panel -p /plugins/plugin-5/icon-size -n -t int -s 0

        xfconf-query -c xfce4-panel -p /plugins/plugin-6 -n -t string -s notification-plugin
        xfconf-query -c xfce4-panel -p /plugins/plugin-7 -n -t string -s power-manager-plugin

        # Ocultar iconos del escritorio
        xfconf-query -n -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -t bool -s false
        xfconf-query -n -c xfce4-desktop -p /desktop-icons/file-icons/show-home -t bool -s false
        xfconf-query -n -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -t bool -s false

        # Botones del título de las ventanas
        xfconf-query -c xfwm4 -p /general/button_layout -n -t string -s '|C'

        # Notificaciones abajo a la izquierda
        xfconf-query -n -c xfce4-notifyd -p /notify-location -t uint -s 1

        # Habilitar menú de aplicaciones en el escritorio
        xfconf-query -n -c xfce4-desktop -p /desktop-menu/show -t bool -s true
    fi

    # Apariencia
    xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s $estilo
    xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "$fuente"

    # Gestor de ventanas
    xfconf-query -c xfwm4 -p /general/theme -n -t string -s $tema
    xfconf-query -c xfwm4 -p /general/title_font -n -t string -s "$fuente"
    xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false
    xfconf-query -c xfwm4 -p /general/workspace_count -n -t int -s 1

    # Cursor
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -n -t string -s $cursor
    xfconf-query -c xsettings -p /Gtk/CursorThemeSize -n -t int -s $tamanio_cursor

    # Panel
    # Borrar panel 2
    xfconf-query -c xfce4-panel -p /panels/panel-2 -rR
    # Dejar un panel
    xfconf-query -c xfce4-panel -p /panels -t int -a -s 1
    # Altura del panel
    xfconf-query -c xfce4-panel -p /panels/panel-1/size -n -t int -s 52
    # Tamaño automático de los iconos
    xfconf-query -c xfce4-panel -p /panels/panel-1/icon-size -n -t int -s 0
    # Mostrar el indicador del modo de presentación
    xfconf-query -n -c xfce4-power-manager -p /xfce4-power-manager/show-presentation-indicator -t bool -s true

    # Recargar panel
    xfce4-panel -r

    # Recargar escritorio.
    #xfdesktop --reload
    _ok
}

# Funcion para iniciar el script.
_iniciar () {
    # Bienvenida.
    clear
    echo "
╔═══════════════════╗
║ Personalizar Xfce ║
╚═══════════════════╝"

    _comprobaciones_iniciales
    _elegir_opcion
    _personalizar_xfce
}

_iniciar

# Funcion para finalizar el script.
_finalizar () {
    # Despedida.
    echo "
╔═══════════════════╗
║        Fin        ║
╚═══════════════════╝"
}

_finalizar

exit
