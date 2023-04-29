<p align="center">
<h1>Jenkins CI/CD labs</h1>
<h3>Pipline automatically buil Docker-Image, Push to DockerHub and ACR, then Deploy to AKS cluster using Jenkins</h3>
<img src="https://github.com/Joska99/jenkins-k8s/blob/main/diagram.drawio.svg">

<h2>Requirements:</h2>

1. [AKS cluster and ACR](https://github.com/Joska99/joska/tree/main/terraform/tf-aks)
2. Attach ACR to AKS:
``` Bash
az aks update -n "AKS NAME" -g $RG_NAME --attach-acr $ACR_NAME"
```
3. Create Service Principal and RBAC for ACR:
- In Azuer Portal CLI create Service Principal for Jenkins:
> Create variables
``` Bash
ACR_NAME=ACR_NAME
SERVICE_PRINCIPAL_NAME=SP_NAME
```
> Get ACR ID
```Bash
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)
```
> Get Service Principal Username and Password
```Bash
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)
```
> Print Service Principal Username and Password
```Bash
echo $PASSWORD
echo $USER_NAME
```
> Add RBAC role to Service Principal to Push images to ACR
```Bash
az role assignment create --assignee $USER_NAME  --scope $ACR_REGISTRY_ID --role acrpush
``` 

4. Note .kubeconfig:
> Connect to cluster
``` Bash
az aks get-credentials --resource-group "RG NAME" --name "AKS NAME"
```
> Print and Note config
```bash
cat .kube/config
``` 
5. Jenkins server or [Container](https://github.com/Joska99/joska/tree/main/docker/stateful-jenkins)

<h1> Steps: </h1>

1. In Jenkins portal: Go to "Create Item"
2. Give Name and Chose "Pipeline"
3. Chose Github project and add Github repo
4. In "Building Trigers" select "GitHub hook trigger for GITScm polling"
5. In Pipline select "Pipline script from SCM" and "Script Path" is File name

<h3> Add credential to Jenkins server:</h3>

1. In Jenkins portal: Go to "Jenkins Seetings" -> "Managee Credentials"
3. Chose "Add credentials"

> Docker Hub
1. Chose "Username with Password"
2. Give credentials to Jenkins
3. Name it and add Description

> ACR
1. Go to "Jenkins Seetings" -> "Manage Plugins" -> "Available plugins"
3. Download "Azure credentials" plugin
4. Back to "Add credentials"
5. Chose "Azure Service Principal"
Subcription ID=Subscription ID<br />
Client ID=Application ID<br />
Tenant ID=AZ AD ID<br />
Client Secret=Secret<br />
6. Name it and add Description

>Kube config

1. Go to "Jenkins Seetings" -> "Manage Plugins" -> "Available plugins"
2. Download "Kubernete CLI" plugin 
3. Back to "Add credentials"
4. Chose "Secret file"
5. Add kube config file
6. Name it and add Description
