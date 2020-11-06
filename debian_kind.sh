#!/bin/bash
# To run 
# curl -LsSf https://gist.githubusercontent.com/rdwinter2/68809acd5e35f42c9319dddd316ff054/raw/d1d2da72f4924482bbbd0fb5d25bf4fcc7cdf246/debian_kind.sh | bash
echo "Running script... 🚀"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common dnsutils wget jq jid
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
newgrp docker

t=$(mktemp -d); pushd $t
sudo curl -fsSL "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo curl -fsSL -O https://github.com/vmware-tanzu/octant/releases/download/v0.16.1/octant_0.16.1_Linux-64bit.deb
sudo apt-get install ./octant_0.16.1_Linux-64bit.deb
curl -fsSL -O "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install --mode=755 --owner=root ./kubectl /usr/local/bin
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
curl -fsSL https://github.com/jenkins-x/jx-cli/releases/download/v3.0.652/jx-cli-linux-amd64.tar.gz | tar xzv 
sudo install --mode=755 --owner=root ./jx /usr/local/bin
curl -fsSL -o ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
sudo install --mode=755 --owner=root ./kind /usr/local/bin
popd

cat <<-EOT | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.19.1@sha256:98cf5288864662e37115e362b23e4369c8c4a408f99cbc06e58ac30ddc721600
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOT
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.4/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.4/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
export address_prefix=$(docker network inspect kind | jq ".[0].IPAM.Config[0].Gateway" | sed -e 's/"//g' | awk -F. '{print $1 "." $2}')
echo $address_prefix
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $address_prefix.255.1-$address_prefix.255.250
EOF
# kubectl get all --all-namespaces
echo "===================================================================="
# kubectl get pods,serviceaccounts,daemonsets,deployments,roles,rolebindings -n metallb-system
echo "===================================================================="

helm repo add traefik https://helm.traefik.io/traefik
helm repo update
kubectl create ns traefik
helm install --namespace=traefik traefik traefik/traefik
cat <<- EOT | kubectl apply -f -
# dashboard.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(\`traefik.localhost\`) && (PathPrefix(\`/dashboard\`) || PathPrefix(\`/api\`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
EOT
# curl -vik --resolve traefik.localhost:443:172.18.255.1 https://traefik.localhost/dashboard

# The workflow is:
# 1) make a registry (with certs for the registry). In our case we have several root certs that we can get from nexus with the curl command you previously showed
# 2) manually deploy a KinD server, with plugin mods to add the registry as a mirror (but it will be untrusted)
# 3) docker cp <certs> kind-control-plane:/usr/local/share/ca-certificates/
# 4) docker exec -it kind-control-plane update-ca-certificates
# 5) then deploy tkg, telling it to use the manually spun up KinD for the bootstrap

echo "Run:: newgrp docker"
echo "Done. 👍"