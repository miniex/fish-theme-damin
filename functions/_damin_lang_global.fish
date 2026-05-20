function _damin_lang_global
    # node: $NVM_BIN = .../versions/node/v<X>/bin -> basename of dirname.
    if set -q NVM_BIN; and test -n "$NVM_BIN"
        set -l v (path basename (path dirname $NVM_BIN) 2>/dev/null | string replace -r '^v' '')
        if test -n "$v"
            echo "node:$v"
            return
        end
    end
    # fnm: $FNM_VERSION_FILE_PATH points at a file holding the resolved version.
    if set -q FNM_VERSION_FILE_PATH; and test -n "$FNM_VERSION_FILE_PATH" -a -f "$FNM_VERSION_FILE_PATH"
        set -l v (command cat $FNM_VERSION_FILE_PATH 2>/dev/null | string trim | string replace -r '^v' '')
        if test -n "$v"
            echo "node:$v"
            return
        end
    end

    # ruby: rbenv > RVM > chruby ($RUBY_VERSION).
    if set -q RBENV_VERSION; and test -n "$RBENV_VERSION" -a "$RBENV_VERSION" != system
        echo "rb:$RBENV_VERSION"
        return
    end
    if set -q rvm_ruby_string; and test -n "$rvm_ruby_string"
        set -l v (string replace -r '^ruby-' '' -- $rvm_ruby_string)
        echo "rb:$v"
        return
    end
    if set -q RUBY_VERSION; and test -n "$RUBY_VERSION"
        echo "rb:$RUBY_VERSION"
        return
    end

    # python: pyenv only — $VIRTUAL_ENV / conda are rendered in env segment.
    if set -q PYENV_VERSION; and test -n "$PYENV_VERSION" -a "$PYENV_VERSION" != system
        echo "py:$PYENV_VERSION"
        return
    end

    # asdf legacy shims: $ASDF_<TOOL>_VERSION.
    if set -q ASDF_NODEJS_VERSION; and test -n "$ASDF_NODEJS_VERSION"
        echo "node:$ASDF_NODEJS_VERSION"
        return
    end
    if set -q ASDF_RUBY_VERSION; and test -n "$ASDF_RUBY_VERSION"
        echo "rb:$ASDF_RUBY_VERSION"
        return
    end
    if set -q ASDF_PYTHON_VERSION; and test -n "$ASDF_PYTHON_VERSION"
        echo "py:$ASDF_PYTHON_VERSION"
        return
    end
end
