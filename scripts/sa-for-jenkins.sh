/bin/bash

sudo kubectl create ns jenkins
sudo kubectl create serviceaccount jenkins -n jenkins
sudo kubectl create rolebinding jenkins-admin-binding --clusterrole=admin --serviceaccount=jenkins:jenkins -n jenkins
sudo kubectl apply -n jenkins -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-secret
  annotations:
    kubernetes.io/service-account.name: jenkins
type: kubernetes.io/service-account-token
EOF
sudo kubectl describe secret jenkins-secret -n jenkins | grep token: | awk '{print $2}'