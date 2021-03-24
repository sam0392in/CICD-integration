# Sample Web Application on Kubernetes

## Summary
- This project aims to create and deploy a highly available, load balanced stateless web application onto a kubernetes cluster.

## Pre-requisites
- Kubernetes cluster with atleast 3 worker nodes.
- Jenkins installed for CICD.
- Cert-manager and issuer already deployed on kubernetes cluster which points to lets-encrypt api.
- Docker installed and running.
- kubectl CLI installed.
- Helm installed.
- A registered domain.

## Tech Stack
- Python v3.7
- Helm v2.7.1
- kubernetes
- kubectl cli v1.19.8

## Application Architecture

![alt text](./readme_images/architecture.png?raw=true)

- Architecture consist of 
  - 1 Deployment 3 replicas of flask server running in it.
  - 1 Cluster-IP service pointing to application pods.
  - 1 Ingress with 2 subdomains.

## Application Features

- Application is highly available as **3 replicas which runs on 3 different worker nodes**.
- This  achieved by using **pod anti-affinity** in deployment file of application.
- Application is **load balanced** as one service distributes the traffic evenly to all the application pods.
- Applcation **runs with a non-root user**.
- The application also exposes a health check on route /health.
- Application has **readiness probe** used in deployment.
- Readiness probe will make sure that application is **completely ready before serving traffic**.  
- Application also used **liveliness probe** to make sure that application is live all the time.
- Application features 2 subdomains.
    - **_sam-app.samdevops.co.in_** will serve as a landing page.
    - **_aboutme.samdevops.co.in/myinfo_** will serve as feature page.
  
## Automated CICD process of Application
- Below diagram explains CICD process step by step.

![alt text](./readme_images/cicd.png?raw=true)

### CICD Process step by step explanation
- Continuous Integration is achieved by jenkins with multi branch pipeline job.
- For Pull-Request branch, build will happen but packaging and deployment will not take place.
- In the current scenario, build step will only be a syntax check of the python code.
- For Master branch, build step will check syntax.
- On successful completion of master branch build, Docker image will be created from the artifact.
- This docker image will be pushed to Docker registry.
- Chart version and image will be updated in Chart.yaml and values.yaml respectively.
- Next step is to package the application and push the newly created chart to the Chartmuseum (Helm chart Repository).
- Final stage to deploy the helm chart to kubernetes cluster(dev environment).
- Promotion of same chart will be done to further environments i.e staging, pre-prod and prod depending upon successful completion of each environment.

## Manual Steps to deploy Application ( _Optional_ )

- Clone the repo
```
git clone https://github.com/sam0392in/sam-projects.git
```

- Build the docker image (optional, incase you want use your personal docker registry)
```
docker build -t __YOUR_REPO_NAME/sampleapp:latest
```
- If you want to use the image which is already built with the project then leave above step.

- Update the image in values.yaml file placed under _charts/sam-http-server_ directory in case you have built the new image.

- Update Chart Version in Chart.yaml file placed under _charts/sam-http-server_ directory in case you have built the new image.
- Go to Charts/sam-http-server
```
cd Charts/sam-http-server
```

- Install the application with helm command
```
helm install sam-http-server . --namespace webapp

----- OUTPUT ------


NAME:   sam-http-server
NAMESPACE: webapp
LAST DEPLOYED: Tue Mar 22 10:55:42 2021
STATUS: DEPLOYED
```
- Resources created as below:

```
NAME                                   READY   STATUS    RESTARTS   AGE
pod/sam-http-server-5666885b4-hdh2g    1/1     Running   0          32s
pod/sam-http-server-5d4689c7c8-hnrx5   1/1     Running   0          32s
pod/sam-http-server-bc886d859-h4c6p    1/1     Running   0          32s

NAME                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/sam-http-server-svc   ClusterIP   10.101.88.70   <none>        80/TCP    32s

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/sam-http-server   3/3     3            3           32s

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/sam-http-server-5666885b4    3         3         3       32s

NAME                      CLASS    HOSTS                                             ADDRESS   PORTS   AGE
sam-http-server-ingress   <none>   sam-app.samdevops.co.in,aboutme.samdevops.co.in             80      5m13s


```

## Validation

- When all the pods are running successfully then validation has to be done.

- Now Go to browser and check the host
- **_NOTE: This domain backend points to my server. Kindly use your domain._**

- Enter the URL in browser http://sam-app.samdevops.co.in

![alt text](./readme_images/index.png?raw=true)

- Now click on aboutme which will redirect to different domain (http://aboutme.samdevops.co.in)

![alt text](./readme_images/aboutme.PNG?raw=true)


## Provisioning Certificates using LetsEncrypt

- Let's Encrypt is a free, automated, and open certificate authority by the nonprofit Internet Security Research Group (ISRG).
- Below steps features to setup and configure application with letsencrypt.

### Installing and Configuring Cert-Manager
```
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.yaml
```

### Create Cluster Issuer
```
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: sam0392in@gmail.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: webapp-tls
    # Enable the HTTP-01 challenge provider
    solvers:
    - http01:
        ingress:
          class: nginx
```

### Deploy Webapp Ingress with Cluster Issuer

```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: sam-http-server-ingress
  annotations:
    kubernetes.io/ingress.class: nginx 
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - sam-app.samdevops.co.in
    - aboutme.samdevops.co.in
    secretName: webapp-tls
  rules:
    - host: sam-app.samdevops.co.in
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sam-http-server-svc
                port:
                  number: 80

    - host: aboutme.samdevops.co.in
      http:
        paths:
          - path: /myinfo
            pathType: Prefix
            backend:
              service:
                name: sam-http-server-svc
                port:
                  number: 80

```