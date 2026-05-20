complete -c damin_palette_preview -f
complete -c damin_palette_preview -l help -s h -d 'show help'
complete -c damin_palette_preview -l all -d 'stack every flavor for comparison'
for _damin_pal in (_damin_palette_list 2>/dev/null)
    complete -c damin_palette_preview -a $_damin_pal -d (_damin_palette_meta $_damin_pal desc 2>/dev/null)
end
set -e _damin_pal
