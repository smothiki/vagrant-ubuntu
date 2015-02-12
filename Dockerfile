FROM ubuntu

RUN apt-get -y install gccgo-go

RUN apt-get -y install git

RUN echo "export GOROOT=/go" >> /etc/bash.bashrc

RUN echo "export PATH=$PATH:/go/bin" >> /etc/bash.bashrc

RUN mkdir -p /go/src/github.com/docker

WORKDIR /go/src/github.com/docker

RUN git clone https://github.com/docker/swarm

WORKDIR /go/src/github.com/docker/swarm

ENV GOPATH /go/src/github.com/docker/swarm/Godeps/_workspace:$GOPATH
RUN CGO_ENABLED=0 go install -v -a -tags netgo -ldflags "-w -X github.com/docker/swarm/version.GITCOMMIT `git rev-parse --short HEAD`"

ENV SWARM_HOST :2375
EXPOSE 2375

VOLUME $HOME/.swarm

ENTRYPOINT ["swarm"]
CMD ["--help"]
