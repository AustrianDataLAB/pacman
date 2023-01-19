# Pacman

Tutorial Application for Teaching k8s on k8s

Rewritten from the original to work on a hardened rke2
(this is not claiming to be original work, I took it from : https://vzilla.co.uk/vzilla-blog/building-the-home-lab-kubernetes-playground-part-9 )

# Documentation 

+ [Local development environment using docker compose](Documentation/localdev.md)

## Currently WIP

## Support and Community Slack
https://aocc-public.slack.com/join/signup

# Welcome to your Kubernetes Beginner Tutorial

This is aimed at beginners to play with the main components of a k8s deployment.
While most components are generic to any k8s, some specific annotations are required for this Rancher-based teaching cluster.

At the end of this tutorial you will be able to:
* understand and use k8s manifests for the most common components
* understand how to find logs
* understand how to dig through the network
* understand how manifests are different from helm charts
* understand the difference between a statefulset and a deployment 
* inspect a secret
* understand the basics of RBAC (Role Based Access Control)
* generate a certificate using cert manager (or by hand, if someone has the patience)
* work with `kubectl` , `RancherUI` and `Lens` 

## Tutorial Part I: Learn how a k8s-"deployment" works by running Pac-Man 

Pac-Man the classic arcade game - modified/upgraded for our Rancher cluster so you may have fun modifying its components.

<p float="left">
<img src="https://raw.githubusercontent.com/AustrianDataLAB/img/main/PacMan-1.png" width=45% height=45%>
<img src="https://raw.githubusercontent.com/AustrianDataLAB/img/main/PacMan-Game.png" width=50% height=50%>
</p>
This was taken from https://vzilla.co.uk/vzilla-blog/building-the-home-lab-kubernetes-playground-part-9

## Pre-Reqs

You have a valid student user and have logged into RancherUI https://rancher.k8s.dev.austrianopensciencecloud.org/


Clone this git repository and change into the pacman directory 

```bash
git clone git@github.com:AustrianDataLAB/pacman.git
cd pacman
```

## Deployment

You will need to set three environment variables in your local environment in
order for the shell scripts to run correctly, and for the pacman application to
be deployed to the cluster.

1. `$KUBECONFIG`, the absolute path to the kube config file for the cluster.
   Download from the RancherUI and save locally.
2. `$pacman`, the target [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
   where the app will be deployed. Appears in the RancherUI, in dropdown menu
   on the top right under "Only User Namespaces". Follows the form `u-XXXXX`
   where `XXXXX` are random characters.
3. `$host`, the DNS hostname for the cluster. In the url: 
   "https://rancher.caas-0005.dev.austrianopencloudcommunity.org"
   the DNS hostname is: "caas-0005.dev.austrianopencloudcommunity.org"

### Create .env file 

Modify the values as they apply to you and save them to a file named `.env` 

```bash
cat <<EOF > .env
export KUBECONFIG=/home/user/k8s/clusters/caas-0005.dev/kubeconfig.yaml
export pacman=u-XXXXXX
export host=caas-0005.dev.austrianopencloudcommunity.org
EOF

```


### Using a Script for installation

Make the script executable, source the environment file and run the script.

```bash
chmod +x pacman-install.sh
source .env
./pacman-install.sh
```

#### Uninstall using a Script

Run file `./pacman-uninstall.sh`. This will delete all objects created by `./pacman-install.sh`

Alternatively, run `./pacman-uninstall.sh keeppvc`. This will delete all objects except for 
the pacman namespace and the persistent volume claim. You can use this to demonstrate persistence 
of the MongoDB data by installing, playing a game and recording a high score, then unininstalling 
with the `keeppvc` argument. You can then run the installation again and the high score will persist.

#### Note of caution: Cert manager will only sign very few official certificates per 168 hrs 
Before adding the ingress/cert, make sure you understand what that does and that you know how to keep your certificate 'safe'


## Task 1: lets add ingress and a certificate
Your Mission, if you choose to accept it:

expose your service to the internet and use a TLS certificate
HINT: checkout branch=`tutorial/ingress`


## Task 2: follow the network traffic
Your Mission, if you choose to accept it:

understand exactly who is talking to whom
HINT: use hubble (HINT: not the telescope)

## Task 3: Scan and Upgrade: Know what is inside
Your Mission, if you choose to accept it:

scan the deployment and upgrade everything
 
HINT: checkout branch=`tutorial/upgrades`
## Task 4: make this better by adding a network policy
Your Mission, if you choose to accept it:

give it as little permissions as possible, for example: make a policy that allows only the podman-pod to talk to the mongo-service.
You can test this by installing mongo-express (a common UI for mongo-db) and trying to connect to the mongo-db, before and after your policy is in place.
Make sure you understand when the UI can connect, and when it cannot. Also use hubble to debug.

````bash
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm install mongo-express cowboysysop/mongo-express -n $pacman --set mongodbServer=mongo --kubeconfig ~/Downloads/local-2.yaml
````

TODO: set the authentication in mongo-express properly
## Using Helm to install
First, make sure you uninstalled everything.

Now, there are two options, depending on how much time you want to spend, 
the barebone approach is the following:

````bash
helm create pacman-rancher

edit to your heart s content

helm package ~/gitrepos/pacman/pacman-rancher/. -d ~/gitrepos/pacman/helm
Successfully packaged chart and saved it to: /Users/croedig/gitrepos/pacman/helm/pacman-rancher-0.1.0.tgz

#Do this only if you really feel like you want to publish a package, normally we dont ever do this from localhost
#this is more to demonstrate that you *could* do it this way, please use a CI/CD pipeline for anything real world
helm repo index ~/gitrepos/pacman/helm --url http://adlsexample.org/charts
sudo sh -c "echo '127.0.1.99       adlsexample.org' >> /etc/hosts"
#create some form of a webserver, e.g. with python or apache or nginx and copy your files to the folder *charts*
cp ~/gitrepos/pacman/helm/* to webserverdir/charts
#now if your url is actually serving your tarball plus the index file, you can add it
helm repo add my-awesome-pacman http://adlsexample.org/charts
````
Since hosting files on a local webserver is not the point of this exercise, lets just do the installation from local file-structure using the branch on our gitrepo that contains the subfolder `~/gitrepos/pacman/pacman-rancher/.`


`git checkout -b tutorial/helm` 
Feel very free to add, improve and experiment with the (very basic) helm chart that you will now find.

````bash
helm upgrade --install pacmanhelm ~/gitrepos/pacman/pacman-rancher/. -n $pacman --create-namespace --kubeconfig ~/Downloads/local-2.yaml
````
For further commands with helm, please read the upstream documentation at helm.sh, here are some common commands:
````bash
# You can see the available values by running
helm ls pacmanhelm -n $pacman
helm get manifest pacmanhelm -n $pacman
````
[Read this blog post](https://veducate.co.uk/how-to-create-helm-chart/) to learn how the original Helm Chart was created.



## Architecture

The application is made up of the following components:

* Namespace
* Deployment
  * MongoDB Pod
    * DB Authentication configured
    * Attached to a PVC
  * Pac-Man Pod
    * Nodejs web front end that connects back to the MongoDB Pod by looking for the Pod DNS address internally.
* RBAC Configuration for Pod Security and Service Account
* Secret which holds the data for the MongoDB Usernames and Passwords to be configured
* Service
  * Type: ClusterIP
* Ingress
  * Using a certificate generated via certman

<img src="https://raw.githubusercontent.com/AustrianDataLAB/img/main/PacMan-1.png" width=50% height=50%>

## Source

These are modified files from the below github repos , changed mildly to make them run contained in a single namespace and without priviledged pods.

> <https://github.com/saintdle/pacman-tanzu.git>


> <https://github.com/font/k8s-example-apps/tree/master/pacman-nodejs-app>


## Recommended Reading

Snyk's vulnerability database: https://security.snyk.io/vuln/npm 
