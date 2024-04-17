# Welcome to your Kubernetes Beginner Tutorial
The main aim is to play with the main components of a k8s deployment.
While most components are generic to any k8s, this Rancher-based teaching cluster
requires some specific annotations.

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

# Pacman on kubernetes

This tutorial uses a sample application a html5 version of the classic arcade
game. The source code to follow along with the tutorial is on 
[github](https://github.com/AustrianDataLAB/pacman). The sections that follow
assume that you have downloaded that source code. The repository itself contains
the source code for the application, as well as the code for packaging and
deploying the application to a kubernetes cluster.

## Prerequisites

+ You can access a kubernetes cluster
+ You have downloaded the kubeconfig from the cluster and stored it locally
+ You have installed [kubectl](https://kubernetes.io/docs/tasks/tools/) 

### Set up local environment variables 

You'll need to set three environment variables locally. These enable
communication with the cluster. You'll probably want to write the following 
values to a `.env` file. Note that it's important not to make these values public, 
in other words, don't upload it to a public repository. The following values are all
placeholders, you'll need to replace them with relevant values for your setup.
Details on each of the variables follow below.

```bash
cat <<EOF > .env
export KUBECONFIG=/home/user/path/to/kubeconfig.yaml
export pacman=<Namespace where you will deploy pacman>
export host=<Hostname of your cluster>
EOF
```

1. `$KUBECONFIG`, the absolute path to the kube configuration file for the cluster.
   Download from the RancherUI and save locally.
2. `$pacman`, the target [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
   for deployment. Appears in the RancherUI, in drop-down menu
   on the top right under "Only User Namespaces". Follows the form `u-XXXXX`
   where `XXXXX` are random characters.
3. `$host`, the DNS hostname for the cluster.

## Overview of kubernetes directory 

As outlined in the Architecture section of the README file, the pacman
application contains at least two major components. Starting with the more 
obvious parts of the application - we know that we will need a container running the
application code, and another running the database. If you've looked into
setting up a local development environment for the application with docker
compose, the application will have run on your local system. 

Remember that containers are basically designed to be stateless, interchangeable 
entities. As such, the containers do not contain any sensitive information about
such as configuration values that the application needs at run time. For example,
credentials used by the client to interact with the database. The host injects
these values at run time. 

As well as reading values from the host system's memory, when the client sends
a request to write entries to the database, we want this data to stick around 
and be accessible for future visitors. To make this possible, the database 
container needs special write permissions to a data volume mounted on the host.

The two main components need to talk to each other over a socket connection in a
network provided by the host system. We also need to create an entry point so
that user's can access the application via the internet.

The following is an overview of the kubernetes directory, this contains a set of
sub directories, each containing one or more yaml files with the information
needed by kubernetes to set up the application. Note also the two shell
scripts, these act as handy wrappers that tie together the individual `kubectl` 
commands used to deploy the application to the cluster. 

```sh
kubernetes/
├── configmap
│   └── pacman-mongo-common-scripts.yaml
├── deployments
│   ├── mongo-deployment.yaml
│   └── pacman-deployment.yaml
├── ingress
│   └── ingress.txt.yaml
├── pacman-install.sh
├── pacman-uninstall.sh
├── persistentvolumeclaim
│   └── mongo-pvc.txt.yaml
├── security
│   ├── rbac.yaml
│   └── secret.txt.yaml
└── services
    ├── mongo-service.yaml
    └── pacman-service.yaml

7 directories, 11 files
```


## Tutorial Part I: Learn how a k8s-"deployment" works by running Pac-Man 

The classic arcade game - modified/upgraded for our Rancher cluster so you may have fun modifying its components.

<p float="left">
<img src="https://raw.githubusercontent.com/AustrianDataLAB/img/main/PacMan-1.png" width=45% height=45%>
<img src="https://raw.githubusercontent.com/AustrianDataLAB/img/main/PacMan-Game.png" width=50% height=50%>
</p>

See the original application: https://vzilla.co.uk/vzilla-blog/building-the-home-lab-kubernetes-playground-part-9

## Deployment

The main tool used to deploy and manage applications on kubernetes is the command
line interface `kubectl`, see the [documentation](https://kubectl.docs.kubernetes.io/)
for more info related to installing the tool and getting up to speed with basic
commands.

As mentioned in the preceding paragraphs, we're using a shell script to deploy
our application. This script contains basically two steps: 
1) It uses the `envsubst` command to populate templates using environment variables
2) It runs `kubectl apply -n <namespace> -f <path/to-resource.yaml>` for each
resource that we have defined.

### configmap

A configmap may contain any information that you want to mount into the environment 
of the container at run time. This can be configuration data for the application, 
environment variables to set, or specific files.

The configmap directory contains three scripts that we want to use to
while the containers are running. Processes running in the mongodb container
will execute these scripts as `liveness`, `readiness` and `startup` probes,
respectively.


### deployments

The deployments directory contains two yaml files, each describing a core
component of our application: the pacman and mongodb containers. 

### ingress

The ingress directory contains a template for our ingress file. At line 7 in the
`pacman-install.sh` executes the `envsubst` program. This command substitutes 
variables with values from the environment to create a coherent ingress configuration. 

For a general introduction to what an ingress is and what it does, see the [kubernetes
documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/).
For more specific info about to the ingress controller installed on our cluster, 
see the [nginx ingress docs](https://kubernetes.github.io/ingress-nginx/)

### persistentvolumeClaim 

The persistentvolumeClaim directory has a single resource definition aimed at
telling the cluster to provision some storage use by the database container. 


### services 

The services directory specifies the services that we wish to expose within the
namespace where we are deploying the application. These services provide the
specification for the sockets over which the application can talk to the
database. Further more, they provide information about the socket that the nginx 
controller will use to direct requests to the front end of the application.


## Install 

Make the script executable, source the environment file and run the script.

```bash
chmod +x pacman-install.sh
source .env
./pacman-install.sh
```

## Uninstall 

Run file `./pacman-uninstall.sh`. This will delete all objects created by `./pacman-install.sh`
It does so by running `kubectl delete -n <namespace> -f <path/to-resource>` for
each resource.

Run `./pacman-uninstall.sh keeppvc`. This will delete all objects except for 
the pacman namespace and the persistent volume claim. You can use this to persist MongoDB 
data by installing, playing a game and recording a high score, then uninstalling 
with the `keeppvc` argument. You can then run the installation again and the high score will persist.

# Exercises

Before adding the ingress/cert, make sure you understand what that does and that 
you know how to keep your certificate 'safe' consult the 
[cert-manager documentation](https://cert-manager.io/docs/) for more info.

## Task 1: lets add ingress and a certificate
Your Mission, if you choose to accept it: 

Expose your service to the internet and use a TLS certificate.

## Task 2: follow the network traffic
Your Mission, if you choose to accept it: 

Understand what network connections are in place. How is communication between
components happening?
HINT: use hubble (HINT: not the telescope).

## Task 3: Scan and Upgrade: Know what is inside
Your Mission, if you choose to accept it: 

Scan the deployment and upgrade everything.
 

## Task 4: make this better by adding a network policy
Your Mission, if you choose to accept it:

Give it as little permissions as possible, for example: make a policy that restricts communication to 
a single channel between the pacman-pod to talk to the mongo-service.

You can test this by installing mongo-express (a common UI for mongo-db) and trying to connect to the 
mongo-db, before and after your policy is in place. Make sure you understand when the UI can connect,
and when it cannot. Also use hubble to debug.

````bash
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm install mongo-express cowboysysop/mongo-express -n $pacman --set mongodbServer=mongo --kubeconfig ~/Downloads/local-2.yaml
````

TODO: set the authentication in mongo-express properly

## Using Helm to install
First, make sure you uninstalled everything.

Six possible ways to install a helm chart exist. The [helm docs](https://helm.sh/docs/helm/helm_install/)
describe each in detail.

### Bare bones helm 

It's common to create a specific directory to house the helm charts within your,
this is typically a directory titled `charts` or `Charts` in the top level
directory of the repository that houses your code and tests.

From the top level of your repository: 
```bash
helm create charts/pacman-custom
```

The `helm create` command creates a directory and populates it with files
according to a standardized structure. Again, you can read about the [helm
create](https://helm.sh/docs/helm/helm_create/) command in the helm
documentation.

For the purposes of our pacman application, it's instructive to read
[this blog post](https://veducate.co.uk/how-to-create-helm-chart/).
This documents how the author created the original helm chart.

Once you've added the necessary files and values to the chart, it's time to
package the chart. This involves creating an archive that is later used to deploy
the chart onto the cluster.

```bash
helm package charts/pacman-custom -d charts
```

This should result in the archive `charts/pacman-custom-0.1.0.tgz`. 
install this archive to the cluster. The following assumes that
you are using the same environment variables established in the preceding
sections. The `-n` flag is shorthand for `namespace` the variable `$pacman`
references a specific namespace on the cluster.

It's illustrative to tell helm to do a "dry run" of the installation first.

```bash
helm install pacman-custom charts/pacman-custom-0.1.0.tgz -n $pacman --dry-run
```

If the output is satisfactory, you can install the chart to the cluster
with the following command:
```bash
helm install pacman-custom charts/pacman-custom-0.1.0.tgz -n $pacman
```

To uninstall the chart, you can use the following command:
```bash
helm uninstall pacman-custom -n $pacman 
```
