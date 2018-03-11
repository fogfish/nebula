# Nebula

The solution implements Erlang nodes discovery for microservices deployable to Amazon ECS, Kubernetes or other Docker-based environments.

## Inspiration

Erlang cluster is build from loosely connected nodes that uses **tcp/ip** transport. Each node listens on different ports, which are allocated from pool. It requires a naming service that coordinates ports discovery. Erlang/OTP implements Erlang Port Mapper Daemon (**epmd**) for this purposes. It is responsible for mapping and discovery the symbolic node names to node address (**ip**, **tcp ports**). However, this solution do not work out of the box in scalable manner in the container-based environment. The discovery needs to account Docker's network topology, dynamic port allocation, etc.

This project implements a container appliance to solve Erlang node discovery.


## Key features 

* [Distribution protocol](doc/protocol.md) to support node discovery in decentralized manner.
* Listener of docker containers status.
* HTTP-based discovery and port mapping.




## Getting Started

The easiest way to run a discovery daemon is with the Docker container. It downloads and runs the latest build of daemon

```
docker run -it \
   --name nebula --rm \
   -p 4370:4370 \
   -v /var/run/docker.sock:/var/run/docker.sock \
   fogfish/nebula
``` 

Alternatively, you can built it from sources.   

```
make dist-up
``` 


This bring Nebula up and listening on port **4370**. 


## References

* https://www.erlang-solutions.com/blog/erlang-and-elixir-distribution-without-epmd.html
* https://github.com/Random-Liu/Erlang-In-Docker
* https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
* https://forums.docker.com/t/remote-api-with-docker-for-mac-beta/15639/2

