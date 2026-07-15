-- ##############################################################################
-- ##                     CONFIGURAÇÃO DO HYPRLAND                             ##
-- ##############################################################################


-- ==============================================================================
-- 01. MONITOR
-- ==============================================================================

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@120.21",
    position = "0x0",
    scale    = "1.25",
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
    mirror   = "eDP-1"
})

-- ==============================================================================
-- 02. VARIÁVEIS DE PROGRAMAS
-- ==============================================================================

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "rofi -show drun -show-icons"
local browser     = "zen-browser"
local editor      = "code"

-- ==============================================================================
-- 03. AUTOSTART
-- ==============================================================================

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprlock &")
    hl.exec_cmd("waybar &")
    hl.exec_cmd("awww-daemon &")
    hl.exec_cmd("eww daemon &")
    
    -- 1. Injeta as variáveis (mantemos isso, é essencial para os apps)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    
    -- 2. A SOLUÇÃO BRUTA: Derruba portais zumbis e inicia manualmente com atraso
    hl.exec_cmd("killall -9 xdg-desktop-portal-hyprland xdg-desktop-portal")
    hl.exec_cmd("sleep 1 && /usr/lib/xdg-desktop-portal-hyprland &")
    hl.exec_cmd("sleep 2 && /usr/lib/xdg-desktop-portal &")
    
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &")
    hl.exec_cmd("hypridle &")
    hl.exec_cmd("xrdb -merge ~/.Xresources")
    hl.exec_cmd("sleep 2 && swaync --skip-system-css --custom-system-css &")
    
    -- hl.exec_cmd("celeste-client &") 
    
    hl.exec_cmd("wl-paste --type text  --watch cliphist store &")
    hl.exec_cmd("wl-paste --type image --watch cliphist store &")
end)

-- ==============================================================================
-- 04. VARIÁVEIS DE AMBIENTE
-- ==============================================================================

hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("AQ_BACKEND",       "drm")
-- hl.env("HYPRCURSOR_THEME", "Adwaita")
-- hl.env("HYPRCURSOR_SIZE",  "24")
-- hl.env("XCURSOR_THEME",    "Adwaita")
-- hl.env("XCURSOR_SIZE",     "24")
hl.env("GDK_SCALE",        "1")

-- Força renderização Wayland para GTK e fallback para X11
hl.env("GDK_BACKEND",      "wayland,x11,*")
hl.env("GDK_SCALE",        "1")

-- Identificação do Desktop
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Força o tema e a plataforma no motor Qt
hl.env("QT_QPA_PLATFORM",      "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Outros toolkits
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")


-- ==============================================================================
-- 05. INPUT (TECLADO, MOUSE E TOUCHPAD)
-- ==============================================================================

hl.config({
    input = {
        kb_layout  = "br",
        kb_variant = "abnt2",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        numlock_by_default = true,
        follow_mouse       = 1,
        sensitivity        = 0.3,

        touchpad = {
            natural_scroll = true,
        },
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

-- Taxa de repetição otimizada para o teclado interno
hl.device({
    name         = "at-translated-set-2-keyboard",
    repeat_rate  = 25,
    repeat_delay = 600,
})

-- Sensibilidade do mouse externo
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- Gesto de 3 dedos horizontal para navegar entre workspaces
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


-- ==============================================================================
-- 06. LOOK & FEEL (CORES, BORDAS E LAYOUT)
-- ==============================================================================

local bg       = "rgba(111111ee)"
local active   = "rgba(c8c8c866)"
local inactive = "rgba(50505044)"

hl.config({
    general = {
        gaps_in     = 6,
        gaps_out    = 12,
        border_size = 1,

        col = {
            active_border   = active,
            inactive_border = inactive,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true,
    },
})


-- ==============================================================================
-- 07. DECORAÇÕES (SOMBRA, BLUR E OPACIDADE)
-- ==============================================================================

hl.config({
    decoration = {
        rounding = 12,

        -- Opacidade sólida para evitar conflito com GTK CSS
        active_opacity   = 1.0,
        inactive_opacity = 0.85,

        shadow = {
            enabled      = false,
            range        = 2,
            render_power = 10,
            color        = "rgba(000000aa)",
        },

        blur = {
            enabled        = true,
            size           = 3,
            passes         = 1,
            vibrancy       = 0.2,
            ignore_opacity = true,
        },
    },
})


-- ==============================================================================
-- 08. ANIMAÇÕES
-- ==============================================================================

hl.config({
    animations = {
        enabled = true,
    },
})

-- Curvas Bezier personalizadas
hl.curve("overshot",    { type = "bezier", points = { {0.05, 0.9}, {0.1,  1.05}  } })
hl.curve("smoothOut",   { type = "bezier", points = { {0.36, 0},   {0.66, -0.56} } })
hl.curve("linear",      { type = "bezier", points = { {0,    0},   {1,    1}     } })
hl.curve("smoothDecel", { type = "bezier", points = { {0.25, 1},   {0.5,  1}     } })
hl.curve("snappy",      { type = "bezier", points = { {0.4,  0.0}, {0.2,  1.0}   } })

-- Janelas
hl.animation({ leaf = "windows",     enabled = true, speed = 3,  bezier = "snappy",      style = "popin 80%" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3,  bezier = "snappy",      style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3,  bezier = "smoothOut",   style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3,  bezier = "snappy",      style = "slide"     })

-- Layers (waybar, rofi, etc.)
hl.animation({ leaf = "layers",      enabled = true, speed = 3,  bezier = "smoothDecel", style = "popin 80%" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 3,  bezier = "smoothDecel", style = "popin 80%" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 3,  bezier = "smoothOut",   style = "popin 80%" })

-- Fade
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2, bezier = "linear" })

-- Workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 3,  bezier = "snappy", style = "slide" })

-- Borda animada
hl.animation({ leaf = "border",      enabled = true, speed = 3,  bezier = "linear"             })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })


