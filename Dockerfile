FROM ubuntu

RUN apt-get update

RUN apt-get -y install golang

RUN apt-get -y install git

RUN export PATH=$PATH:/usr/local/go/bin

ENV PATH $PATH:/go/bin

ENV GOPATH /go

RUN mkdir -p /go/src/github.com/docker

WORKDIR /go/src/github.com/docker

RUN git clone https://github.com/docker/swarm

WORKDIR /go/src/github.com/docker/swarm

ENV GOPATH /go/src/github.com/docker/swarm/Godeps/_workspace:$GOPATH

RUN echo $GOPATH $GOROOT
RUN CGO_ENABLED=0 go install -v -a -tags netgo -ldflags "-w -X github.com/docker/swarm/version.GITCOMMIT `git rev-parse --short HEAD`"

ENV SWARM_HOST :2375
EXPOSE 2375

VOLUME $HOME/.swarm

ENTRYPOINT ["swarm"]
CMD ["--help"]
