#!/bin/bash -i

# Copies localhost's ~/.kube/config file into the container and swap out localhost
# for host.docker.internal whenever a new shell starts to keep them in sync.
if [ "$SYNC_LOCALHOST_KUBECONFIG" = "true" ] && [ -d "/usr/local/share/kube-localhost" ]; then
    mkdir -p $HOME/.kube
    sudo cp -r /usr/local/share/kube-localhost/* $HOME/.kube
    sudo chown -R $(id -u) $HOME/.kube
    sed -i -e "s/localhost/host.docker.internal/g" $HOME/.kube/config
    sed -i -e "s/127.0.0.1/host.docker.internal/g" $HOME/.kube/config

    # If .minikube was mounted, set up client cert/key
	# minikube context must be minikube
    if [  -d "/usr/local/share/minikube-localhost" ]   &&  [ "$DEV_CLUSTER_PROVIDER" = "minikube" ]; then
        mkdir -p $HOME/.minikube
        sudo cp -r /usr/local/share/minikube-localhost/ca.crt $HOME/.minikube
        # Location varies between versions of minikube
        if [ -f "/usr/local/share/minikube-localhost/client.crt" ]; then
            sudo cp -r /usr/local/share/minikube-localhost/client.crt $HOME/.minikube
            sudo cp -r /usr/local/share/minikube-localhost/client.key $HOME/.minikube
        elif [ -f "/usr/local/share/minikube-localhost/profiles/minikube/client.crt" ]; then
            sudo cp -r /usr/local/share/minikube-localhost/profiles/minikube/client.crt $HOME/.minikube
            sudo cp -r /usr/local/share/minikube-localhost/profiles/minikube/client.key $HOME/.minikube
        fi
        sudo chown -R $(id -u) $HOME/.minikube

        # Point .kube/config to the correct location of the certs
        #sed -i -r "s|(\s*certificate-authority:\s).*|\\1$HOME\/.minikube\/ca.crt|g" $HOME/.kube/config
        #sed -i -r "s|(\s*client-certificate:\s).*|\\1$HOME\/.minikube\/client.crt|g" $HOME/.kube/config
        #sed -i -r "s|(\s*client-key:\s).*|\\1$HOME\/.minikube\/client.key|g" $HOME/.kube/config
		#sed -i -r "s|(\s*server:\s).*|\\1$KUBE_SERVER_API|g" $HOME/.kube/config
		
		kubectl config set clusters.$DEV_CLUSTER_NAME.server $DEV_KUBE_SERVER_API
		#kubectl config set clusters.$DEV_CLUSTER_NAME"minikube.server $KUBE_SERVER_API
		kubectl config set clusters.$DEV_CLUSTER_NAME.certificate-authority $HOME/.minikube/ca.crt
		#kubectl config --kubeconfig=$HOME/.kube/config set-cluster $DEV_CLUSTER_NAME --server=$KUBE_SERVER_API  --certificate-authority=$HOME/minikube/ca.crt
		kubectl config  --kubeconfig=$HOME/.kube/config  set-credentials $DEV_CLUSTER_NAME --client-certificate=$HOME/.minikube/client.crt --client-key=$HOME/.minikube/client.key
		
    fi
fi
