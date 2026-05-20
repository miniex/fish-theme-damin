# flavor -> display name / description / theme (dark|light).
# field: name | desc | theme. without field -> 3 lines in that order.
# empty name signals "no .theme file" (terminal-*).
function _damin_palette_meta --argument-names flavor field
    set -l name
    set -l desc
    set -l theme dark
    switch $flavor
        case mocha
            set name "Damin Mocha"
            set desc 'catppuccin default (dark)'
        case macchiato
            set name "Damin Macchiato"
            set desc 'catppuccin muted (dark)'
        case frappe
            set name "Damin Frappe"
            set desc 'catppuccin softer (dark)'
        case latte
            set name "Damin Latte"
            set desc 'catppuccin light'
            set theme light
        case gruvbox
            set name "Damin Gruvbox"
            set desc 'retro warm earth (dark)'
        case gruvbox-light
            set name "Damin Gruvbox Light"
            set desc 'gruvbox light'
            set theme light
        case tokyonight
            set name "Damin Tokyo Night"
            set desc 'downtown neon (dark)'
        case rosepine
            set name "Damin Rose Pine"
            set desc 'muted rose/pine (dark)'
        case nord
            set name "Damin Nord"
            set desc 'arctic pastels (dark)'
        case dracula
            set name "Damin Dracula"
            set desc 'classic vampire (dark)'
        case solarized
            set name "Damin Solarized"
            set desc 'schoonover dark'
        case solarized-light
            set name "Damin Solarized Light"
            set desc 'solarized light'
            set theme light
        case base16
            set name "Damin Base16"
            set desc 'base16 default-dark'
        case base16-light
            set name "Damin Base16 Light"
            set desc 'base16 default-light'
            set theme light
        case zenburn
            set name "Damin Zenburn"
            set desc 'low-contrast muted (dark)'
        case colorblind
            set name "Damin Colorblind"
            set desc 'Okabe-Ito colorblind-safe (dark)'
        case high-contrast
            set name "Damin High Contrast"
            set desc 'WCAG AAA-ish saturated palette (dark)'
        case terminal-dark
            set desc 'terminal 16-color, dark fg'
        case terminal-light
            set desc 'terminal 16-color, light fg'
            set theme light
    end
    switch "$field"
        case name
            echo $name
        case desc
            echo $desc
        case theme
            echo $theme
        case '*'
            printf '%s\n%s\n%s\n' "$name" "$desc" "$theme"
    end
end
