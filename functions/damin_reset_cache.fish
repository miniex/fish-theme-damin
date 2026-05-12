function damin_reset_cache
    command rm -rf $_damin_cache_dir 2>/dev/null
    set -e _damin_lang_pwd
    set -e _damin_lang_value
    set -e _damin_vcs_pwd
    set -e _damin_vcs_value
    set -e _damin_vcs_dir
    set -e _damin_pwd_key_pwd
    set -e _damin_pwd_key_value
    set -e _damin_battery_value
    set -e _damin_battery_at
    set -e _damin_devops_pwd
    set -e _damin_devops_tf
    set -e _damin_devops_pl
    set -e _damin_k8s_mt
    set -e _damin_k8s_ctx
    set -e _damin_k8s_ns
    echo "cleared $_damin_cache_dir"
end