-- ==============================================================================
-- 09. MISC E DEBUG
-- ==============================================================================

hl.config({
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        always_follow_on_dnd     = true,
        disable_autoreload       = false,
    },

    debug = {
        disable_logs       = false,
        suppress_errors    = false,
        enable_stdout_logs = false,
    },
})


-- ==============================================================================
-- 10. PERMISSÕES (descomente se necessário)
-- ==============================================================================

-- hl.config({
--     ecosystem = {
--         enforce_permissions = true,
--     },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim",                          "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland","screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm",                        "plugin",     "allow")


-- ==============================================================================
-- 11. REGRAS DE LAYER (BLUR EM OVERLAYS)
-- ==============================================================================

hl.layer_rule({
    name         = "blur_waybar",
    match        = { namespace = "^(waybar)$" },
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name         = "blur_ewwbar",
    match        = { namespace = "^(gtk-layer-shell)$" },
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name         = "blur_rofi",
    match        = { namespace = "^(rofi)$" },
    blur         = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name         = "blur_wlogout",
    match        = { namespace = "^(wlogout)$" },
    blur         = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name         = "blur_swaync_centro",
    match        = { namespace = "^(swaync-control-center)$" },
    blur         = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name         = "blur_swaync_notificacoes",
    match        = { namespace = "^(swaync-notification-window)$" },
    blur         = true,
    ignore_alpha = 0.5,
})


-- ==============================================================================
-- 12. REGRAS DE JANELA
-- ==============================================================================

-- Apps utilitários em modo flutuante centralizado
hl.window_rule({
    name       = "nm-connection-editor",
    match      = { class = "^(nm-connection-editor)$" },
    float      = true,
    center     = true,
    size       = "600 500",
    -- dim_around = true,
})

hl.window_rule({
    name       = "polkit-gnome",
    match      = { class = "^(polkit-gnome-authentication-agent-1)$" },
    float      = true,
    center     = true,
    dim_around = true,
    pin        = true,
})

hl.window_rule({
    name       = "waypaper",
    match      = { class = "^(waypaper)$" },
    float      = true,
    center     = true,
    size       = "900 600",
   -- dim_around = true,
})

hl.window_rule({
    name       = "btop_float",
    match      = { class = "^(btop_floating)$" },
    float      = true,
    center     = true,
    size       = "1280 720",
   -- dim_around = true,
})

hl.window_rule({
    name       = "blueman-manager",
    match      = { class = "^(blueman-manager)$" },
    float      = true,
    center     = true,
    size       = "600 500",
    --dim_around = true,
})

hl.window_rule({
    name       = "pavucontrol",
    match      = { class = "^(org.pulseaudio.pavucontrol)$" },
    float      = true,
    center     = true,
    size       = "600 500",
    -- dim_around = true,
})

hl.window_rule({
    name       = "nmgtk",
    match      = { class = "^(org.personal.nmgtk)$" },
    float      = true,
    center     = true,
    size       = "600 500",
    dim_around = true,
})


-- Suprime evento de maximizar
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Modo Janelas Flutuantes
--hl.window_rule({
  --  name       = "modo-janelas-flutuantes",
    --match      = { class = ".*" },
    --float      = true,
    --center     = true,
--})

-- Corrige drag em janelas XWayland sem título/classe
hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class    = "^$",
        title    = "^$",
        xwayland = true,
        float    = true,
    },
    no_focus = true,
})

