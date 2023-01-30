# Pacman

Tutorial Application for Teaching k8s on k8s

Rewritten from the original to work on a hardened rke2
(this is not claiming to be original work, I took it from: 
https://vzilla.co.uk/vzilla-blog/building-the-home-lab-kubernetes-playground-part-9 )

# Documentation 

+ [Set up a local development environment using docker compose](Documentation/localdev.md)
+ [Understand linux containers](Documentation/containers.md)
+ [Deploy pacman on kubernetes](Documentation/kubernetes.md)

## Support and Community Slack
https://aocc-public.slack.com/join/signup

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

<img src="https://raw.githubusercontent.com/AustrianDataLAB/img/main/PacMan-Game.png" width=50% height=50%>

## Source

These are modified files from the below github repos , changed mildly to make them run contained in a single namespace and without priviledged pods.

> <https://github.com/saintdle/pacman-tanzu.git>


> <https://github.com/font/k8s-example-apps/tree/master/pacman-nodejs-app>


## Recommended Reading

Snyk's vulnerability database: https://security.snyk.io/vuln/npm 
