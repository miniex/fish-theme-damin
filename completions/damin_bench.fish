complete -c damin_bench -f
complete -c damin_bench -l help -s h -d 'show help'
complete -c damin_bench -l json -d 'emit single-line JSON for CI comparison'
complete -c damin_bench -l cold -d 'cold-path benchmark: wipe caches between samples, N=1, no warmup'
complete -c damin_bench -l compare -d 'diff two --json outputs and emit Δ ms / %'