-- Posiciona janelas do hyprland-run no canto inferior esquerdo
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- Spotify abre no workspace especial
hl.window_rule({
    name      = "spotify",
    match     = { class = "^(spotify_terminal)$" },
    workspace = "special:spotify",
})

-- App Wi-Fi
hl.window_rule({
    name       = "app-wifi-rust",
    match      = { class = "^(org\\.personal\\.wifirust)$" },
    float      = true,
    center     = true,
    size       = "450 550",
    --dim_around = true,
    opacity    = "0.85 0.85",
})

-- Opacidade do VS Code
hl.window_rule({
    name    = "opacidade-vscode",
    match   = { class = "^([Cc]ode.*)$" },
    opacity = "0.95 0.95",
})

-- Opacidade do Thunar
hl.window_rule({
    name    = "opacidade-thunar",
    match   = { class = "^([Tt]hunar)$" },
    opacity = "0.85 0.85",
})

-- GLava: visualizador de áudio fixo no fundo da tela
hl.window_rule({
    name             = "glava",
    match            = { class = "^(GLava)$" },
    float            = true,
    pin              = true,
    size             = "1536 100",
    move             = "0 764",
    border_size      = 0,
    no_shadow        = true,
    no_blur          = true,
    no_focus         = true,
    no_initial_focus = true,
    allows_input     = false,
    dim_around       = false,
    render_unfocused = true,
    animation        = "fade",
})

-- ==============================================================================
-- 13. ATALHOS (BINDS)
-- ==============================================================================

local mainMod = "SUPER"

-- Aplicativos
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + A",         hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + E",         hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + O",         hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("uuctl rofi -dmenu -theme ~/.config/rofi/uuctl.rasi"))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("~/.config/meu-wifi-rust/meu-wifi-rust"))
hl.bind(mainMod .. " + C",         hl.dsp.exec_cmd("cliphist list | rofi -dmenu -theme ~/.config/rofi/clipboard.rasi | cliphist decode | wl-copy"))
hl.bind("XF86PowerOff",            hl.dsp.exec_cmd("wlogout"))
local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("spotify"))

-- Layout e foco
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())
hl.bind(mainMod .. " + U",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + U",     hl.dsp.window.center())
hl.bind(mainMod .. " + CTRL + U",      hl.dsp.window.pin())
hl.bind(mainMod .. " + ALT + U",       hl.dsp.layout("togglesplit"))

-- Movimentação de foco
hl.bind(mainMod .. " + left",          hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right",         hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",            hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",          hl.dsp.focus({ direction = "down"  }))

-- Movimentação de janelas
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left"  }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up"    }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down"  }))

-- Redimensionar janelas
local resizeUnit = 100
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = resizeUnit, y = 0, relative=true }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -resizeUnit, y = 0, relative=true }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -resizeUnit, relative=true }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = resizeUnit, relative=true }))

-- Arrastar e redimensionar com mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces: trocar e mover janela (tecla 0 = workspace 10)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Navegação de workspace com scroll do mouse
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Screenshots (comandos passados para bash para garantir expansão correta de variáveis)
hl.bind("Print", hl.dsp.exec_cmd(
    'bash -c \'d="$HOME/Imagens/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"; grim -g "$(slurp)" "$d" && notify-send "📸 Print Salvo" "Área capturada com sucesso" -i "$d"\''
))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    'bash -c \'d="$HOME/Imagens/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"; grim "$d" && notify-send "📸 Print Salvo" "Tela cheia capturada" -i "$d"\''
))
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    'bash -c \'grim -g "$(slurp)" - | wl-copy && notify-send "📋 Print Copiado" "Imagem enviada para a área de transferência"\''
))

-- Multimídia: volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh down"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("~/.config/hypr/scripts/volume.sh mute"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { locked = true, repeating = true })

-- Multimídia: brilho
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("~/.config/hypr/scripts/brilho.sh +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/hypr/scripts/brilho.sh 5%-"), { locked = true, repeating = true })

-- Multimídia: controle de mídia (playerctl)
hl.bind(mainMod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd("playerctl previous"),    { locked = true })
hl.bind(mainMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPlay",                      hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
