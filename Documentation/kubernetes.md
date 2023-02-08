# Pacman on kubernetes

The following is a brief introduction to deploying applications on kubernetes.

## Prerequisites

+ You can access a kubernetes clusters
+ You have downloaded the kubeconfig from the cluster and stored it locally
+ [kubectl](https://kubernetes.io/docs/tasks/tools/) is installed on your local machine

### Set up local environment variables 

You'll need to set a few environment variables locally in order to communicate
with the cluster. You'll probably want to write the following values to a `.env`
file. Note that it's important not to make these values public, in other words,
don't upload it to a public repository. The following values are all
placeholders, you'll need to replace them with relevant values for your setup.
A little more detail on each of the variables is given below.

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
   where the app will be deployed. Appears in the RancherUI, in drop-down menu
   on the top right under "Only User Namespaces". Follows the form `u-XXXXX`
   where `XXXXX` are random characters.
3. `$host`, the DNS hostname for the cluster.

## Overview of kubernetes directory 

As outlined in the Architecture section of the README file, the pacman application is
made up of a number of discrete components. Starting with the more obvious parts
of the application - we know that we will need a container running the
application code, and another running the database. If you've looked into
setting up a local development environment for the application with docker
compose, you may well have already witnessed these containers running on your
local system. As well as the code to run the application, we'll need to load
some configuration values into the containers. Remember that containers are
basically designed to be stateless, interchangeable entities. Any specific
configuration values are loaded from the host system into the guest container at run time.
Conversely, when we write entries to the database, we want this data to stick
around. So we need to tell the host system about our requirement for a persistent
storage volume. In addition to these familiar components, we'll need to specify
some details related to the network - how our application connects into a
network, and how it is exposed publicly.

The following is an overview of the kubernetes directory, this contains a set of
sub directories, each containing one or more yaml files with the details of how
the various aspects of our application should be set up. Note also the two shell
scripts, these act as handy wrappers that tie together the individual commands
that are required to deploy the application to the cluster. It's worth reading
these two scripts.

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

## Deployment

The main tool used to deploy and manage applications on kubernetes is the command
line interface `kubectl`, see the [documentation](https://kubectl.docs.kubernetes.io/)
for more info related to installing the tool and getting up to speed with basic
commands.

As mentioned in the preceding paragraphs, we're using a shell script to deploy
our application. This script contains basically two steps: 
1) It uses the `envsubst` command to use the three environment variables that
were set using the steps outlined above.
2) It runs `kubectl apply -n <namespace> -f <path/to-resource.yaml>` for each
resource that we have defined.

### configmap

The configmap directory contains a number of scripts that we want to use to
while the containers are running. Typically a configmap will contain
environmental information (configuration data, or executable code) to load 
at run time. 

### deployments

The deployments directory contains two yaml files, each describing a core
component of our application: the pacman and mongodb containers. 

### ingress

