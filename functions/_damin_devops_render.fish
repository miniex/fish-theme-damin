function _damin_devops_render
    test "$theme_damin_show_terraform" = 1 -o "$theme_damin_show_pulumi" = 1; or return
    _damin_devops_resolve
    test -n "$_damin_devops_tf"; and echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "tf:$_damin_devops_tf" $_damin_c_normal
    test -n "$_damin_devops_pl"; and echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "pulumi:$_damin_devops_pl" $_damin_c_normal
end
