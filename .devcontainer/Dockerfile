ARG VARIANT=11-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/java:0-${VARIANT}

 

#########################################   INSTALL  SO Packages  #########################

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=vscode

#automatic
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# [Optional] Install  Network utilities
RUN  sudo apt-get update &&  export DEBIAN_FRONTEND=noninteractive  \
&& sudo apt-get -y install --no-install-recommends iputils-ping dnsutils netcat 


#########################################   INSTALL Docker #########################

# Docker Cli Instalacao
RUN sudo apt-get -y install     gnupg 
RUN sudo mkdir -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN  sudo apt-get update && sudo apt-get -y install  docker-ce-cli   


# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1



#########################################   INSTALL JAVA Tools #########################

# [Option] Install Maven
ARG INSTALL_MAVEN="false"
ARG MAVEN_VERSION=""

# [Option] Install Gradle
ARG INSTALL_GRADLE="false"
ARG GRADLE_VERSION=""

RUN if [ "${INSTALL_MAVEN}" = "true" ]; then su vscode -c "umask 0002 && . /usr/local/sdkman/bin/sdkman-init.sh && sdk install maven \"${MAVEN_VERSION}\""; fi \
    && if [ "${INSTALL_GRADLE}" = "true" ]; then su vscode -c "umask 0002 && . /usr/local/sdkman/bin/sdkman-init.sh && sdk install gradle \"${GRADLE_VERSION}\""; fi

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi


#Copy User Specific Maven
 #VOLUME /local_m2
ARG M2_LOCAL_HOME_CONFIG
# ="C:/Program Files/apache-maven-3.8.5/conf/settings.xml"
COPY  "${M2_LOCAL_HOME_CONFIG}"    /home/$USERNAME/.m2/settings.xml
RUN  chown $USER_UID:$USER_GID -R  /home/$USERNAME/.m2

########################################   INSTALL  Build Image Tools #########################

#  Daemon Based - BuildPack client
ARG INSTALL_DAEMON_BUILD="true"
RUN if [ "${INSTALL_DAEMON_BUILD}" = "true" ]; then  sudo addgroup --system docker && sudo adduser $USERNAME docker &&  curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.25.0/pack-v0.25.0-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack; fi 

# [Option] Install Daemonless Builds Tools 
# It can not run in some versions
ARG INSTALL_DAEMONLESS_BUILD="true"
RUN if [ "${INSTALL_DAEMONLESS_BUILD}" = "true" ];  then sudo apt-get -y install buildah && sudo apt-get -y install podman; fi 
 
########################################   INSTALL Container Image Tools #########################



# Regctl - Client API para Registry
RUN curl -L https://github.com/regclient/regclient/releases/latest/download/regctl-linux-amd64 >regctl && sudo chmod 755 regctl && sudo mv ./regctl /usr/local/bin/regctl 

# Syft - SBOM
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

########################################   INSTALL Kubernetes Tools #########################


# Kubectl, Helm, Kustomize
ARG KUBECTL_VERSION=1.23.5
RUN   curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && sudo chmod 700 get_helm.sh && ./get_helm.sh && curl -sSLO -o /usr/local/bin/kubectl  "https://dl.k8s.io/release/v1.23.5/bin/linux/amd64/kubectl"  && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && sudo chmod a+x ./kustomize && sudo mv ./kustomize /usr/local/bin/kustomize && curl -Lo skaffold https://storage.googleapis.com/skaffold/builds/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/


#Install k9s
RUN sudo wget -c  https://github.com/derailed/k9s/releases/download/v0.25.18/k9s_Linux_x86_64.tar.gz -O - |   sudo tar -xz -C /usr/local/bin

########################################   INSTALL Debug Kubernetes Tools #########################

#  
# Install devspaces
RUN curl -s -L "https://github.com/loft-sh/devspace/releases/latest" | sed -nE 's!.*"([^"]*devspace-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o devspace && chmod +x devspace && sudo install devspace /usr/local/bin

# Install Telepresence
# 1. Download the latest binary (~50 MB):
RUN sudo curl -fL https://app.getambassador.io/download/tel2/linux/amd64/latest/telepresence -o /usr/local/bin/telepresence && sudo chmod a+x /usr/local/bin/telepresence

#Install Datree
RUN sudo curl https://get.datree.io | /bin/bash

#Install debug KoolKit ( Light run )
#COPY debug_wrapper.sh /home/${USERNAME}/debug_wrapper.txt
COPY debug_wrapper.sh  /usr/local/bin/debug_kube.sh 
RUN sudo chmod a+x  /usr/local/bin/debug_kube.sh
 
########################################   Configure Kubernetes Environment #########################


#Configura  Kubeconfig ambiente
# Script copies localhost's ~/.kube/config file into the container and swaps out 
# localhost for host.docker.internal on bash/zsh start to keep them in sync.
COPY copy-kube-config.sh /usr/local/share/
RUN sudo chown ${USERNAME}:root /usr/local/share/copy-kube-config.sh \
    && echo "source /usr/local/share/copy-kube-config.sh" |  sudo tee -a /root/.bashrc /root/.zshrc /home/${USERNAME}/.bashrc >> /home/${USERNAME}/.zshrc
 


 
 
#cd jib-extrai && wget  -qO- https://github.com/GoogleContainerTools/jib/releases/download/v0.10.0-cli/jib-jre-0.10.0.zip | jar xvf /dev/stdin
# install nc ( ncat )  e dig ( rede ) 
 

 
# tem sudo apt install shellcheck

# Setting the ENTRYPOINT to docker-init.sh will configure non-root access to 
# the Docker socket if "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]

  




