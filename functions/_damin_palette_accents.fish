# palette → "primary_hex secondary_hex". used by conf.d and the picker swatch.
function _damin_palette_accents --argument-names flavor
    switch $flavor
        case gruvbox
            echo "83a598 d3869b"
        case tokyonight
            echo "7aa2f7 bb9af7"
        case rosepine
            echo "9ccfd8 ebbcba"
        case nord
            echo "88c0d0 b48ead"
        case dracula
            echo "8be9fd bd93f9"
        case solarized solarized-light
            echo "268bd2 d33682"
        case base16 base16-light
            echo "7cafc2 ba8baf"
        case zenburn
            echo "8cd0d3 dca3a3"
        case gruvbox-light
            echo "458588 b16286"
        case colorblind
            echo "56b4e9 e69f00"
        case high-contrast
            echo "87ceeb ff79c6"
        case terminal-dark terminal-light
            echo "blue magenta"
        case '*'
            # catppuccin variants — cherry-blossom defaults.
            echo "98ABCC E890B0"
    end
end
