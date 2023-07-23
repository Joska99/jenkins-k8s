<h1>Jenkins CI/CD lab</h1>
<h2>Jenkins CI/CD pipeline with slave in kubernetes (IN PROGRESS!!!!) </h2>
<p align="center">
<img src="https://github.com/Joska99/jenkins-k8s/blob/main/diagram.drawio.svg">
</p>

<h2> Requirements: </h2>

1. Kubernetes cluster
2. Jenkins server:
- [My Jenkins Container guide](https://github.com/Joska99/joska/tree/main/docker/jenkins)
3. Add DockerHub and Cluster credentials to Jenkins
4. Install Jenkins plugins:
- Kubernetes plugin
- GitHub Integration Plugin


<h2> Add credential to Jenkins server: </h2>

1. In Jenkins portal: Go to "Manage Jenkins" -> "Credentials"
2. Click on "global"
3. Chose "Add credentials"

- Docker Hub
1. Chose "Username with Password"
2. Fill credentials fields
>ID - DockerHub-LG </br>
>password - password </br>
>username - username 
3. Add description


<h2> Add plugins to Jenkins: </h2>

1. In Jenkins portal: Go to "Manage Jenkins" -> "Plugins" -> "Available plugins"
2. Search for "GitHub Integration Plugin" and install
3. Search for "Kubernetes plugin" and install

</h2> Configure Slaves in Kubernetes cluster: </h2>

1. In Jenkins portal: Go to "Manage Jenkins" -> "Nodes and Clouds" -> "Cloud"
2. then "Add a new cloud" -> "Kubernetes"
3. Name: Kubernetes
4. Open: "Kubernetes cluster details"
5. In "Kubernetes url" add url of yor cluster 
```bash
cat ~/.kube/config | grep server:
``` 
6. "Disable https certificate check" - for local tests only
7. In kubernetes cluster CLI run those commands to create ServiceAccount for Jenkins in cluster:
>Create namespace for Jenkins:
```bash
sudo kubectl create ns jenkins
```
>Create service account for Jenkins
```bash
sudo kubectl create serviceaccount jenkins -n jenkins
```
>Add roles to this service account
```bash
sudo kubectl create rolebinding jenkins-admin-binding --clusterrole=admin --serviceaccount=jenkins:jenkins -n jenkins
```
>Generate token for service account
```bash
sudo kubectl apply -n jenkins -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-secret
  annotations:
    kubernetes.io/service-account.name: jenkins
type: kubernetes.io/service-account-token
EOF
```
>Print the token
```bash
sudo kubectl describe secret jenkins-secret -n jenkins | grep token: | awk '{print $2}'
```
>Copy the output

8. Specify "kubernetes NameSpace" to "jenkins"
9. Add the secret token as "secret text" to the Jenkins 
>Kind - Secret text
>ID - SA-k8s </br>
>Secret - token
10. Save

<h2> Steps: </h2>

1. Configure GitHub WebHook

- In GitHub repo: Go to "Setting" -> "Webhooks"
- Payload URL: https://<UR_PUBLIC_IP>:8000/github-webhook/
>You need to expose container from localhost to internet </br>
>You can use ngrok to achieve this </br>
>Run this with ngrok installed 
```bash
ngrok.exe http 8000
```
>copy link and paste to "Payload URL" </br>
>example: https://2966-93-172-72-111.ngrok.io/github-webhook/

- Content type: "application/json"
- In "Witch events would trigger?" chose "Just the push event"
- In "Secret" add API token from Jenkins
>in Jenkins portal click on your user name on right top and chose "Configure" </br>
>Scroll till "API Token" and generate new

- Click on "Add webhook"

2. Configure Jenkins
- In Jenkins portal: Navigate to "New Item"
- Give "Name" to item and Chose "Pipeline"
- You can add description to the pipeline
- Then chose "Github project" and add Github repo URL
- Then in "Building Triggers" select "GitHub hook trigger for GITScm polling"
- In Pipeline select "Pipeline script from SCM", SCM is "Git" add Github repo URL, specify branch, "Script Path" is File name "Jenkinsfile"


