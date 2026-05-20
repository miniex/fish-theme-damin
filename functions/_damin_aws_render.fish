function _damin_aws_render
    test "$theme_damin_show_aws" = 1; or return
    set -l profile
    if set -q AWS_PROFILE; and test -n "$AWS_PROFILE"
        set profile $AWS_PROFILE
    else if set -q AWS_DEFAULT_PROFILE; and test -n "$AWS_DEFAULT_PROFILE"
        set profile $AWS_DEFAULT_PROFILE
    else if set -q AWS_VAULT; and test -n "$AWS_VAULT"
        # aws-vault exec may not export AWS_PROFILE.
        set profile $AWS_VAULT
    end
    test -n "$profile"; or return

    set -l region
    if set -q AWS_REGION; and test -n "$AWS_REGION"
        set region $AWS_REGION
    else if set -q AWS_DEFAULT_REGION; and test -n "$AWS_DEFAULT_REGION"
        set region $AWS_DEFAULT_REGION
    else if test "$theme_damin_show_aws_region" = 1
        set -l cfg "$HOME/.aws/config"
        set -q AWS_CONFIG_FILE; and test -n "$AWS_CONFIG_FILE"; and set cfg $AWS_CONFIG_FILE
        if test -f $cfg
            set -l mt (path mtime $cfg 2>/dev/null)
            set -l key "$mt|$profile"
            if test "$_damin_aws_cfg_mt" = "$key"
                set region $_damin_aws_cfg_value
            else
                set region (_damin_aws_region_for $profile $cfg)
                set -g _damin_aws_cfg_mt "$key"
                set -g _damin_aws_cfg_value "$region"
            end
        end
    end

    # aws-vault session -> distinct `aws-vault:` prefix.
    set -l prefix aws
    set -q AWS_VAULT; and test -n "$AWS_VAULT"; and set prefix aws-vault
    set -l shown_profile (_damin_truncate "$profile" (_damin_effective_max_len aws))
    set -l label "$prefix:$shown_profile"
    test "$theme_damin_show_aws_region" = 1 -a -n "$region"; and set label "$label@$region"
    echo -n -s $_damin_c_dim "$label " $_damin_c_normal
end
