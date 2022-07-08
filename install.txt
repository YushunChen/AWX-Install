#!/bin/bash

minikube delete

minikube start --cpus=4 --install-addons=true --kubernetes-version=v1.21.4 --memory=6g
minikube status
alias kubectl="minikube kubectl --"
kubectl cluster-info

while true
do    
    if kubectl get nodes | grep -q 'Ready'; then
        break 1
    else
        echo "not ready"
    fi
done

echo "✨✨✨✨✨All good ✨✨✨✨✨✨"

docker login
# login with your docker hub credentials
cat /home/$USER/.docker/config.json
kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/$USER/.docker/config.json --type='kubernetes.io/dockerconfigjson'
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'
kubectl apply -f https://raw.githubusercontent.com/ansible/awx-operator/0.12.0/deploy/awx-operator.yaml
kubectl get pods

while true
do    
    if kubectl get pods | grep -q 'Running'; then
        break 1
    else
        echo "Not ready... retyring in 5 seconds 😭😭😭😭 ඞඞඞemergency meeting!!!! AWX is acting SUS!!!ඞඞඞ"
        sleep 5
    fi
done

echo "Out of the loop"
#vi ansible-awx.yml

cat <<EOF >ansible-awx.yml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: ansible-awx
spec:
  service_type: nodeport
  ingress_type: none
  hostname: ansible-awx.example.com
EOF

kubectl apply -f ansible-awx.yml

while true
do    
    if kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator" | grep -q '1/1     Running'; then
        break 1
    else
        echo "Postgres is not ready... retyring in 5 seconds"
        sleep 5
    fi
done

while true
do    
    if kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator" | grep -q '4/4     Running'; then
        break 1
    else
        echo "Retrying in 15 seconds! Creating awx pods NOW!!!! Current status:"
        kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
        sleep 15
    fi
done

kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"
