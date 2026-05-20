# flavors + descriptions come from _damin_palette_list / _damin_palette_meta.
complete -c damin_set_palette -f
complete -c damin_set_palette -l help -s h -d 'show help'
for _damin_pal in (_damin_palette_list 2>/dev/null)
    complete -c damin_set_palette -a $_damin_pal -d (_damin_palette_meta $_damin_pal desc 2>/dev/null)
end
set -e _damin_pal
