# active_config names the live config; configurations/config_<name> [core] holds the project.
function _damin_gcp_render
    test "$theme_damin_show_gcp" = 1; or return

    set -l project
    if set -q CLOUDSDK_CORE_PROJECT; and test -n "$CLOUDSDK_CORE_PROJECT"
        set project $CLOUDSDK_CORE_PROJECT
    else
        set -l cfg_root "$HOME/.config/gcloud"
        set -q CLOUDSDK_CONFIG; and test -n "$CLOUDSDK_CONFIG"; and set cfg_root $CLOUDSDK_CONFIG
        set -l active "$cfg_root/active_config"
        test -f $active; or return

        set -l mt (path mtime $active 2>/dev/null)
        set -l name
        if test "$_damin_gcp_active_mt" = "$mt"
            set name $_damin_gcp_active_name
        else
            set name (command cat $active 2>/dev/null | string trim | head -1)
            set -g _damin_gcp_active_mt "$mt"
            set -g _damin_gcp_active_name "$name"
        end
        test -n "$name"; or return

        set -l cfg "$cfg_root/configurations/config_$name"
        test -f $cfg; or return
        set -l cmt (path mtime $cfg 2>/dev/null)
        if test "$_damin_gcp_cfg_mt" = "$cmt|$name"
            set project $_damin_gcp_cfg_value
        else
            set -l in_core 0
            for line in (command cat $cfg 2>/dev/null)
                if string match -qr '^\[' -- $line
                    test "$line" = '[core]'; and set in_core 1; or set in_core 0
                    continue
                end
                test $in_core = 1; or continue
                set -l m (string match -r '^project *= *(.*)$' -- $line)
                test (count $m) -ge 2; and set project (string trim -- $m[2]); and break
            end
            set -g _damin_gcp_cfg_mt "$cmt|$name"
            set -g _damin_gcp_cfg_value "$project"
        end
    end

    test -n "$project"; or return
    set -l shown (_damin_truncate "$project" (_damin_effective_max_len gcp))
    echo -n -s $_damin_c_dim "gcp:$shown " $_damin_c_normal
end
