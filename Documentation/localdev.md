# Local development environment with docker compose

This document provides a brief overview of the basic components of the pacman 
application. The focus is to set up a local development environment
using docker-compose. 

Required tools:
+ a shell (bash)
+ docker
+ docker-compose

optional tools:
+ gnu make

## Docker

A command line interface used to communicate with a locally running `dockerd`, a
long-running daemon process. 

+ [docker engine official docs](https://docs.docker.com/engine/)


## Docker compose 

`docker-compose` is a tool for running multi-container applications on your
local machine. It's a good way to test out containerized applications before
deploying them to a cloud platform like kubernetes.

+ [docker-compose official docs](https://docs.docker.com/compose/)


## gnu make

This a build utility most commonly used for wrapping compile commands for
specific programs - these tended to be written in C, historically. 
It can also be used as a way to interface with the system shell and perform 
setup steps on a system before building a program. It involves writing a 
`Makefile` that specifies the required build targets and their dependencies. 
In this tutorial, it is only being used to wrap a few shell commands. 
Exactly what commands are being used will be documented below, these can also be
run as shell scripts, incase you prefer not to install make.

+ [gnu make docs](https://www.gnu.org/software/make/manual/make.html)


# Quickstart 

You can leverage an existing target in the makefile to set up persistent storage
for local development. The `data_volume` target is designed to make a new
subdirectory named `./localdev/data`. After creating the subdirectory, we need
to set the correct permissions.

Set up the data volume either by running the following make command:

```bash
sudo make data_volume
```

Or the equivalent bash commands:

```bash
mkdir ./localdev/mongodb
sudo chown -R 1001:1001 ./localdev/mongodb
```

As soon as the volumes are configured on the host machine, you can run docker
compose to start the application: 

```bash
sudo docker-compose -f localdev/docker-compose.yml up
```

# Requirements

The structure of our application is relatively straight forward: there are two
isolated environments that we wish to run on a single host. These two
environments need to be able to communicate with one another by way of sockets. 
This effectively means that both environments need to be on the same
network. Additionally, we would like to persist data by way of recording 
entries in a database. 

# docker-compose file

The file itself is written in yaml format, essentially a set of key-value pairs.
There are three top level sections in our docker-compose file, each one is
explained in more detail below.

## Services

The core of our docker compose file is made up of two service definitions,
named app and db. 

```yaml
services:
  app:
    image: ghcr.io/austriandatalab/pacman:v0.0.6
    container_name: adls-pacman-app
    env_file:
      - local-dev-app.env
    depends_on:
      - db 
    networks:
      - adls-pacman-net
    ports:
      - 8080:8080
    healthcheck: https://docs.docker.com/engine/reference/commandline/exec/
      test: wget --quiet --tries=3 --spider http://localhost:8080 || exit 1
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

  db:
    image: bitnami/mongodb:4.4.14
    container_name: adls-pacman-mongodb
    env_file:
      - local-dev-mongodb.env
    volumes:
      - ./mongodb:/bitnami/mongodb
    networks:
      - adls-pacman-net
    ports:
      - 27017:27017
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongo adls-pacman-mongodb:27017/test --quiet
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
```

The following table offers a brief description of each key and the function of
the associated value, as contained within a service definitihttps://docs.docker.com/engine/reference/commandline/exec/on. 

| key            | function                                             |
|----------------|------------------------------------------------------|
| image          | location of the container image to be downloaded     |
| container_name | use a predefined name for ease of reference          |
| env_file       | sets variables in the containers runtime environment |
| volumes        | map a storage volume in the form <host>:<container>  |
| networks       | the service should be available on these networks    |
| ports          | the service exposes these ports                      |
| healthcheck    | recurring check to see that the container is healthy |
| restart        | rules for restarting the service                     |


### Containers 

#### adls-pacman-app

The app itself is a simple nodejs application that has two primary functions: 
to serve the broswer-based frontend of our application and communicate with
the database via an API. 

The actual container image is something that we also specify in the top-level
`Dockerfile`

```Dockerfile
FROM node:latest

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Clone game source code
COPY src .

# Install app dependencies
RUN npm install

# Expose port 8080
EXPOSE 8080

RUN usermod -o -u 1000 node
USER 1000

# Run container
CMD ["npm", "start"]
```

#### adls-pacman-mongodb

The container image for our mongodb container is built by bitnami. We simply
reference the location of the image and tell docker compose to download it for
us. It's useful to note that this is a `non-root` container, meaning that it
does not require the internal mongo process to run with root permissions. The
process is instead run by user 1001. 

### Environment variables

It is possible to load environment variables into a container at build time and
at runtime. As a general rule of thumb, it's good to be mindful about exactly
what type of information you place into a container at build time. Any
environment variables that are placed into the container when the container is
being built typically will need to be hardcoded into the code that is used to
generate the container image. Any environment variables specified at this stage
will be persistent and visible to anyone who uses the container. So, it's
important to only encode information that is intended to be constant across all
possible instance of the application and also publically viewable. As a rule, 
you would never want to put secrets into a container at buildtime. 

Most applications will however require some extra configuration. Typically this
config is injected into the container at runtime. In our docker-compose example
the way that we do this is by using environment files. The content of these
files is for didactic purposes only and they do not contain any information that
we don't mind being public. For this reason we are showing their complete
contents below. Normally you would be much more secretive about your secrets.
You would never uplaod such an environment file to a public git repository. And
if somehow by chance it found its way in there, you would change all the
passwords that had been published!

```localdev/local-dev-app.env
MONGO_SERVICE_HOST=adls-pacman-mongodb
MONGO_USE_SSL=false
MONGO_AUTH_USER=localdev
MONGO_AUTH_PWD=secret123
```

```localhost/local-dev-mongodb.env
BITNAMI_DEBUG=false
MONGODB_ROOT_PASSWORD=mongo2root
MONGODB_DATABASE=pacman
MONGODB_USERNAME=localdev
MONGODB_PASSWORD=secret123
ALLOW_EMPTY_PASSWORD=no
MONGODB_SYSTEM_LOG_VERBOSITY=0
MONGODB_DISABLE_SYSTEM_LOG=no
MONGODB_DISABLE_JAVASCRIPT=no
MONGODB_ENABLE_JOURNAL=yes
MONGODB_PORT_NUMBER=27017
MONGODB_ENABLE_IPV6=no
MONGODB_ENABLE_DIRECTORY_PER_DB=no
```

#### Exercise 1

Start the application as outlined in [quickstart](#Quickstart). Play the game and 
save a high score. Use the `docker exec` command to run start interactive shell 
session in the `adls-pacman-app` container. 

Hint: [docker exec docs](https://docs.docker.com/engine/reference/commandline/exec/)

Once in the interactive shell session, reset the MONGO_AUTH_USER variable to
some other value. 

Play the game again and try to save a high score. Does it work? Examine the
container logs and explain what you find.

## Networks

The docker compose file defines a network called `adls-pacman-net` and attaches
our two services to this network. This is what we need to enable communication
between the two containers.

## Volumes 

The docker-compose file defines a single volume that gets mounted into the
running container. As noted in the [quickstart](#Quickstart) section above,
we need to first create a directory on the host system that has the correct
permissions set to enable read and write operations by the process running
within the container. In this case, it is the mongo process running as 1001:1001
that will be reading to and writing from persistent storage.

### Exercise 2

You've been asked to investigate a bug related to docker networks. Some of the
developers that you work with have had trouble with the wifi cards running on
their local machines. In particular, they've been experiencing drop-outs or
reduced functionality. The problem seems to crop up from time to time if there
are multiple docker networks running on the machine.

Your job is to run the `ip addr` command within the `ldevex`, and "pipe" the
output to a new file. You want this data to be readable from your host system,
so you are using a path under the volume defined in the docker-compose file: 
`/opt/data/net_info.txt`. You will use the data to check that the network
interfaces defined in the container matches those running on the host machine. 
Eventually you want to remove any "zombie" networks. The only problem is that
you seem to be having some trouble writing data to the volume attached
to the running container.

The following steps rely on files in the `localdev/exercises/volume_permissions/` 
directory.

1. Run the container using the docker-compose command `sudo docker-compose up`
2. Try to pipe the required data to the file: `ip addr > /opt/data/net_info.txt`
3. Fix the permission denied error.