The ingress directory contains a template for our ingress file. This will be
populated with values set in our local environment. For a general introduction
to what an ingress is and what it does, see the [kubernetes
documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/).
For more specific info related to the type of ingress controller that is
installed on our cluster, see the [nginx ingress docs](https://kubernetes.github.io/ingress-nginx/)

#### TUWien specific
In order to comply with the security requirements of the ADLS kubernetes clusters
running on the TUWien infrastructure, each ingress definition must include three
annotations. These tell the ingress controller where to redirect requests so
they can be authenticated, and it also tells the controller to perform a check
to ensure that any web requests are coming from within an allowed range of IP
addresses. You'll need to set this range and add it to your local environment file:

```bash
echo "export ip_whitelist_range=<IPs allowed to access publically exposed resources>" >> .env
```

### persistentvolumeClaim 

The persistentvolumeClaim directory has a single resource definition aimed at
telling the cluster to provision some storage for any information that will be
written by the database. 

### security 

The security directory contains some encrypted secrets that our application will
use. Note that this example uses open encryption (anyone with openssl or a
similar encryption tool can read the plain text values they hide). In a real
production application, you would not upload secrets like this to a public git
repository. Instead, you would use something called sealed-secrets to further
control access to the hidden values.

The rbac resource definition is not pertinent to our discussion at this time.

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

Alternatively, run `./pacman-uninstall.sh keeppvc`. This will delete all objects except for 
the pacman namespace and the persistent volume claim. You can use this to demonstrate persistence 
of the MongoDB data by installing, playing a game and recording a high score, then uninstalling 
with the `keeppvc` argument. You can then run the installation again and the high score will persist.



# Exercises

#### Note of caution: Cert manager will only sign very few official certificates per 168 hrs 
Before adding the ingress/cert, make sure you understand what that does and that you know how to keep your certificate 'safe'

## Task 1: lets add ingress and a certificate
Your Mission, if you choose to accept it: 

Expose your service to the internet and use a TLS certificate.

## Task 2: follow the network traffic
Your Mission, if you choose to accept it: 

Understand exactly who is talking to whom
HINT: use hubble (HINT: not the telescope).

## Task 3: Scan and Upgrade: Know what is inside
Your Mission, if you choose to accept it: 

Scan the deployment and upgrade everything.
 

## Task 4: make this better by adding a network policy
Your Mission, if you choose to accept it:

Give it as little permissions as possible, for example: make a policy that allows only the pacman-pod to talk to the mongo-service.
You can test this by installing mongo-express (a common UI for mongo-db) and trying to connect to the mongo-db, before and after your policy is in place.
Make sure you understand when the UI can connect, and when it cannot. Also use hubble to debug.

````bash
helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm install mongo-express cowboysysop/mongo-express -n $pacman --set mongodbServer=mongo --kubeconfig ~/Downloads/local-2.yaml
````

TODO: set the authentication in mongo-express properly

## Using Helm to install
First, make sure you uninstalled everything.

There are six possible ways to install a helm chart outlined in the [helm docs](https://helm.sh/docs/helm/helm_install/)
We're going to briefly cover one of the more simple variants here. In a
nutshell, a helm chart is a 

### Bare bones helm 

It's common to create a specific directory to house the helm charts within your,
this is typically a directory titled `charts` or `Charts` in the top level
directory of the repository that houses your code and tests.

From the top level of your repository: 
````bash
helm create charts/pacman-custom
```
The `helm create` command creates a directory and populates it with files
according to a standardized structure. Again, you can read about the [helm
create](https://helm.sh/docs/helm/helm_create/) command in the helm
documentaion.

For the purposes of our pacman application, it's instructive to read
[this blog post](https://veducate.co.uk/how-to-create-helm-chart/) to learn how
the original Helm Chart was created.

Once you've added the necessary files and values to the chart, it's time to
package the chart. This involves creating an archive that is later used to deploy
the chart onto the cluster.

```bash
helm package charts/pacman-custom -d charts
```

This should result in the archive `charts/pacman-custom-0.1.0.tgz`. The
resulting archive can then be applied to the cluster. The following assumes that
you are using the same environment variables established in the preceeding
sections. The `-n` flag is shorthand for `namespace` the variable `$pacman`
references a specific namespace on the cluster.

It's illustrative to tell helm to do a "dry run" of the installation first, the
following command will output the full contents of the chart that will be
applied to the cluster: 

```bash
helm install pacman-custom charts/pacman-custom-0.1.0.tgz -n $pacman --dry-run
```

If you are satisfied with the output, you can install the chart to the cluster
with the following command:
```bash
helm install pacman-custom charts/pacman-custom-0.1.0.tgz -n $pacman
```
To uninstall the chart, you can use the following command:

```bash
helm uninstall pacman-custom -n $pacman 
```

```bash
#Do this only if you really feel like you want to publish a package, normally we dont ever do this from localhost
#this is more to demonstrate that you *could* do it this way, please use a CI/CD pipeline for anything real world
helm repo index ~/gitrepos/pacman/helm --url http://adlsexample.org/charts
sudo sh -c "echo '127.0.1.99       adlsexample.org' >> /etc/hosts"
#create some form of a webserver, e.g. with python or apache or nginx and copy your files to the folder *charts*
cp ~/gitrepos/pacman/helm/* to webserverdir/charts
#now if your url is actually serving your tarball plus the index file, you can add it
helm repo add my-awesome-pacman http://adlsexample.org/charts
````
Since hosting files on a local web server is not the point of this exercise, lets just do the installation from 
local file-structure using the branch on our git repository that contains the sub directory `~/gitrepos/pacman/pacman-rancher/.`

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
