function _damin_k8s_config_path
    if set -q KUBECONFIG; and test -n "$KUBECONFIG"
        echo (string split : -- $KUBECONFIG)[1]
        return
    end
    echo "$HOME/.kube/config"
end
