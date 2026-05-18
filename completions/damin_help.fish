complete -c damin_help -f
complete -c damin_help -l help -s h -d 'show help'
complete -c damin_help -n __fish_use_subcommand \
    -a '(set --names 2>/dev/null | string match "theme_damin_*" | string replace "theme_damin_" "")' \
    -d 'filter substring'
