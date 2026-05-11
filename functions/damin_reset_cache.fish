function damin_reset_cache
    command rm -rf $_damin_cache_dir 2>/dev/null
    set -e _damin_lang_pwd
    set -e _damin_lang_value
    set -e _damin_vcs_pwd
    set -e _damin_vcs_value
    set -e _damin_pwd_key_pwd
    set -e _damin_pwd_key_value
    echo "cleared $_damin_cache_dir"
end
