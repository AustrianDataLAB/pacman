# Containers 

The development of containers arose from the need to offer a personalized view
of globally accessible resources on a computer system that was accessible by
many users. The form that exist today - linux containers - have their roots in 
some of the operating system features developed for unix and plan9, which were
developed at Bell Labs in the 1970s and 1980s.

The lesser known Plan 9 was built as a research project to answer some
questions about operating systems design. It followed in the wake of unix and
thus adopted and shared the [unix
philosophy](https://en.wikipedia.org/wiki/Unix_philosophy) of developing
minimalist, modular software to create an integrated experience. In terms of
hardware, unix was originally designed for the PDP-11, a type of minicomputer
developed in the 1960s.  

At the system level Plan9 aimed to have the users share resources on the system.
From the perspective of the operating system, there are various machines with
keyboards, mouse, screens that provide access to the resources of the network.
One of the early questions asked by Plan9 was how to give a personalized view of
globally accessible resources to users. This idea of presenting users with a
personalized view of the resources of a system is one of the central ideas of
containers. The reason for mentioning Plan9 in this context is that it seems to
be the first notable operating system to introduce the idea of a per process
name space. This turns out to be a relatively powerful concept  and one that
informed the long running development of namespaces in the linux kernel. Linux
namespaces have been around in one form or another for quite a while - their
earliest mentions in articles and emails on the development mailing list date
back to at least 2001, [kernel version
2.4.2](https://lwn.net/2001/0301/a/namespaces.php3). Michael Kerrisk presents 
a very good [overview of namespaces](https://lwn.net/Articles/531114/).

## Practical example: introduction to container runtimes

`ctr` is a client used to interact with the containerd daemon. Containerd is a 
container run-time: low-level libraries that are used indirectly by higher-level
orchestration environments such as docker or kubernetes.

Note: the following examples assume that you are running a linux shell as root.

Run a container using the busybox image (a useful image containing a set of
common utilities).

```bash
# ctr image pull docker.io/library/busybox:1.36.0-musl
# ctr run -t --rm docker.io/library/busybox:1.36.0-musl ex1
```

In another window:
```bash
# ctr task ls
```

List the namespaces associated with the PID of the running container

```bash
# CPID=$(ctr task ls | grep ex1 | awk '{print $2}')
# lsns | grep $CPID
```

The above command will run a list where we see that the container run time 
is using 5 different namespaces to provide isolation for the processes 
running in the container. The following series of articles 

+ [Mount namespaces](http://lwn.net/2001/0301/a/namespaces.php3)
+ [UTS namespaces](https://lwn.net/Articles/179345/)
+ [IPC namespaces](https://lwn.net/Articles/187274/)
+ [PID namespaces](https://lwn.net/Articles/259217/)
+ [Network namespaces](https://lwn.net/Articles/219794/)

