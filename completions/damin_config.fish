# subcommands + theme_damin_* var name completion for get/set/reset.
complete -c damin_config -f
complete -c damin_config -l help -s h -d 'show help'

complete -c damin_config -n __fish_use_subcommand -a wizard -d 'interactive setup (default)'
complete -c damin_config -n __fish_use_subcommand -a get -d 'print matching theme_damin_*'
complete -c damin_config -n __fish_use_subcommand -a set -d 'set -U a theme_damin_* var'
complete -c damin_config -n __fish_use_subcommand -a reset -d 'unset matching universals (confirm)'
complete -c damin_config -n __fish_use_subcommand -a export -d 'dump universals as fish script'
complete -c damin_config -n __fish_use_subcommand -a edit -d 'edit current export in $EDITOR, re-source on save'
complete -c damin_config -n __fish_use_subcommand -a help -d 'show help'

# arg slot after set/reset: complete with currently-set universal theme_damin_* names.
complete -c damin_config -n '__fish_seen_subcommand_from set reset' \
    -a '(set --names -U 2>/dev/null | string match "theme_damin_*")'
