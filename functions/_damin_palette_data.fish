# 15 lines per flavor:
#   1=text 2=blue 3=mauve 4=green 5=pink 6=peach 7=red 8=flamingo
#   9=overlay1 10=surface0 11=maroon 12=overlay0 13=yellow 14=teal 15=bg
# bg empty for terminal-* (no fixed-hex preview). default arm = mocha.
function _damin_palette_data --argument-names flavor
    switch $flavor
        case macchiato
            printf '%s\n' cad3f5 8aadf4 c6a0f6 a6da95 f5bde6 f5a97f ed8796 f0c6c6 8087a2 363a4f ee99a0 6e738d eed49f 8bd5ca 24273a
        case frappe
            printf '%s\n' c6d0f5 8caaee ca9ee6 a6d189 f4b8e4 ef9f76 e78284 eebebe 838ba7 414559 ea999c 737994 e5c890 81c8be 303446
        case latte
            printf '%s\n' 4c4f69 1e66f5 8839ef 40a02b ea76cb fe640b d20f39 dd7878 8c8fa1 ccd0da e64553 9ca0b0 df8e1d 179299 eff1f5
        case gruvbox
            printf '%s\n' ebdbb2 83a598 d3869b b8bb26 fb4934 fe8019 fb4934 e78a4e 928374 504945 ea6962 7c6f64 fabd2f 8ec07c 282828
        case gruvbox-light
            printf '%s\n' 3c3836 458588 b16286 98971a cc241d d65d0e cc241d af3a03 7c6f64 ebdbb2 9d0006 928374 d79921 689d6a fbf1c7
        case tokyonight
            printf '%s\n' c0caf5 7aa2f7 bb9af7 9ece6a f7768e ff9e64 f7768e e0af68 565f89 414868 ff757f 414868 e0af68 73daca 1a1b26
        case rosepine
            printf '%s\n' e0def4 9ccfd8 c4a7e7 31748f ebbcba f6c177 eb6f92 ebbcba 6e6a86 26233a eb6f92 524f67 f6c177 9ccfd8 191724
        case nord
            printf '%s\n' eceff4 81a1c1 b48ead a3be8c b48ead d08770 bf616a d08770 4c566a 3b4252 bf616a 4c566a ebcb8b 88c0d0 2e3440
        case dracula
            printf '%s\n' f8f8f2 8be9fd bd93f9 50fa7b ff79c6 ffb86c ff5555 ffb86c 6272a4 44475a ff5555 6272a4 f1fa8c 8be9fd 282a36
        case solarized
            printf '%s\n' 839496 268bd2 6c71c4 859900 d33682 cb4b16 dc322f cb4b16 586e75 073642 dc322f 657b83 b58900 2aa198 002b36
        case solarized-light
            printf '%s\n' 657b83 268bd2 6c71c4 859900 d33682 cb4b16 dc322f cb4b16 93a1a1 eee8d5 dc322f 839496 b58900 2aa198 fdf6e3
        case base16
            printf '%s\n' d8d8d8 7cafc2 ba8baf a1b56c ba8baf dc9656 ab4642 dc9656 585858 282828 ab4642 585858 f7ca88 86c1b9 181818
        case base16-light
            printf '%s\n' 383838 7cafc2 ba8baf a1b56c ba8baf dc9656 ab4642 dc9656 b8b8b8 e8e8e8 ab4642 b8b8b8 f7ca88 86c1b9 f8f8f8
        case zenburn
            printf '%s\n' dcdccc 8cd0d3 dc8cc3 7f9f7f dca3a3 dfaf8f cc9393 dca3a3 7f9f7f 4f4f4f cc9393 606060 f0dfaf 93e0e3 3f3f3f
        case colorblind
            # Okabe-Ito 8-color set — distinguishable for deuteranopia / protanopia.
            printf '%s\n' eeeeee 0072b2 cc79a7 009e73 e69f00 e69f00 d55e00 e69f00 888888 3a3a3a d55e00 666666 f0e442 56b4e9 1a1a1a
        case high-contrast
            # WCAG AAA-ish — pure-black bg, saturated foregrounds.
            printf '%s\n' ffffff 87ceeb ff79c6 00ff88 ff5577 ffaa00 ff3344 ffaa00 999999 1a1a1a ff3344 666666 ffe600 00d4ff 000000
        case terminal-dark
            printf '%s\n' white blue brmagenta green brred yellow red yellow brblack brblack red brblack yellow cyan ''
        case terminal-light
            printf '%s\n' black blue magenta green red yellow red yellow brblack brwhite red brblack yellow cyan ''
        case '*'
            # mocha — catppuccin default.
            printf '%s\n' cdd6f4 89b4fa cba6f7 a6e3a1 f5c2e7 fab387 f38ba8 f2cdcd 7f849c 313244 eba0ac 6c7086 f9e2af 94e2d5 1e1e2e
    end
end
