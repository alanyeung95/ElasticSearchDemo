### Build
FROM golang:1.13-alpine3.10 AS builder

# Dependency
RUN apk add --no-cache git gcc g++

# Compile app with rest of source
RUN git clone https://github.com/rwynn/monstache.git /monstache
WORKDIR /monstache
RUN git checkout v5.4.3 && \
    go install

# Since we need to build the plugin with exact modules version that monstache use in according to the go.mod provided in monstache.
# If we need to go get speific version insated of latest version, we need to set here.
RUN go get github.com/mitchellh/mapstructure@v1.2.2
RUN go mod download

### Pack
FROM golang:1.13-alpine3.10 
WORKDIR /
COPY --from=builder /go/bin/monstache /bin/monstache
CMD ["/bin/monstache"]

