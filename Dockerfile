FROM ubuntu:17.10

ENV GOOS linux
ENV GOARCH amd64
# ENV CGO_ENABLED 0
# ENV GODEBUG netdns=go

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		wget \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
		git \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.8.5

RUN wget --no-check-certificate -O go.tgz \
"https://golang.org/dl/go${GOLANG_VERSION}.${GOOS}-${GOARCH}.tar.gz" \
&& tar -C /usr/local -xzf go.tgz && rm go.tgz

RUN export PATH="/usr/local/go/bin:$PATH"

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN go get -u github.com/golang/dep/cmd/dep

RUN echo '#!/bin/bash -x\n\
go build -buildmode=plugin -ldflags="-w -s" -o $1.so\n\
' > /usr/local/bin/build && \
chmod +x /usr/local/bin/build

ADD . /go/src/github.com/nmeji/google-cloud-functions-go
RUN cd $GOPATH/src/github.com/nmeji/google-cloud-functions-go && ./build \
	&& mv cloud-functions-go /bin && mv cloud-functions-go-shim /bin
RUN rm -fr $GOPATH/src/github.com/nmeji/google-cloud-functions-go
