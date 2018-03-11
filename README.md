# Nebula

The solution implements Erlang nodes discovery for microservices deployable to Amazon ECS, Kubernetes or other Docker-based environments.


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

https://www.erlang-solutions.com/blog/erlang-and-elixir-distribution-without-epmd.html
https://github.com/Random-Liu/Erlang-In-Docker
https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
https://forums.docker.com/t/remote-api-with-docker-for-mac-beta/15639/2

