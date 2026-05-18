function _damin_azure_render
    test "$theme_damin_show_azure" = 1; or return
    set -l sub
    if set -q AZURE_SUBSCRIPTION_NAME; and test -n "$AZURE_SUBSCRIPTION_NAME"
        set sub $AZURE_SUBSCRIPTION_NAME
    else if set -q AZURE_DEFAULTS_SUBSCRIPTION; and test -n "$AZURE_DEFAULTS_SUBSCRIPTION"
        set sub $AZURE_DEFAULTS_SUBSCRIPTION
    else
        set -l file "$HOME/.azure/azureProfile.json"
        set -q AZURE_CONFIG_DIR; and test -n "$AZURE_CONFIG_DIR"; and set file "$AZURE_CONFIG_DIR/azureProfile.json"
        test -f $file; or return
        set -l mt (path mtime $file 2>/dev/null)
        if test "$_damin_azure_mt" = "$mt"
            set sub $_damin_azure_value
        else
            set sub (_damin_azure_compute $file)
            set -g _damin_azure_mt "$mt"
            set -g _damin_azure_value "$sub"
        end
    end
    test -n "$sub"; or return
    set -l shown (_damin_truncate "$sub" (_damin_effective_max_len azure))
    echo -n -s $_damin_c_dim "az:$shown " $_damin_c_normal
end
